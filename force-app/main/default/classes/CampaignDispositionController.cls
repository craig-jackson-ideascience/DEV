public with sharing class CampaignDispositionController {

    private static List<String> getDispositionStatusLabels(){
        return Label.Campaign_Disposition_Statuses.split('\\r?\\n');
    }


    @AuraEnabled(cacheable=true)
    public static Boolean checkForStatuses(ID campaignID){
        //create a set of the current Campaign Member Statuses
        List<CampaignMemberStatus> currentStatusList = new List<CampaignMemberStatus>();
        currentStatusList = [SELECT Label FROM CampaignMemberStatus WHERE CampaignId = :campaignID];
        Set<String> currentStatusSet = new Set<String>();
        for(CampaignMemberStatus status : currentStatusList){
            currentStatusSet.add(status.Label);
        }

        //get list of the disposition Campaign Member Statuses
        List<String> dispositionStatusList = getDispositionStatusLabels();

        //check to see if all disposition Campaign Member Statuses already exist for this campaign
        //return true if all of them do; otherwise return false
        for(String status : dispositionStatusList){
            if( !currentStatusSet.contains(status) ){
                return false;
            }
        }
        return true;
    }


    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getPriorAutoDispositionedData(ID campaignID){
        //get previously auto-dispositioned Campaign Members and their statuses for this campaign
        List<CampaignMember> cms = new List<CampaignMember>();
        cms = [SELECT Name, Type, Status, Status_Date__c, Status_Reason__c
               FROM CampaignMember
               WHERE Status_Date__c != null
               AND Status_Reason__c != null
               AND (Status = 'Customer' OR Status = '2a. Unqualified' OR Status = '2b. Existing Opp')
               AND CampaignId = :campaignID
               ORDER BY Status ASC, Name ASC
              ];
        return cms;
    }
    

    @AuraEnabled
    public static void addStatuses(ID campaignID){
        //query existing Campaign Member Statuses
        List<CampaignMemberStatus> currentStatuses = new List<CampaignMemberStatus>();
        currentStatuses = [SELECT Label, SortOrder
                           FROM CampaignMemberStatus
                           WHERE CampaignId = :campaignID
                           ORDER BY SortOrder DESC];
        
        //determine starting SortOrder value for new Campaign Member Statuses
        Integer maxCurrentSortOrder = 0;
        if(currentStatuses.size() > 0){
            maxCurrentSortOrder = currentStatuses[0].SortOrder;
        }
        Integer startingSortOrder = maxCurrentSortOrder + 1;

        //create Set of existing status labels
        Set<String> currentStatusLabels = new Set<String>();
        for(CampaignMemberStatus currentStatus : currentStatuses){
            currentStatusLabels.add(currentStatus.Label);
        }

        //check for any Campaign Members
        Integer cmCount = [SELECT COUNT() FROM CampaignMember WHERE CampaignId = :campaignID];
        
        //if no Campaign Members exist, set boolean to delete current Campaign Member Statuses later
        Boolean deleteCurrentStatuses = false;
        if(cmCount == 0 && currentStatuses.size() > 0){
            deleteCurrentStatuses = true;
        }

        //prep new Campaign Member Statuses to be inserted
        List<String> newStatusLabels = getDispositionStatusLabels();
        List<CampaignMemberStatus> newStatuses = new List<CampaignMemberStatus>();
        for(Integer i=0; i<newStatusLabels.size(); i++){
            String label = newStatusLabels[i];
            if( !currentStatusLabels.contains(label) ){
                CampaignMemberStatus status = new CampaignMemberStatus();
                status.CampaignID = campaignID;
                status.Label = label;
                status.SortOrder = startingSortOrder + i;
                if(label == '0. New'){
                    status.IsDefault = true;
                }
                if(label == '5. Working' || label == '6. SQL'){
                    status.HasResponded = true;
                }
                newStatuses.add(status);
            }
        }
        
        if(newStatuses.size() > 0){
            insert newStatuses;
        }

        if(deleteCurrentStatuses){
            //before deleting current statuses, make sure you're not deleting any of the
            //disposition statuses that SHOULD be there
            for(Integer i=currentStatuses.size()-1; i>=0; i--){
                if( newStatusLabels.contains(currentStatuses[i].Label) ){
                    currentStatuses.remove(i);
                }
            }
            //delete any remaining current statuses -- in most cases, this will just be the
            //default status values of 'Sent' and 'Responded'
            if(currentStatuses.size() > 0){
                delete currentStatuses;
            }
        }
        return;
    }


    @AuraEnabled
    public static Integer updateStatuses(ID campaignID, ID projectID){
        //1. GET CAMPAIGN MEMBERS AND ACCOUNT FOR EACH CAMPAIGN MEMBER

        //form query to get Campaign Members
        //forming it as a string so that it can also be used by batch apex
        String query = '';
        query += 'SELECT Id, Status, Name, ';
        query += 'LeadId, Lead.Email, Lead.Account__c, Lead.Company, Lead.Title, ';
        query += 'ContactId, Contact.Email, Contact.AccountId, Contact.Title, ';
        query += 'Campaign.Name, Campaign.Project__c ';
        query += 'FROM CampaignMember ';
        query += 'WHERE CampaignId = \'' + campaignID + '\' ';
        query += 'AND Status = \'0. New\'';

        //get Campaign Members
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        campaignMembers = Database.query(query);

        //if query returned 0 Campaign Members, return 0
        if(campaignMembers.size() == 0){
            return 0;

        //if query returned 100 Campaign Members or more, execute batch and return -1
        }else if(campaignMembers.size() >= 100){
            String userEmail = UserInfo.getUserEmail();
            String campaignName = campaignMembers[0].Campaign.Name;
            CampaignDispositionBatch cdb = new CampaignDispositionBatch(projectID, campaignID, campaignName, userEmail, query);
            Database.executeBatch(cdb, 100); //batch size of 100 records at a time

            //indicate to LWC that batch was run by returning -1
            return -1;

        //otherwise proceed with regular (non-batch) processing
        }else{
            Integer numCMsUpdated = processCampaignMembers(campaignMembers, projectID);

            //return number of Campaign Members statuses updated
            return numCMsUpdated;
        }
    }


    //this is split into its own method so that the batch class can use it as well
    public static Integer processCampaignMembers(List<CampaignMember> campaignMembers, ID projectID){

        //1. DETERMINE ACCOUNT FOR EACH CAMPAIGN MEMBER

        //create set of Campaign Members' email domains
        //also populate map of Campain Members' ID to name, used at very end of method
        Set<String> cmEmailDomains = new Set<String>();
        Map<ID, String> cmIDToName = new Map<ID, String>();
        for(CampaignMember cm : campaignMembers){
            if(cm.Lead.Email != null){
                String domain = cm.Lead.Email.substringAfterLast('@');
                cmEmailDomains.add(domain);
            }else if(cm.Contact.Email != null){
                String domain = cm.Contact.Email.substringAfterLast('@');
                cmEmailDomains.add(domain);
            }
            cmIDToName.put(cm.Id, cm.Name);
        }

        //query accounts with Account Domains that match the email domains collected
        List<Account> accountsByDomain = new List<Account>();
        accountsByDomain = [SELECT Account_Domain__c
                            FROM Account
                            WHERE Account_Domain__c IN :cmEmailDomains
                            ORDER BY Previous_Year_Total_Spend__c ASC, Annual_Spend__c ASC
                           ];
        //create map of Account Domain to Account ID
        Map<String, ID> accountDomainToID = new Map<String, ID>();
        for(Account acc : accountsByDomain){
            accountDomainToID.put(acc.Account_Domain__c, acc.Id);
        }
        
        //create and populate map of Campaign Member ID to correct Account
        Map<CampaignMember, ID> cmToAccount = new Map<CampaignMember, ID>();
        for(CampaignMember cm : campaignMembers){

            //if Campaign Member is a Lead
            if(cm.LeadId != null){
                Boolean accFound = false;

                //try getting Account from Lead record first
                if(cm.Lead.Account__c != null && cm.Lead.Account__c != System.label.Individual_No_Account){
                    cmToAccount.put(cm, cm.Lead.Account__c);
                    accFound = true;
                
                //if Lead record didn't have Account, try matching by email domain
                }else if(cm.Lead.Email != null){
                    String domain = cm.Lead.Email.substringAfterLast('@');
                    if( accountDomainToID.containsKey(domain) ){
                        ID accID = accountDomainToID.get(domain);
                        cmToAccount.put(cm, accID);
                        accFound = true;
                    }
                }

                //if Account still hasn't been found, add CM to cmToAccount map with null value for Account
                if(!accFound){
                    cmToAccount.put(cm, null);
                }
                
            //if Campaign Member is a Contact
            }else if(cm.ContactId != null){
                Boolean accFound = false;

                //try getting Account from Contact record first
                if(cm.Contact.AccountId != null && cm.Contact.AccountId != System.label.Individual_No_Account){
                    cmToAccount.put(cm, cm.Contact.AccountId);
                    accFound = true;
                
                //if Contact record didn't have Account, try matching by email domain
                }else if(cm.Contact.Email != null){
                    String domain = cm.Contact.Email.substringAfterLast('@');
                    if( accountDomainToID.containsKey(domain) ){
                        ID accID = accountDomainToID.get(domain);
                        cmToAccount.put(cm, accID);
                        accFound = true;
                    }
                }

                //if Account still hasn't been found, add CM to cmToAccount map with null value for Account
                if(!accFound){
                    cmToAccount.put(cm, null);
                }
            }
        }
        System.debug(cmToAccount);


        //2. GET ALL DATA NECESSARY TO DETERMINE STATUS FOR EACH CAMPAIGN MEMBER

        //get memberships to determine 'Customer' status
        List<Membership__c> activeMemberships = new List<Membership__c>();
        activeMemberships = [SELECT Account__c
                             FROM Membership__c
                             WHERE Project__c = :projectID
                             AND Account__c IN :cmToAccount.values()
                             AND (Status__c = 'Active' OR Status__c = 'Purchased')
                            ];
        Set<ID> accountsWithActiveMemberships = new Set<ID>();
        for(Membership__c memb : activeMemberships){
            accountsWithActiveMemberships.add(memb.Account__c);
        }

        //get free email domains to determine '2a. Unqualified' status
        Set<String> freeEmailDomains = getFreeEmailDomains();

        //get OLIs attached to open Opps to determine '2b. Existing Opp' status
        List<OpportunityLineItem> olisOfOpenOpps = new List<OpportunityLineItem>();
        olisOfOpenOpps = [SELECT Opportunity.AccountId
                          FROM OpportunityLineItem
                          WHERE Opportunity.AccountId IN :cmToAccount.values()
                          AND Opportunity.StageName != 'Closed Won'
                          AND Opportunity.StageName != 'Closed Lost'
                          AND Product_Details__r.Project__c = :projectID
                         ];
        Set<ID> accountsWithOpenOpps = new Set<ID>();
        for(OpportunityLineItem oli : olisOfOpenOpps){
            accountsWithOpenOpps.add(oli.Opportunity.AccountId);
        }


        //3. DETERMINE STATUS FOR EACH CAMPAIGN MEMBER

        //loop through Campaign Member to Account map to determine status for each Campaign Member
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        for( CampaignMember cm : cmToAccount.keySet() ){
            ID accID = cmToAccount.get(cm);

            //'Customer' check
            if( accountsWithActiveMemberships.contains(accID) ){
                cm.Status = 'Customer';
                cm.Status_Reason__c = 'active or purchased membership for this project found';
                cm.Status_Date__c = Date.today();
                cm.Skip_Mass_Disposition_Trigger__c = true;
                cmsToUpdate.add(cm);
                continue;
            }

            //calculate email domain for this Campaign Member for unqualified check
            String emailDomain = '';
            if(cm.ContactId != null && cm.Contact.Email != null){
                emailDomain += cm.Contact.Email.substringAfterLast('@');
            }else if(cm.LeadId != null && cm.Lead.Email != null){
                emailDomain += cm.Lead.Email.substringAfterLast('@');
            }

            //'2a. Unqualified' checks
            if(emailDomain.endsWith('.edu') || emailDomain.endsWith('.org') || emailDomain.endsWith('.gov') || emailDomain.contains('.org.')){
                cm.Status = '2a. Unqualified';
                cm.Status_Reason__c = '.edu, .gov, or .org email';
                cm.Status_Date__c = Date.today();
                cm.Skip_Mass_Disposition_Trigger__c = true;
                cmsToUpdate.add(cm);
                continue;
            }else if(cm.LeadId != null && cm.Lead.Company == null && cm.Lead.Title == null && freeEmailDomains.contains(emailDomain)){
                cm.Status = '2a. Unqualified';
                cm.Status_Reason__c = ('Lead with blank Company, blank Title, and non-corporate email');
                cm.Status_Date__c = Date.today();
                cm.Skip_Mass_Disposition_Trigger__c = true;
                cmsToUpdate.add(cm);
                continue;
            }else if(cm.ContactId != null  && cm.Contact.Title == null && freeEmailDomains.contains(emailDomain)
                     && (cm.Contact.AccountId == System.label.Individual_No_Account || cm.Contact.AccountId == null)){
                cm.Status = '2a. Unqualified';
                cm.Status_Reason__c = ('Contact with no Account, blank Title, and non-corporate email');
                cm.Status_Date__c = Date.today();
                cm.Skip_Mass_Disposition_Trigger__c = true;
                cmsToUpdate.add(cm);
                continue;
            }

            //'2b. Existing Opp' check
            if( accountsWithOpenOpps.contains(accID) ){
                cm.Status = '2b. Existing Opp';
                cm.Status_Reason__c = ('open Opportunity for this project found');
                cm.Status_Date__c = Date.today();
                cm.Skip_Mass_Disposition_Trigger__c = true;
                cmsToUpdate.add(cm);
                continue;
            }
        }

        //update Campaign Member statuses and return
        if(cmsToUpdate.size() > 0){
            update cmsToUpdate;
        }

        //return number of Campaign Members statuses updated
        return cmsToUpdate.size();
    }


    private static Set<String> getFreeEmailDomains(){
        Set<String> freeEmailDomains = new Set<String>();
        freeEmailDomains.add('007addict.com');
        freeEmailDomains.add('020.co.uk');
        freeEmailDomains.add('123.com');
        freeEmailDomains.add('123box.net');
        freeEmailDomains.add('123india.com');
        freeEmailDomains.add('123qwe.co.uk');
        freeEmailDomains.add('138mail.com');
        freeEmailDomains.add('150mail.com');
        freeEmailDomains.add('150ml.com');
        freeEmailDomains.add('15meg4free.com');
        freeEmailDomains.add('16mail.com');
        freeEmailDomains.add('1auto.com');
        freeEmailDomains.add('1colony.com');
        freeEmailDomains.add('1freeemail.com');
        freeEmailDomains.add('247emails.com');
        freeEmailDomains.add('24horas.com');
        freeEmailDomains.add('2coolforyou.net');
        freeEmailDomains.add('2die4.com');
        freeEmailDomains.add('2hotforyou.net');
        freeEmailDomains.add('2mydns.com');
        freeEmailDomains.add('2net.us');
        freeEmailDomains.add('360.ru');
        freeEmailDomains.add('37.com');
        freeEmailDomains.add('3ammagazine.com');
        freeEmailDomains.add('3email.com');
        freeEmailDomains.add('3xl.net');
        freeEmailDomains.add('444.net');
        freeEmailDomains.add('4email.com');
        freeEmailDomains.add('4mg.com');
        freeEmailDomains.add('4newyork.com');
        freeEmailDomains.add('4x4fan.com');
        freeEmailDomains.add('50mail.com');
        freeEmailDomains.add('5fm.za.com');
        freeEmailDomains.add('5iron.com');
        freeEmailDomains.add('702mail.co.za');
        freeEmailDomains.add('8848.net');
        freeEmailDomains.add('a-player.org');
        freeEmailDomains.add('a2z4u.net');
        freeEmailDomains.add('aahlife.com');
        freeEmailDomains.add('aaronkwok.net');
        freeEmailDomains.add('abbeyroadlondon.co.uk');
        freeEmailDomains.add('aberystwyth.com');
        freeEmailDomains.add('about.com');
        freeEmailDomains.add('absolutevitality.com');
        freeEmailDomains.add('abv.bg');
        freeEmailDomains.add('acceso.or.cr');
        freeEmailDomains.add('access4less.net');
        freeEmailDomains.add('accessgcc.com');
        freeEmailDomains.add('accountant.com');
        freeEmailDomains.add('acdczone.com');
        freeEmailDomains.add('acmemail.net');
        freeEmailDomains.add('acninc.net');
        freeEmailDomains.add('acrobatmail.com');
        freeEmailDomains.add('adexec.com');
        freeEmailDomains.add('adres.nl');
        freeEmailDomains.add('aeiou.pt');
        freeEmailDomains.add('aemail4u.com');
        freeEmailDomains.add('aeneasmail.com');
        freeEmailDomains.add('afreeinternet.com');
        freeEmailDomains.add('africa-11.com');
        freeEmailDomains.add('africamail.com');
        freeEmailDomains.add('africanpartnersonline.com');
        freeEmailDomains.add('agelessemail.com');
        freeEmailDomains.add('agoodmail.com');
        freeEmailDomains.add('ahaa.dk');
        freeEmailDomains.add('aichi.com');
        freeEmailDomains.add('aiutamici.com');
        freeEmailDomains.add('aknet.kg');
        freeEmailDomains.add('akphantom.com');
        freeEmailDomains.add('albawaba.com');
        freeEmailDomains.add('alex4all.com');
        freeEmailDomains.add('alexandria.cc');
        freeEmailDomains.add('algeria.com');
        freeEmailDomains.add('algeriamail.com');
        freeEmailDomains.add('aliceinchainsmail.com');
        freeEmailDomains.add('allergist.com');
        freeEmailDomains.add('alloymail.com');
        freeEmailDomains.add('allsaintsfan.com');
        freeEmailDomains.add('alskens.dk');
        freeEmailDomains.add('altavista.com');
        freeEmailDomains.add('altavista.se');
        freeEmailDomains.add('alternativagratis.com');
        freeEmailDomains.add('alumnidirector.com');
        freeEmailDomains.add('amele.com');
        freeEmailDomains.add('america.hm');
        freeEmailDomains.add('amrer.net');
        freeEmailDomains.add('amuro.net');
        freeEmailDomains.add('amuromail.com');
        freeEmailDomains.add('ananzi.co.za');
        freeEmailDomains.add('andreabocellimail.com');
        freeEmailDomains.add('andylau.net');
        freeEmailDomains.add('anfmail.com');
        freeEmailDomains.add('angelfire.com');
        freeEmailDomains.add('anjungcafe.com');
        freeEmailDomains.add('anniefans.com');
        freeEmailDomains.add('anti-ignorance.net');
        freeEmailDomains.add('antiqueemail.com');
        freeEmailDomains.add('antwerpen.com');
        freeEmailDomains.add('anymoment.com');
        freeEmailDomains.add('anytimenow.com');
        freeEmailDomains.add('aon.at');
        freeEmailDomains.add('apexmail.com');
        freeEmailDomains.add('apollo.lv');
        freeEmailDomains.add('aport.ru');
        freeEmailDomains.add('aport2000.ru');
        freeEmailDomains.add('apple.sib.ru');
        freeEmailDomains.add('approvers.net');
        freeEmailDomains.add('aquaticmail.net');
        freeEmailDomains.add('arabia.com');
        freeEmailDomains.add('arabtop.net');
        freeEmailDomains.add('archaeologist.com');
        freeEmailDomains.add('archerymail.com');
        freeEmailDomains.add('arcor.de');
        freeEmailDomains.add('arcticmail.com');
        freeEmailDomains.add('argentina.com');
        freeEmailDomains.add('arhaelogist.com');
        freeEmailDomains.add('arnet.com.ar');
        freeEmailDomains.add('artistemail.com');
        freeEmailDomains.add('artlover.com');
        freeEmailDomains.add('artlover.com.au');
        freeEmailDomains.add('asean-mail.com');
        freeEmailDomains.add('asheville.com');
        freeEmailDomains.add('asia-links.com');
        freeEmailDomains.add('asia.com');
        freeEmailDomains.add('asianavenue.com');
        freeEmailDomains.add('asiancityweb.com');
        freeEmailDomains.add('asianwired.net');
        freeEmailDomains.add('askaclub.ru');
        freeEmailDomains.add('assamesemail.com');
        freeEmailDomains.add('astroboymail.com');
        freeEmailDomains.add('asurfer.com');
        freeEmailDomains.add('atlas.cz');
        freeEmailDomains.add('atlaswebmail.com');
        freeEmailDomains.add('atozasia.com');
        freeEmailDomains.add('atrus.ru');
        freeEmailDomains.add('au.ru');
        freeEmailDomains.add('aufeminin.com');
        freeEmailDomains.add('aus-city.com');
        freeEmailDomains.add('ausi.com');
        freeEmailDomains.add('australiamail.com');
        freeEmailDomains.add('automail.ru');
        freeEmailDomains.add('avh.hu');
        freeEmailDomains.add('avtoritet.ru');
        freeEmailDomains.add('awayonvacation.com');
        freeEmailDomains.add('ayna.com');
        freeEmailDomains.add('backfliper.com');
        freeEmailDomains.add('backstreetboysclub.com');
        freeEmailDomains.add('backtothefuturefans.com');
        freeEmailDomains.add('badtzmail.com');
        freeEmailDomains.add('bakpaka.com');
        freeEmailDomains.add('bakpaka.net');
        freeEmailDomains.add('ballerstatus.net');
        freeEmailDomains.add('balochistan.org');
        freeEmailDomains.add('baluch.com');
        freeEmailDomains.add('baptistmail.com');
        freeEmailDomains.add('baptized.com');
        freeEmailDomains.add('barlick.net');
        freeEmailDomains.add('baseball-email.com');
        freeEmailDomains.add('batuta.net');
        freeEmailDomains.add('bboy.com');
        freeEmailDomains.add('bcvibes.com');
        freeEmailDomains.add('beep.ru');
        freeEmailDomains.add('beer.com');
        freeEmailDomains.add('beerandremotes.com');
        freeEmailDomains.add('beethoven.com');
        freeEmailDomains.add('beirut.com');
        freeEmailDomains.add('belizehome.com');
        freeEmailDomains.add('belizemail.net');
        freeEmailDomains.add('belizeweb.com');
        freeEmailDomains.add('berlin.com');
        freeEmailDomains.add('berlin.de');
        freeEmailDomains.add('bharatmail.com');
        freeEmailDomains.add('big5mail.com');
        freeEmailDomains.add('bigfoot.com');
        freeEmailDomains.add('bigfoot.de');
        freeEmailDomains.add('bigger.com');
        freeEmailDomains.add('bigmailbox.com');
        freeEmailDomains.add('bigramp.com');
        freeEmailDomains.add('bikerider.com');
        freeEmailDomains.add('biologyfan.com');
        freeEmailDomains.add('birdfanatic.com');
        freeEmailDomains.add('bizhosting.com');
        freeEmailDomains.add('bk.ru');
        freeEmailDomains.add('bkkmail.com');
        freeEmailDomains.add('blackburnfans.com');
        freeEmailDomains.add('blackburnmail.com');
        freeEmailDomains.add('blackplanet.com');
        freeEmailDomains.add('blazemail.com');
        freeEmailDomains.add('blink182.net');
        freeEmailDomains.add('blondandeasy.com');
        freeEmailDomains.add('bluebottle.com');
        freeEmailDomains.add('bluemail.ch');
        freeEmailDomains.add('bluemail.dk');
        freeEmailDomains.add('blushmail.com');
        freeEmailDomains.add('bmlsports.net');
        freeEmailDomains.add('boardermail.com');
        freeEmailDomains.add('boarderzone.com');
        freeEmailDomains.add('bol.com.br');
        freeEmailDomains.add('bolando.com');
        freeEmailDomains.add('bollywoodz.com');
        freeEmailDomains.add('bolt.com');
        freeEmailDomains.add('bonbon.net');
        freeEmailDomains.add('boom.com');
        freeEmailDomains.add('bootmail.com');
        freeEmailDomains.add('bornagain.com');
        freeEmailDomains.add('bostonoffice.com');
        freeEmailDomains.add('bounce.net');
        freeEmailDomains.add('boxemail.com');
        freeEmailDomains.add('boyzoneclub.com');
        freeEmailDomains.add('brasilia.net');
        freeEmailDomains.add('bratan.ru');
        freeEmailDomains.add('brazilmail.com.br');
        freeEmailDomains.add('breathe.com');
        freeEmailDomains.add('brestonline.com');
        freeEmailDomains.add('brfree.com.br');
        freeEmailDomains.add('britneyclub.com');
        freeEmailDomains.add('broadwaybuff.com');
        freeEmailDomains.add('broadwaylove.com');
        freeEmailDomains.add('brokeandhappy.com');
        freeEmailDomains.add('brujula.net');
        freeEmailDomains.add('brunetka.ru');
        freeEmailDomains.add('btcc.org');
        freeEmailDomains.add('bulgaria.com');
        freeEmailDomains.add('bunita.net');
        freeEmailDomains.add('burntmail.com');
        freeEmailDomains.add('bushemail.com');
        freeEmailDomains.add('businessman.net');
        freeEmailDomains.add('bust.com');
        freeEmailDomains.add('butch-femme.net');
        freeEmailDomains.add('butovo.net');
        freeEmailDomains.add('buzy.com');
        freeEmailDomains.add('bvimailbox.com');
        freeEmailDomains.add('byke.com');
        freeEmailDomains.add('c3.hu');
        freeEmailDomains.add('c4.com');
        freeEmailDomains.add('cairomail.com');
        freeEmailDomains.add('calcuttaads.com');
        freeEmailDomains.add('callnetuk.com');
        freeEmailDomains.add('canada-11.com');
        freeEmailDomains.add('canada.com');
        freeEmailDomains.add('canoemail.com');
        freeEmailDomains.add('caramail.com');
        freeEmailDomains.add('care2.com');
        freeEmailDomains.add('carioca.net');
        freeEmailDomains.add('cashette.com');
        freeEmailDomains.add('cataloniamail.com');
        freeEmailDomains.add('cataz.com');
        freeEmailDomains.add('catcha.com');
        freeEmailDomains.add('catemail.com');
        freeEmailDomains.add('catholic.org');
        freeEmailDomains.add('catlover.com');
        freeEmailDomains.add('celineclub.com');
        freeEmailDomains.add('centralpets.com');
        freeEmailDomains.add('centrum.cz');
        freeEmailDomains.add('centrum.sk');
        freeEmailDomains.add('chaiyo.com');
        freeEmailDomains.add('chaiyomail.com');
        freeEmailDomains.add('chalkmail.net');
        freeEmailDomains.add('chance2mail.com');
        freeEmailDomains.add('channelonetv.com');
        freeEmailDomains.add('charityemail.com');
        freeEmailDomains.add('chat.ru');
        freeEmailDomains.add('chatlane.ru');
        freeEmailDomains.add('chattown.com');
        freeEmailDomains.add('check1check.com');
        freeEmailDomains.add('cheeb.com');
        freeEmailDomains.add('cheerful.com');
        freeEmailDomains.add('chefmail.com');
        freeEmailDomains.add('chemist.com');
        freeEmailDomains.add('chequemail.com');
        freeEmailDomains.add('cheshiremail.com');
        freeEmailDomains.add('chickmail.com');
        freeEmailDomains.add('chil-e.com');
        freeEmailDomains.add('chinesecool.com');
        freeEmailDomains.add('chirk.com');
        freeEmailDomains.add('chocaholic.com.au');
        freeEmailDomains.add('chocofan.com');
        freeEmailDomains.add('chronicspender.com');
        freeEmailDomains.add('ciaoweb.it');
        freeEmailDomains.add('cirquefans.com');
        freeEmailDomains.add('city-of-swansea.com');
        freeEmailDomains.add('city-of-westminster.com');
        freeEmailDomains.add('citynetusa.com');
        freeEmailDomains.add('claramail.com');
        freeEmailDomains.add('clerk.com');
        freeEmailDomains.add('clickforadate.com');
        freeEmailDomains.add('cliffhanger.com');
        freeEmailDomains.add('close2you.net');
        freeEmailDomains.add('cluemail.com');
        freeEmailDomains.add('cmail.ru');
        freeEmailDomains.add('cmpnetmail.com');
        freeEmailDomains.add('collegeclub.com');
        freeEmailDomains.add('columnist.com');
        freeEmailDomains.add('comic.com');
        freeEmailDomains.add('complxmind.com');
        freeEmailDomains.add('compuserve.com');
        freeEmailDomains.add('computer-expert.net');
        freeEmailDomains.add('computerconfused.com');
        freeEmailDomains.add('computermail.net');
        freeEmailDomains.add('computernaked.com');
        freeEmailDomains.add('cong.ru');
        freeEmailDomains.add('connect4free.net');
        freeEmailDomains.add('connectbox.com');
        freeEmailDomains.add('consultant.com');
        freeEmailDomains.add('cookiemonster.com');
        freeEmailDomains.add('cool.br');
        freeEmailDomains.add('coolgoose.com');
        freeEmailDomains.add('coolkiwi.com');
        freeEmailDomains.add('coollist.com');
        freeEmailDomains.add('coolmail.com');
        freeEmailDomains.add('coolmail.net');
        freeEmailDomains.add('coolrio.com');
        freeEmailDomains.add('coolsend.com');
        freeEmailDomains.add('copacabana.com');
        freeEmailDomains.add('copticmail.com');
        freeEmailDomains.add('corrsfan.com');
        freeEmailDomains.add('cosmo.com');
        freeEmailDomains.add('counsellor.com');
        freeEmailDomains.add('craftemail.com');
        freeEmailDomains.add('crazy.ru');
        freeEmailDomains.add('crewstart.com');
        freeEmailDomains.add('critterpost.com');
        freeEmailDomains.add('croeso.com');
        freeEmailDomains.add('crosswinds.net');
        freeEmailDomains.add('crunkmail.com');
        freeEmailDomains.add('cry4helponline.com');
        freeEmailDomains.add('cryingmail.com');
        freeEmailDomains.add('cs.com');
        freeEmailDomains.add('cumbriamail.com');
        freeEmailDomains.add('curio-city.com');
        freeEmailDomains.add('cutekittens.com');
        freeEmailDomains.add('cutey.com');
        freeEmailDomains.add('cww.de');
        freeEmailDomains.add('cybercity-online.net');
        freeEmailDomains.add('cyberinbox.com');
        freeEmailDomains.add('cyberleports.com');
        freeEmailDomains.add('cybernet.it');
        freeEmailDomains.add('cymail.net');
        freeEmailDomains.add('dabsol.net');
        freeEmailDomains.add('dansegulvet.com');
        freeEmailDomains.add('data54.com');
        freeEmailDomains.add('date.by');
        freeEmailDomains.add('dbzmail.com');
        freeEmailDomains.add('dcsi.net');
        freeEmailDomains.add('deafemail.net');
        freeEmailDomains.add('dearriba.com');
        freeEmailDomains.add('deepseafisherman.net');
        freeEmailDomains.add('deforestationsucks.com');
        freeEmailDomains.add('degoo.com');
        freeEmailDomains.add('deliveryman.com');
        freeEmailDomains.add('desertmail.com');
        freeEmailDomains.add('desertonline.com');
        freeEmailDomains.add('desertsaintsmail.com');
        freeEmailDomains.add('desilota.com');
        freeEmailDomains.add('deskpilot.com');
        freeEmailDomains.add('despammed.com');
        freeEmailDomains.add('detik.com');
        freeEmailDomains.add('dezigner.ru');
        freeEmailDomains.add('di-ve.com');
        freeEmailDomains.add('diamondemail.com');
        freeEmailDomains.add('didamail.com');
        freeEmailDomains.add('diehardmail.com');
        freeEmailDomains.add('digitalforeplay.net');
        freeEmailDomains.add('digosnet.com');
        freeEmailDomains.add('diplomats.com');
        freeEmailDomains.add('director-general.com');
        freeEmailDomains.add('diri.com');
        freeEmailDomains.add('discoverymail.net');
        freeEmailDomains.add('disinfo.net');
        freeEmailDomains.add('divorcedandhappy.com');
        freeEmailDomains.add('dmailman.com');
        freeEmailDomains.add('dmitrovka.net');
        freeEmailDomains.add('dmitry.ru');
        freeEmailDomains.add('dnsmadeeasy.com');
        freeEmailDomains.add('doar.net');
        freeEmailDomains.add('doctor.com');
        freeEmailDomains.add('dodgeit.com');
        freeEmailDomains.add('doglover.com');
        freeEmailDomains.add('dogmail.co.uk');
        freeEmailDomains.add('doityourself.com');
        freeEmailDomains.add('doneasy.com');
        freeEmailDomains.add('donegal.net');
        freeEmailDomains.add('donjuan.com');
        freeEmailDomains.add('dontgotmail.com');
        freeEmailDomains.add('doramail.com');
        freeEmailDomains.add('dostmail.com');
        freeEmailDomains.add('dotcom.fr');
        freeEmailDomains.add('dotnow.com');
        freeEmailDomains.add('dott.it');
        freeEmailDomains.add('dplanet.ch');
        freeEmailDomains.add('dr.com');
        freeEmailDomains.add('dragoncon.net');
        freeEmailDomains.add('dubaimail.com');
        freeEmailDomains.add('dublin.com');
        freeEmailDomains.add('dustdevil.com');
        freeEmailDomains.add('dvd-fan.net');
        freeEmailDomains.add('dygo.com');
        freeEmailDomains.add('dynamitemail.com');
        freeEmailDomains.add('e-apollo.lv');
        freeEmailDomains.add('e-hkma.com');
        freeEmailDomains.add('e-mail.ru');
        freeEmailDomains.add('e-mailanywhere.com');
        freeEmailDomains.add('e-mails.ru');
        freeEmailDomains.add('e-tapaal.com');
        freeEmailDomains.add('e-webtec.com');
        freeEmailDomains.add('eastmail.com');
        freeEmailDomains.add('eastrolog.com');
        freeEmailDomains.add('easy.com');
        freeEmailDomains.add('easypeasy.com');
        freeEmailDomains.add('ebprofits.net');
        freeEmailDomains.add('eircom.net');
        freeEmailDomains.add('elitemail.org');
        freeEmailDomains.add('elsitio.com');
        freeEmailDomains.add('eltimon.com');
        freeEmailDomains.add('elvis.com');
        freeEmailDomains.add('email-london.co.uk');
        freeEmailDomains.add('email-value.com');
        freeEmailDomains.add('email.com');
        freeEmailDomains.add('email.cz');
        freeEmailDomains.add('email.it');
        freeEmailDomains.add('email.nu');
        freeEmailDomains.add('email.ro');
        freeEmailDomains.add('email.ru');
        freeEmailDomains.add('email.si');
        freeEmailDomains.add('email2me.com');
        freeEmailDomains.add('email2me.net');
        freeEmailDomains.add('emailacc.com');
        freeEmailDomains.add('emailaccount.com');
        freeEmailDomains.add('emailaddresses.com');
        freeEmailDomains.add('emailchoice.com');
        freeEmailDomains.add('emailforyou.net');
        freeEmailDomains.add('emailgaul.com');
        freeEmailDomains.add('emailgroups.net');
        freeEmailDomains.add('emailoregon.com');
        freeEmailDomains.add('emailpinoy.com');
        freeEmailDomains.add('emailplanet.com');
        freeEmailDomains.add('emailplus.org');
        freeEmailDomains.add('emails.ru');
        freeEmailDomains.add('emailservice.com');
        freeEmailDomains.add('emailsydney.com');
        freeEmailDomains.add('emailx.net');
        freeEmailDomains.add('emale.ru');
        freeEmailDomains.add('ematic.com');
        freeEmailDomains.add('empereur.com');
        freeEmailDomains.add('emptymail.com');
        freeEmailDomains.add('enel.net');
        freeEmailDomains.add('enelpunto.net');
        freeEmailDomains.add('engineer.com');
        freeEmailDomains.add('england.com');
        freeEmailDomains.add('epatra.com');
        freeEmailDomains.add('epiqmail.com');
        freeEmailDomains.add('epomail.com');
        freeEmailDomains.add('epost.de');
        freeEmailDomains.add('eprompter.com');
        freeEmailDomains.add('eresmas.com');
        freeEmailDomains.add('eriga.lv');
        freeEmailDomains.add('eshche.net');
        freeEmailDomains.add('esmailweb.net');
        freeEmailDomains.add('etoast.com');
        freeEmailDomains.add('eudoramail.com');
        freeEmailDomains.add('europe.com');
        freeEmailDomains.add('euroseek.com');
        freeEmailDomains.add('evafan.com');
        freeEmailDomains.add('evertonfans.com');
        freeEmailDomains.add('everymail.net');
        freeEmailDomains.add('everyone.net');
        freeEmailDomains.add('excite.co.jp');
        freeEmailDomains.add('excite.com');
        freeEmailDomains.add('execs.com');
        freeEmailDomains.add('execs2k.com');
        freeEmailDomains.add('executivemail.co.za');
        freeEmailDomains.add('extended.com');
        freeEmailDomains.add('ezagenda.com');
        freeEmailDomains.add('ezcybersearch.com');
        freeEmailDomains.add('ezmail.ru');
        freeEmailDomains.add('fadrasha.net');
        freeEmailDomains.add('fadrasha.org');
        freeEmailDomains.add('fannclub.com');
        freeEmailDomains.add('fast-mail.org');
        freeEmailDomains.add('fastemailer.com');
        freeEmailDomains.add('fastermail.com');
        freeEmailDomains.add('fastest.cc');
        freeEmailDomains.add('fastimap.com');
        freeEmailDomains.add('fastmail.fm');
        freeEmailDomains.add('fastmail.gr');
        freeEmailDomains.add('fastmessaging.com');
        freeEmailDomains.add('fatyachts.com');
        freeEmailDomains.add('female.ru');
        freeEmailDomains.add('fepg.net');
        freeEmailDomains.add('ffanet.com');
        freeEmailDomains.add('fiberia.com');
        freeEmailDomains.add('filipinolinks.com');
        freeEmailDomains.add('financefan.net');
        freeEmailDomains.add('financier.com');
        freeEmailDomains.add('findfo.com');
        freeEmailDomains.add('findmail.com');
        freeEmailDomains.add('findmemail.com');
        freeEmailDomains.add('fineemail.com');
        freeEmailDomains.add('finklfan.com');
        freeEmailDomains.add('flashmail.com');
        freeEmailDomains.add('flipcode.com');
        freeEmailDomains.add('floridaemail.net');
        freeEmailDomains.add('flytecrew.com');
        freeEmailDomains.add('fmail.co.uk');
        freeEmailDomains.add('fmgirl.com');
        freeEmailDomains.add('fmguy.com');
        freeEmailDomains.add('fnmail.com');
        freeEmailDomains.add('forfree.at');
        freeEmailDomains.add('fortuncity.com');
        freeEmailDomains.add('forum.dk');
        freeEmailDomains.add('fossefans.com');
        freeEmailDomains.add('francefans.com');
        freeEmailDomains.add('free.fr');
        freeEmailDomains.add('freeaccess.nl');
        freeEmailDomains.add('freefanmail.com');
        freeEmailDomains.add('freegates.be');
        freeEmailDomains.add('freeler.nl');
        freeEmailDomains.add('freemail.bozz.com');
        freeEmailDomains.add('freemail.com.au');
        freeEmailDomains.add('freemail.com.pk');
        freeEmailDomains.add('freemail.de');
        freeEmailDomains.add('freemail.gr');
        freeEmailDomains.add('freemail.hu');
        freeEmailDomains.add('freemail.it');
        freeEmailDomains.add('freemail.lt');
        freeEmailDomains.add('freemail.nl');
        freeEmailDomains.add('freemail.org.mk');
        freeEmailDomains.add('freemail.ru');
        freeEmailDomains.add('freenet.de');
        freeEmailDomains.add('freenet.kg');
        freeEmailDomains.add('freeola.net');
        freeEmailDomains.add('freeproblem.com');
        freeEmailDomains.add('freesbee.fr');
        freeEmailDomains.add('freeserve.co.uk');
        freeEmailDomains.add('freestart.hu');
        freeEmailDomains.add('freesurf.fr');
        freeEmailDomains.add('freesurf.nl');
        freeEmailDomains.add('freeuk.com');
        freeEmailDomains.add('freeuk.net');
        freeEmailDomains.add('freewebemail.com');
        freeEmailDomains.add('freeyellow.com');
        freeEmailDomains.add('fresnomail.com');
        freeEmailDomains.add('friction.net');
        freeEmailDomains.add('friendlydevices.com');
        freeEmailDomains.add('frominter.net');
        freeEmailDomains.add('fromru.com');
        freeEmailDomains.add('fromru.ru');
        freeEmailDomains.add('front.ru');
        freeEmailDomains.add('fsmail.net');
        freeEmailDomains.add('ftml.net');
        freeEmailDomains.add('funiran.com');
        freeEmailDomains.add('fusemail.com');
        freeEmailDomains.add('fut.es');
        freeEmailDomains.add('gamebox.com');
        freeEmailDomains.add('gamebox.net');
        freeEmailDomains.add('gardener.com');
        freeEmailDomains.add('gatwickemail.com');
        freeEmailDomains.add('gawab.com');
        freeEmailDomains.add('gay.com');
        freeEmailDomains.add('gazeta.pl');
        freeEmailDomains.add('gdi.net');
        freeEmailDomains.add('geeklife.com');
        freeEmailDomains.add('genxemail.com');
        freeEmailDomains.add('geologist.com');
        freeEmailDomains.add('geopia.com');
        freeEmailDomains.add('gfxartist.ru');
        freeEmailDomains.add('giga4u.de');
        freeEmailDomains.add('glay.org');
        freeEmailDomains.add('glendale.net');
        freeEmailDomains.add('globalsite.com.br');
        freeEmailDomains.add('globetrotter.net');
        freeEmailDomains.add('gmail.com');
        freeEmailDomains.add('gmx.net');
        freeEmailDomains.add('go.com');
        freeEmailDomains.add('go.ro');
        freeEmailDomains.add('go.ru');
        freeEmailDomains.add('go2net.com');
        freeEmailDomains.add('go4.it');
        freeEmailDomains.add('gofree.co.uk');
        freeEmailDomains.add('goldenmail.ru');
        freeEmailDomains.add('goldmail.ru');
        freeEmailDomains.add('golfemail.com');
        freeEmailDomains.add('gonuts4free.com');
        freeEmailDomains.add('goosemoose.com');
        freeEmailDomains.add('goplay.com');
        freeEmailDomains.add('gotmail.com');
        freeEmailDomains.add('gotomy.com');
        freeEmailDomains.add('graffiti.net');
        freeEmailDomains.add('graphic-designer.com');
        freeEmailDomains.add('gratisweb.com');
        freeEmailDomains.add('grungecafe.com');
        freeEmailDomains.add('guessmail.com');
        freeEmailDomains.add('guju.net');
        freeEmailDomains.add('guy.com');
        freeEmailDomains.add('guyanafriends.com');
        freeEmailDomains.add('gwhsgeckos.com');
        freeEmailDomains.add('gyorsposta.com');
        freeEmailDomains.add('hablas.com');
        freeEmailDomains.add('hailmail.net');
        freeEmailDomains.add('hairdresser.com');
        freeEmailDomains.add('hairdresser.net');
        freeEmailDomains.add('handbag.com');
        freeEmailDomains.add('hangglidemail.com');
        freeEmailDomains.add('happemail.com');
        freeEmailDomains.add('happycounsel.com');
        freeEmailDomains.add('haramamba.ru');
        freeEmailDomains.add('hardyoungbabes.com');
        freeEmailDomains.add('healthemail.net');
        freeEmailDomains.add('heavynoize.net');
        freeEmailDomains.add('heesun.net');
        freeEmailDomains.add('hellokitty.com');
        freeEmailDomains.add('heremail.com');
        freeEmailDomains.add('hewgen.ru');
        freeEmailDomains.add('hideakifan.com');
        freeEmailDomains.add('highquality.com');
        freeEmailDomains.add('hinduhome.com');
        freeEmailDomains.add('hingis.org');
        freeEmailDomains.add('hispavista.com');
        freeEmailDomains.add('hitmanrecords.com');
        freeEmailDomains.add('home.no.net');
        freeEmailDomains.add('home.ro');
        freeEmailDomains.add('home.se');
        freeEmailDomains.add('homelocator.com');
        freeEmailDomains.add('homenetmail.com');
        freeEmailDomains.add('homeonthethrone.com');
        freeEmailDomains.add('homestead.com');
        freeEmailDomains.add('hot-shop.com');
        freeEmailDomains.add('hot-shot.com');
        freeEmailDomains.add('hot.ee');
        freeEmailDomains.add('hotbot.com');
        freeEmailDomains.add('hotbox.ru');
        freeEmailDomains.add('hotcoolmail.com');
        freeEmailDomains.add('hotfire.net');
        freeEmailDomains.add('hotlinemail.com');
        freeEmailDomains.add('hotmail.co.il');
        freeEmailDomains.add('hotmail.com');
        freeEmailDomains.add('hotmail.it');
        freeEmailDomains.add('hotmail.kg');
        freeEmailDomains.add('hotmail.ro');
        freeEmailDomains.add('hotmail.ru');
        freeEmailDomains.add('hotpop.com');
        freeEmailDomains.add('hotpop3.com');
        freeEmailDomains.add('hotvoice.com');
        freeEmailDomains.add('housemail.com');
        freeEmailDomains.add('hsuchi.net');
        freeEmailDomains.add('humanux.com');
        freeEmailDomains.add('humour.com');
        freeEmailDomains.add('hushmail.com');
        freeEmailDomains.add('i-france.com');
        freeEmailDomains.add('i-love-cats.com');
        freeEmailDomains.add('i-mail.com.au');
        freeEmailDomains.add('i-p.com');
        freeEmailDomains.add('i2828.com');
        freeEmailDomains.add('iam4msu.com');
        freeEmailDomains.add('iamfinallyonline.com');
        freeEmailDomains.add('icestorm.com');
        freeEmailDomains.add('icq.com');
        freeEmailDomains.add('icqmail.com');
        freeEmailDomains.add('icrazy.com');
        freeEmailDomains.add('id.ru');
        freeEmailDomains.add('idirect.com');
        freeEmailDomains.add('iespana.es');
        freeEmailDomains.add('ignmail.com');
        freeEmailDomains.add('ilovegiraffes.net');
        freeEmailDomains.add('ilovelionking.com');
        freeEmailDomains.add('ilovepokemonmail.com');
        freeEmailDomains.add('ilovetocollect.net');
        freeEmailDomains.add('imail.ru');
        freeEmailDomains.add('imailbox.com');
        freeEmailDomains.add('imap-mail.com');
        freeEmailDomains.add('imel.org');
        freeEmailDomains.add('in-box.net');
        freeEmailDomains.add('iname.com');
        freeEmailDomains.add('inbox.lv');
        freeEmailDomains.add('inbox.net');
        freeEmailDomains.add('inbox.ru');
        freeEmailDomains.add('incamail.com');
        freeEmailDomains.add('indexa.fr');
        freeEmailDomains.add('india.com');
        freeEmailDomains.add('indus.ru');
        freeEmailDomains.add('infoapex.com');
        freeEmailDomains.add('infohq.com');
        freeEmailDomains.add('infomail.es');
        freeEmailDomains.add('infomart.or.jp');
        freeEmailDomains.add('infovia.com.ar');
        freeEmailDomains.add('inicia.es');
        freeEmailDomains.add('inmail.sk');
        freeEmailDomains.add('inonesearch.com');
        freeEmailDomains.add('inorbit.com');
        freeEmailDomains.add('inspectorjavert.com');
        freeEmailDomains.add('insurer.com');
        freeEmailDomains.add('interfree.it');
        freeEmailDomains.add('interia.pl');
        freeEmailDomains.add('interlap.com.ar');
        freeEmailDomains.add('internet-e-mail.com');
        freeEmailDomains.add('internetbiz.com');
        freeEmailDomains.add('internetegypt.com');
        freeEmailDomains.add('internetmailing.net');
        freeEmailDomains.add('inwind.it');
        freeEmailDomains.add('iobox.com');
        freeEmailDomains.add('iobox.fi');
        freeEmailDomains.add('iol.it');
        freeEmailDomains.add('iol.pt');
        freeEmailDomains.add('ip3.com');
        freeEmailDomains.add('ipex.ru');
        freeEmailDomains.add('iportalexpress.com');
        freeEmailDomains.add('iqemail.com');
        freeEmailDomains.add('irangate.net');
        freeEmailDomains.add('iraqmail.com');
        freeEmailDomains.add('iscooler.com');
        freeEmailDomains.add('islandemail.net');
        freeEmailDomains.add('ismart.net');
        freeEmailDomains.add('isonfire.com');
        freeEmailDomains.add('isp9.net');
        freeEmailDomains.add('itmom.com');
        freeEmailDomains.add('ivillage.com');
        freeEmailDomains.add('iwan-fals.com');
        freeEmailDomains.add('iwon.com');
        freeEmailDomains.add('jabble.com');
        freeEmailDomains.add('japan.com');
        freeEmailDomains.add('jaydemail.com');
        freeEmailDomains.add('jeanvaljean.com');
        freeEmailDomains.add('jesusanswers.com');
        freeEmailDomains.add('jetemail.net');
        freeEmailDomains.add('jfkislanders.com');
        freeEmailDomains.add('jingjo.net');
        freeEmailDomains.add('jippii.fi');
        freeEmailDomains.add('joinme.com');
        freeEmailDomains.add('jojomail.com');
        freeEmailDomains.add('jordanmail.com');
        freeEmailDomains.add('journalist.com');
        freeEmailDomains.add('joymail.com');
        freeEmailDomains.add('jpopmail.com');
        freeEmailDomains.add('jumpy.it');
        freeEmailDomains.add('juniormail.com');
        freeEmailDomains.add('juno.com');
        freeEmailDomains.add('justmail.de');
        freeEmailDomains.add('justmailz.com');
        freeEmailDomains.add('justmarriedmail.com');
        freeEmailDomains.add('k.ro');
        freeEmailDomains.add('kaazoo.com');
        freeEmailDomains.add('kabissa.org');
        freeEmailDomains.add('kaduku.net');
        freeEmailDomains.add('kalpoint.com');
        freeEmailDomains.add('karachioye.com');
        freeEmailDomains.add('katamail.com');
        freeEmailDomains.add('kebi.com');
        freeEmailDomains.add('keko.com.ar');
        freeEmailDomains.add('keptprivate.com');
        freeEmailDomains.add('keromail.com');
        freeEmailDomains.add('kewpee.com');
        freeEmailDomains.add('kichimail.com');
        freeEmailDomains.add('killamail.com');
        freeEmailDomains.add('killergreenmail.com');
        freeEmailDomains.add('kimo.com');
        freeEmailDomains.add('kinki-kids.com');
        freeEmailDomains.add('kitemail.com');
        freeEmailDomains.add('kittymail.com');
        freeEmailDomains.add('kiwibox.com');
        freeEmailDomains.add('kiwitown.com');
        freeEmailDomains.add('km.ru');
        freeEmailDomains.add('koko.com');
        freeEmailDomains.add('konkovo.net');
        freeEmailDomains.add('konsul.ru');
        freeEmailDomains.add('kosino.net');
        freeEmailDomains.add('kreditor.ru');
        freeEmailDomains.add('krovatka.net');
        freeEmailDomains.add('krunis.com');
        freeEmailDomains.add('kukamail.com');
        freeEmailDomains.add('kuwait-mail.com');
        freeEmailDomains.add('kuzminki.net');
        freeEmailDomains.add('kyokodate.com');
        freeEmailDomains.add('kyokofukada.net');
        freeEmailDomains.add('ladyfire.com');
        freeEmailDomains.add('ladymail.cz');
        freeEmailDomains.add('lahoreoye.com');
        freeEmailDomains.add('lakmail.com');
        freeEmailDomains.add('land.ru');
        freeEmailDomains.add('langoo.com');
        freeEmailDomains.add('lankamail.com');
        freeEmailDomains.add('laposte.net');
        freeEmailDomains.add('latinmail.com');
        freeEmailDomains.add('lawyer.com');
        freeEmailDomains.add('learn2compute.net');
        freeEmailDomains.add('lebanonatlas.com');
        freeEmailDomains.add('leehom.net');
        freeEmailDomains.add('lefortovo.net');
        freeEmailDomains.add('legislator.com');
        freeEmailDomains.add('legistrator.com');
        freeEmailDomains.add('lenta.ru');
        freeEmailDomains.add('leonlai.net');
        freeEmailDomains.add('levele.com');
        freeEmailDomains.add('lianozovo.net');
        freeEmailDomains.add('liberomail.com');
        freeEmailDomains.add('linkmaster.com');
        freeEmailDomains.add('linuxfreemail.com');
        freeEmailDomains.add('linuxmail.org');
        freeEmailDomains.add('lionsfan.com.au');
        freeEmailDomains.add('lissamail.com');
        freeEmailDomains.add('list.ru');
        freeEmailDomains.add('literaturelover.com');
        freeEmailDomains.add('ljiljan.com');
        freeEmailDomains.add('llandudno.com');
        freeEmailDomains.add('llangollen.com');
        freeEmailDomains.add('lobbyist.com');
        freeEmailDomains.add('localgenius.com');
        freeEmailDomains.add('lolnetwork.net');
        freeEmailDomains.add('london.com');
        freeEmailDomains.add('looksmart.co.uk');
        freeEmailDomains.add('looksmart.com');
        freeEmailDomains.add('looksmart.com.au');
        freeEmailDomains.add('lopezclub.com');
        freeEmailDomains.add('louiskoo.com');
        freeEmailDomains.add('lov.ru');
        freeEmailDomains.add('loveable.com');
        freeEmailDomains.add('lovecat.com');
        freeEmailDomains.add('loveforlostcats.com');
        freeEmailDomains.add('lovemail.com');
        freeEmailDomains.add('lovetocook.net');
        freeEmailDomains.add('lovetohike.com');
        freeEmailDomains.add('lovingjesus.com');
        freeEmailDomains.add('lubovnik.ru');
        freeEmailDomains.add('luso.pt');
        freeEmailDomains.add('luukku.com');
        freeEmailDomains.add('luvrhino.com');
        freeEmailDomains.add('lvwebmail.com');
        freeEmailDomains.add('lycos.co.uk');
        freeEmailDomains.add('lycos.com');
        freeEmailDomains.add('lycos.it');
        freeEmailDomains.add('lycos.ne.jp');
        freeEmailDomains.add('lycos.ru');
        freeEmailDomains.add('lycosmail.com');
        freeEmailDomains.add('mac.com');
        freeEmailDomains.add('macbox.ru');
        freeEmailDomains.add('machinecandy.com');
        freeEmailDomains.add('macmail.com');
        freeEmailDomains.add('mad.scientist.com');
        freeEmailDomains.add('madcrazy.com');
        freeEmailDomains.add('madrid.com');
        freeEmailDomains.add('magicmail.co.za');
        freeEmailDomains.add('mail-box.cz');
        freeEmailDomains.add('mail-center.com');
        freeEmailDomains.add('mail.az');
        freeEmailDomains.add('mail.co.za');
        freeEmailDomains.add('mail.com');
        freeEmailDomains.add('mail.ee');
        freeEmailDomains.add('mail.gr');
        freeEmailDomains.add('mail.md');
        freeEmailDomains.add('mail.pf');
        freeEmailDomains.add('mail.pt');
        freeEmailDomains.add('mail.ru');
        freeEmailDomains.add('mail.vu');
        freeEmailDomains.add('mail2k.ru');
        freeEmailDomains.add('mail2world.com');
        freeEmailDomains.add('mail3000.com');
        freeEmailDomains.add('mail333.com');
        freeEmailDomains.add('mail8.com');
        freeEmailDomains.add('mailandnews.com');
        freeEmailDomains.add('mailasia.com');
        freeEmailDomains.add('mailblocks.com');
        freeEmailDomains.add('mailbolt.com');
        freeEmailDomains.add('mailbox.as');
        freeEmailDomains.add('mailbox.gr');
        freeEmailDomains.add('mailbox.hu');
        freeEmailDomains.add('mailbr.com.br');
        freeEmailDomains.add('mailchoose.co');
        freeEmailDomains.add('mailcity.com');
        freeEmailDomains.add('mailclub.fr');
        freeEmailDomains.add('mailclub.net');
        freeEmailDomains.add('mailexcite.com');
        freeEmailDomains.add('mailfly.com');
        freeEmailDomains.add('mailfreeway.com');
        freeEmailDomains.add('mailgate.ru');
        freeEmailDomains.add('mailgenie.net');
        freeEmailDomains.add('mailhood.com');
        freeEmailDomains.add('mailingweb.com');
        freeEmailDomains.add('mailisent.com');
        freeEmailDomains.add('mailite.com');
        freeEmailDomains.add('mailme.dk');
        freeEmailDomains.add('mailmight.com');
        freeEmailDomains.add('mailmij.nl');
        freeEmailDomains.add('mailops.com');
        freeEmailDomains.add('mailoye.com');
        freeEmailDomains.add('mailpanda.com');
        freeEmailDomains.add('mailpride.com');
        freeEmailDomains.add('mailpuppy.com');
        freeEmailDomains.add('mailroom.com');
        freeEmailDomains.add('mailru.com');
        freeEmailDomains.add('mailserver.ru');
        freeEmailDomains.add('mailsnare.net');
        freeEmailDomains.add('mailsurf.com');
        freeEmailDomains.add('mailworks.org');
        freeEmailDomains.add('maktoob.com');
        freeEmailDomains.add('malayalamtelevision.net');
        freeEmailDomains.add('malayalapathram.com');
        freeEmailDomains.add('male.ru');
        freeEmailDomains.add('manager.de');
        freeEmailDomains.add('manlymail.net');
        freeEmailDomains.add('mantrafreenet.com');
        freeEmailDomains.add('mantramail.com');
        freeEmailDomains.add('mantraonline.com');
        freeEmailDomains.add('manutdfans.com');
        freeEmailDomains.add('marchmail.com');
        freeEmailDomains.add('marfino.net');
        freeEmailDomains.add('margarita.ru');
        freeEmailDomains.add('marijuana.nl');
        freeEmailDomains.add('marketingfanatic.com');
        freeEmailDomains.add('marketweighton.com');
        freeEmailDomains.add('marriedandlovingit.com');
        freeEmailDomains.add('marry.ru');
        freeEmailDomains.add('martinguerre.net');
        freeEmailDomains.add('masrawy.com');
        freeEmailDomains.add('mauimail.com');
        freeEmailDomains.add('maximumedge.com');
        freeEmailDomains.add('maxleft.com');
        freeEmailDomains.add('mayaple.ru');
        freeEmailDomains.add('mcrmail.com');
        freeEmailDomains.add('meanpeoplesuck.com');
        freeEmailDomains.add('meatismurder.net');
        freeEmailDomains.add('meetingmall.com');
        freeEmailDomains.add('megago.com');
        freeEmailDomains.add('megamail.pt');
        freeEmailDomains.add('melodymail.com');
        freeEmailDomains.add('meloo.com');
        freeEmailDomains.add('menja.net');
        freeEmailDomains.add('merseymail.com');
        freeEmailDomains.add('mesra.net');
        freeEmailDomains.add('messagez.com');
        freeEmailDomains.add('metacrawler.com');
        freeEmailDomains.add('miesto.sk');
        freeEmailDomains.add('milmail.com');
        freeEmailDomains.add('mindless.com');
        freeEmailDomains.add('minermail.com');
        freeEmailDomains.add('minister.com');
        freeEmailDomains.add('misery.net');
        freeEmailDomains.add('mixmail.com');
        freeEmailDomains.add('ml1.net');
        freeEmailDomains.add('mlanime.com');
        freeEmailDomains.add('mmail.com');
        freeEmailDomains.add('mo3gov.net');
        freeEmailDomains.add('mobico.ru');
        freeEmailDomains.add('modemnet.net');
        freeEmailDomains.add('modernenglish.com');
        freeEmailDomains.add('modomail.com');
        freeEmailDomains.add('moldova.com');
        freeEmailDomains.add('moldovacc.com');
        freeEmailDomains.add('mom-mail.com');
        freeEmailDomains.add('monsieurcinema.com');
        freeEmailDomains.add('montevideo.com.uy');
        freeEmailDomains.add('moomia.com');
        freeEmailDomains.add('moose-mail.com');
        freeEmailDomains.add('mosaicfx.com');
        freeEmailDomains.add('moscowmail.com');
        freeEmailDomains.add('mosk.ru');
        freeEmailDomains.add('motorcyclefan.net');
        freeEmailDomains.add('motormania.com');
        freeEmailDomains.add('movemail.com');
        freeEmailDomains.add('movieemail.net');
        freeEmailDomains.add('mozartmail.com');
        freeEmailDomains.add('mozhno.net');
        freeEmailDomains.add('mp3haze.com');
        freeEmailDomains.add('mrspender.com');
        freeEmailDomains.add('msgbox.com');
        freeEmailDomains.add('msx.ru');
        freeEmailDomains.add('mundomail.net');
        freeEmailDomains.add('munich.com');
        freeEmailDomains.add('music.maigate.ru');
        freeEmailDomains.add('musician.com');
        freeEmailDomains.add('musician.org');
        freeEmailDomains.add('mycabin.com');
        freeEmailDomains.add('mycool.com');
        freeEmailDomains.add('mydomain.com');
        freeEmailDomains.add('myfunnymail.com');
        freeEmailDomains.add('myiris.com');
        freeEmailDomains.add('myjazzmail.com');
        freeEmailDomains.add('mymac.ru');
        freeEmailDomains.add('mymail.ro');
        freeEmailDomains.add('mynamedot.com');
        freeEmailDomains.add('myotw.net');
        freeEmailDomains.add('mypersonalemail.com');
        freeEmailDomains.add('myplace.com');
        freeEmailDomains.add('myrealbox.com');
        freeEmailDomains.add('myself.com');
        freeEmailDomains.add('myway.com');
        freeEmailDomains.add('myworldmail.com');
        freeEmailDomains.add('n2.com');
        freeEmailDomains.add('n2business.com');
        freeEmailDomains.add('n2mail.com');
        freeEmailDomains.add('n2software.com');
        freeEmailDomains.add('nagarealm.com');
        freeEmailDomains.add('name.com');
        freeEmailDomains.add('nameplanet.com');
        freeEmailDomains.add('nanaseaikawa.com');
        freeEmailDomains.add('nandomail.com');
        freeEmailDomains.add('naseej.com');
        freeEmailDomains.add('nativestar.net');
        freeEmailDomains.add('nativeweb.net');
        freeEmailDomains.add('nc.ru');
        freeEmailDomains.add('nekto.com');
        freeEmailDomains.add('nekto.net');
        freeEmailDomains.add('nekto.ru');
        freeEmailDomains.add('nemra1.com');
        freeEmailDomains.add('nenter.com');
        freeEmailDomains.add('nervhq.org');
        freeEmailDomains.add('net4b.pt');
        freeEmailDomains.add('net4you.at');
        freeEmailDomains.add('netaddres.ru');
        freeEmailDomains.add('netaddress.ru');
        freeEmailDomains.add('netbounce.com');
        freeEmailDomains.add('netbroadcaster.com');
        freeEmailDomains.add('netcity.ru');
        freeEmailDomains.add('netcourrier.com');
        freeEmailDomains.add('netfirms.com');
        freeEmailDomains.add('netizen.com.ar');
        freeEmailDomains.add('netkushi.com');
        freeEmailDomains.add('netmail.kg');
        freeEmailDomains.add('netman.ru');
        freeEmailDomains.add('netmongol.com');
        freeEmailDomains.add('netpiper.com');
        freeEmailDomains.add('netposta.net');
        freeEmailDomains.add('netscape.net');
        freeEmailDomains.add('netscapeonline.co.uk');
        freeEmailDomains.add('netsquare.com');
        freeEmailDomains.add('nettaxi.com');
        freeEmailDomains.add('netzero.com');
        freeEmailDomains.add('netzoola.com');
        freeEmailDomains.add('neustreet.com');
        freeEmailDomains.add('newap.ru');
        freeEmailDomains.add('newarbat.net');
        freeEmailDomains.add('newmail.com');
        freeEmailDomains.add('newmail.net');
        freeEmailDomains.add('newmail.ru');
        freeEmailDomains.add('newyork.com');
        freeEmailDomains.add('newyorkcity.com');
        freeEmailDomains.add('nfmail.com');
        freeEmailDomains.add('ngs.ru');
        freeEmailDomains.add('nicegal.com');
        freeEmailDomains.add('nicholastse.net');
        freeEmailDomains.add('nicolastse.com');
        freeEmailDomains.add('nightimeuk.com');
        freeEmailDomains.add('nightmail.com');
        freeEmailDomains.add('nightmail.ru');
        freeEmailDomains.add('nikulino.net');
        freeEmailDomains.add('nm.ru');
        freeEmailDomains.add('nnov.ru');
        freeEmailDomains.add('no4ma.ru');
        freeEmailDomains.add('noavar.com');
        freeEmailDomains.add('nonstopcinema.com');
        freeEmailDomains.add('norikomail.com');
        freeEmailDomains.add('nospammail.net');
        freeEmailDomains.add('notyouagain.com');
        freeEmailDomains.add('novogireevo.net');
        freeEmailDomains.add('novokosino.net');
        freeEmailDomains.add('numep.ru');
        freeEmailDomains.add('nuvse.com');
        freeEmailDomains.add('ny.com');
        freeEmailDomains.add('nybce.com');
        freeEmailDomains.add('nyc.com');
        freeEmailDomains.add('nycmail.com');
        freeEmailDomains.add('nz11.com');
        freeEmailDomains.add('nzoomail.com');
        freeEmailDomains.add('o2.pl');
        freeEmailDomains.add('oceanfree.net');
        freeEmailDomains.add('ochakovo.net');
        freeEmailDomains.add('oddpost.com');
        freeEmailDomains.add('odmail.com');
        freeEmailDomains.add('oicexchange.com');
        freeEmailDomains.add('ok.kz');
        freeEmailDomains.add('ok.ru');
        freeEmailDomains.add('oldbuthealthy.com');
        freeEmailDomains.add('ole.com');
        freeEmailDomains.add('olemail.com');
        freeEmailDomains.add('oligarh.ru');
        freeEmailDomains.add('olympist.net');
        freeEmailDomains.add('omaninfo.com');
        freeEmailDomains.add('omen.ru');
        freeEmailDomains.add('ondikoi.com');
        freeEmailDomains.add('onebox.com');
        freeEmailDomains.add('onenet.com.ar');
        freeEmailDomains.add('onet.pl');
        freeEmailDomains.add('oninet.pt');
        freeEmailDomains.add('online.ie');
        freeEmailDomains.add('online.ru');
        freeEmailDomains.add('onlinecasinogamblings.com');
        freeEmailDomains.add('onlinewiz.com');
        freeEmailDomains.add('onobox.com');
        freeEmailDomains.add('opendiary.com');
        freeEmailDomains.add('operamail.com');
        freeEmailDomains.add('optician.com');
        freeEmailDomains.add('orbitel.bg');
        freeEmailDomains.add('orgmail.net');
        freeEmailDomains.add('osite.com.br');
        freeEmailDomains.add('oso.com');
        freeEmailDomains.add('otakumail.com');
        freeEmailDomains.add('ournet.md');
        freeEmailDomains.add('outgun.com');
        freeEmailDomains.add('ozz.ru');
        freeEmailDomains.add('paidforsurf.com');
        freeEmailDomains.add('pakistanoye.com');
        freeEmailDomains.add('palestinemail.com');
        freeEmailDomains.add('pandawa.com');
        freeEmailDomains.add('pandora.be');
        freeEmailDomains.add('paradiseemail.com');
        freeEmailDomains.add('paris.com');
        freeEmailDomains.add('pathfindermail.com');
        freeEmailDomains.add('patmail.com');
        freeEmailDomains.add('patra.net');
        freeEmailDomains.add('pechkin.ru');
        freeEmailDomains.add('pediatrician.com');
        freeEmailDomains.add('pekklemail.com');
        freeEmailDomains.add('penpen.com');
        freeEmailDomains.add('peopleweb.com');
        freeEmailDomains.add('perfectmail.com');
        freeEmailDomains.add('perovo.net');
        freeEmailDomains.add('personal.ro');
        freeEmailDomains.add('personales.com');
        freeEmailDomains.add('petr.ru');
        freeEmailDomains.add('phreaker.net');
        freeEmailDomains.add('piercedallover.com');
        freeEmailDomains.add('pigeonportal.com');
        freeEmailDomains.add('pigmail.net');
        freeEmailDomains.add('pigpig.net');
        freeEmailDomains.add('pilotemail.com');
        freeEmailDomains.add('pimagop.com');
        freeEmailDomains.add('pinoymail.com');
        freeEmailDomains.add('pisem.net');
        freeEmailDomains.add('planetaccess.com');
        freeEmailDomains.add('planetout.com');
        freeEmailDomains.add('plasa.com');
        freeEmailDomains.add('playersodds.com');
        freeEmailDomains.add('playful.com');
        freeEmailDomains.add('pluno.com');
        freeEmailDomains.add('plusmail.com.br');
        freeEmailDomains.add('pmail.net');
        freeEmailDomains.add('pobox.ru');
        freeEmailDomains.add('pobox.sk');
        freeEmailDomains.add('pochta.by');
        freeEmailDomains.add('pochta.ws');
        freeEmailDomains.add('pochtamt.ru');
        freeEmailDomains.add('poczta.fm');
        freeEmailDomains.add('poetic.com');
        freeEmailDomains.add('polbox.com');
        freeEmailDomains.add('poohfan.com');
        freeEmailDomains.add('pop3.ru');
        freeEmailDomains.add('popaccount.com');
        freeEmailDomains.add('popmail.com');
        freeEmailDomains.add('popsmail.com');
        freeEmailDomains.add('popstar.com');
        freeEmailDomains.add('portugalmail.com');
        freeEmailDomains.add('portugalnet.com');
        freeEmailDomains.add('post.com');
        freeEmailDomains.add('post.cz');
        freeEmailDomains.add('post.sk');
        freeEmailDomains.add('postino.ch');
        freeEmailDomains.add('postino.it');
        freeEmailDomains.add('postmaster.co.uk');
        freeEmailDomains.add('powerdivas.com');
        freeEmailDomains.add('powerfan.com');
        freeEmailDomains.add('praize.com');
        freeEmailDomains.add('predprinimatel.ru');
        freeEmailDomains.add('premiumproducts.com');
        freeEmailDomains.add('premiumservice.com');
        freeEmailDomains.add('prepodavatel.ru');
        freeEmailDomains.add('presidency.com');
        freeEmailDomains.add('presnya.net');
        freeEmailDomains.add('press.co.jp');
        freeEmailDomains.add('prettierthanher.com');
        freeEmailDomains.add('priest.com');
        freeEmailDomains.add('primposta.com');
        freeEmailDomains.add('printesamargareta.ro');
        freeEmailDomains.add('professor.ru');
        freeEmailDomains.add('programist.ru');
        freeEmailDomains.add('programmer.net');
        freeEmailDomains.add('prokuratura.ru');
        freeEmailDomains.add('promessage.com');
        freeEmailDomains.add('prontomail.com');
        freeEmailDomains.add('publicist.com');
        freeEmailDomains.add('punkass.com');
        freeEmailDomains.add('puppy.com.my');
        freeEmailDomains.add('purinmail.com');
        freeEmailDomains.add('qatarmail.com');
        freeEmailDomains.add('qdice.com');
        freeEmailDomains.add('qrio.com');
        freeEmailDomains.add('quake.ru');
        freeEmailDomains.add('qudsmail.com');
        freeEmailDomains.add('quepasa.com');
        freeEmailDomains.add('quickmail.ru');
        freeEmailDomains.add('quickwebmail.com');
        freeEmailDomains.add('r-o-o-t.com');
        freeEmailDomains.add('raakim.com');
        freeEmailDomains.add('racingfan.com.au');
        freeEmailDomains.add('radicalz.com');
        freeEmailDomains.add('ragingbull.com');
        freeEmailDomains.add('rambler.ru');
        freeEmailDomains.add('ranmamail.com');
        freeEmailDomains.add('ravearena.com');
        freeEmailDomains.add('ravefan.com');
        freeEmailDomains.add('ravemail.co.za');
        freeEmailDomains.add('razormail.com');
        freeEmailDomains.add('realestatemail.net');
        freeEmailDomains.add('realtyagent.com');
        freeEmailDomains.add('recycledmail.com');
        freeEmailDomains.add('rediffmail.com');
        freeEmailDomains.add('rediffmailpro.com');
        freeEmailDomains.add('redseven.de');
        freeEmailDomains.add('redwhitearmy.com');
        freeEmailDomains.add('registerednurses.com');
        freeEmailDomains.add('relia.com');
        freeEmailDomains.add('repairman.com');
        freeEmailDomains.add('represantive.com');
        freeEmailDomains.add('representative.com');
        freeEmailDomains.add('rescueteam.com');
        freeEmailDomains.add('retailfan.com');
        freeEmailDomains.add('rexian.com');
        freeEmailDomains.add('rickymail.com');
        freeEmailDomains.add('ring.by');
        freeEmailDomains.add('rn.com');
        freeEmailDomains.add('roanokemail.com');
        freeEmailDomains.add('rock.com');
        freeEmailDomains.add('rocketmail.com');
        freeEmailDomains.add('rojname.com');
        freeEmailDomains.add('rol.ro');
        freeEmailDomains.add('rome.com');
        freeEmailDomains.add('romymichele.com');
        freeEmailDomains.add('rpharmacist.com');
        freeEmailDomains.add('rt.nl');
        freeEmailDomains.add('ru.ru');
        freeEmailDomains.add('runbox.com');
        freeEmailDomains.add('rushpost.com');
        freeEmailDomains.add('s-mail.com');
        freeEmailDomains.add('sacbeemail.com');
        freeEmailDomains.add('safe-mail.net');
        freeEmailDomains.add('sailormoon.com');
        freeEmailDomains.add('saint-mike.org');
        freeEmailDomains.add('saintly.com');
        freeEmailDomains.add('samerica.com');
        freeEmailDomains.add('samilan.net');
        freeEmailDomains.add('samiznaetekogo.net');
        freeEmailDomains.add('sammimail.com');
        freeEmailDomains.add('sanchezsharks.com');
        freeEmailDomains.add('sanfranmail.com');
        freeEmailDomains.add('sanriotown.com');
        freeEmailDomains.add('santanmail.com');
        freeEmailDomains.add('saturnfans.com');
        freeEmailDomains.add('saturnperformance.com');
        freeEmailDomains.add('saudia.com');
        freeEmailDomains.add('savecougars.com');
        freeEmailDomains.add('saveowls.com');
        freeEmailDomains.add('sayhi.net');
        freeEmailDomains.add('scfn.net');
        freeEmailDomains.add('schweiz.org');
        freeEmailDomains.add('sci.fi');
        freeEmailDomains.add('scientist.com');
        freeEmailDomains.add('scottishmail.co.uk');
        freeEmailDomains.add('scottishtories.com');
        freeEmailDomains.add('scrapbookscrapbook.com');
        freeEmailDomains.add('search417.com');
        freeEmailDomains.add('sebil.com');
        freeEmailDomains.add('seckinmail.com');
        freeEmailDomains.add('secretservices.net');
        freeEmailDomains.add('seductive.com');
        freeEmailDomains.add('sekomaonline.com');
        freeEmailDomains.add('sellingspree.com');
        freeEmailDomains.add('sendmail.ru');
        freeEmailDomains.add('sendme.cz');
        freeEmailDomains.add('serga.com.ar');
        freeEmailDomains.add('servemymail.com');
        freeEmailDomains.add('sesmail.com');
        freeEmailDomains.add('sexmagnet.com');
        freeEmailDomains.add('seznam.cz');
        freeEmailDomains.add('shaniastuff.com');
        freeEmailDomains.add('shellov.net');
        freeEmailDomains.add('shootmail.com');
        freeEmailDomains.add('showfans.com');
        freeEmailDomains.add('shuf.com');
        freeEmailDomains.add('sify.com');
        freeEmailDomains.add('sigaret.net');
        freeEmailDomains.add('simbamail.fm');
        freeEmailDomains.add('sinamail.com');
        freeEmailDomains.add('singapore.com');
        freeEmailDomains.add('singmail.com');
        freeEmailDomains.add('singnet.com.sg');
        freeEmailDomains.add('sirindia.com');
        freeEmailDomains.add('skim.com');
        freeEmailDomains.add('skunkbox.com');
        freeEmailDomains.add('slamdunkfan.com');
        freeEmailDomains.add('slickriffs.co.uk');
        freeEmailDomains.add('slingshot.com');
        freeEmailDomains.add('slo.net');
        freeEmailDomains.add('smapxsmap.net');
        freeEmailDomains.add('sminkymail.com');
        freeEmailDomains.add('smtp.ru');
        freeEmailDomains.add('snail-mail.net');
        freeEmailDomains.add('sndt.net');
        freeEmailDomains.add('sneakemail.com');
        freeEmailDomains.add('snoopymail.com');
        freeEmailDomains.add('snowboarding.com');
        freeEmailDomains.add('so-simple.org');
        freeEmailDomains.add('socamail.com');
        freeEmailDomains.add('socceraccess.com');
        freeEmailDomains.add('sociologist.com');
        freeEmailDomains.add('softhome.net');
        freeEmailDomains.add('sokolniki.net');
        freeEmailDomains.add('sol.dk');
        freeEmailDomains.add('soon.com');
        freeEmailDomains.add('soulfoodcookbook.com');
        freeEmailDomains.add('soundofmusicfans.com');
        freeEmailDomains.add('southparkmail.com');
        freeEmailDomains.add('sovsem.net');
        freeEmailDomains.add('sp.nl');
        freeEmailDomains.add('space.com');
        freeEmailDomains.add('spacetowns.com');
        freeEmailDomains.add('spamex.com');
        freeEmailDomains.add('spankthedonkey.com');
        freeEmailDomains.add('spartapiet.com');
        freeEmailDomains.add('spazmail.com');
        freeEmailDomains.add('spils.com');
        freeEmailDomains.add('spinfinder.com');
        freeEmailDomains.add('spiritseekers.com');
        freeEmailDomains.add('sportemail.com');
        freeEmailDomains.add('sportmail.ru');
        freeEmailDomains.add('spray.no');
        freeEmailDomains.add('spray.se');
        freeEmailDomains.add('srilankan.net');
        freeEmailDomains.add('stade.fr');
        freeEmailDomains.add('stalag13.com');
        freeEmailDomains.add('standalone.net');
        freeEmailDomains.add('starbuzz.com');
        freeEmailDomains.add('starmail.org');
        freeEmailDomains.add('starmedia.com');
        freeEmailDomains.add('starspath.com');
        freeEmailDomains.add('start.com.au');
        freeEmailDomains.add('starwars-fans.com');
        freeEmailDomains.add('stillchronic.com');
        freeEmailDomains.add('stockstorm.com');
        freeEmailDomains.add('stribmail.com');
        freeEmailDomains.add('sudanmail.net');
        freeEmailDomains.add('sueddeutsche.de');
        freeEmailDomains.add('suisse.org');
        freeEmailDomains.add('sunmail1.com');
        freeEmailDomains.add('sunpoint.net');
        freeEmailDomains.add('supermail.ru');
        freeEmailDomains.add('superman.ru');
        freeEmailDomains.add('surf3.net');
        freeEmailDomains.add('surfsupnet.net');
        freeEmailDomains.add('surfy.net');
        freeEmailDomains.add('surimail.com');
        freeEmailDomains.add('survivormail.com');
        freeEmailDomains.add('sviblovo.net');
        freeEmailDomains.add('sweb.cz');
        freeEmailDomains.add('swiftdesk.com');
        freeEmailDomains.add('swirve.com');
        freeEmailDomains.add('swissinfo.org');
        freeEmailDomains.add('swissmail.net');
        freeEmailDomains.add('switchboardmail.com');
        freeEmailDomains.add('switzerland.org');
        freeEmailDomains.add('syriamail.com');
        freeEmailDomains.add('t2mail.com');
        freeEmailDomains.add('table of free mail providers used in spam');
        freeEmailDomains.add('takoe.com');
        freeEmailDomains.add('takoe.net');
        freeEmailDomains.add('talk21.com');
        freeEmailDomains.add('talkcity.com');
        freeEmailDomains.add('tamb.ru');
        freeEmailDomains.add('tangmonkey.com');
        freeEmailDomains.add('taotaotano.com');
        freeEmailDomains.add('tatanova.com');
        freeEmailDomains.add('tattooedallover.com');
        freeEmailDomains.add('tattoofanatic.com');
        freeEmailDomains.add('teacher.com');
        freeEmailDomains.add('techemail.com');
        freeEmailDomains.add('techie.com');
        freeEmailDomains.add('technologist.com');
        freeEmailDomains.add('technologyandstocks.com');
        freeEmailDomains.add('techsniper.com');
        freeEmailDomains.add('telebot.com');
        freeEmailDomains.add('teleline.es');
        freeEmailDomains.add('telinco.net');
        freeEmailDomains.add('telpage.net');
        freeEmailDomains.add('tenchiclub.com');
        freeEmailDomains.add('terra.cl');
        freeEmailDomains.add('terra.com');
        freeEmailDomains.add('terra.com.ar');
        freeEmailDomains.add('terra.com.br');
        freeEmailDomains.add('terra.es');
        freeEmailDomains.add('tfz.net');
        freeEmailDomains.add('tgasa.ru');
        freeEmailDomains.add('tgma.ru');
        freeEmailDomains.add('tgngu.ru');
        freeEmailDomains.add('tgu.ru');
        freeEmailDomains.add('thai.com');
        freeEmailDomains.add('thaimail.com');
        freeEmailDomains.add('thaimail.net');
        freeEmailDomains.add('the-fastest.net');
        freeEmailDomains.add('the-professional.com');
        freeEmailDomains.add('the-quickest.com');
        freeEmailDomains.add('the-seasiders.com');
        freeEmailDomains.add('the-wild-west.com');
        freeEmailDomains.add('thedoghousemail.com');
        freeEmailDomains.add('theheadoffice.com');
        freeEmailDomains.add('theinternetemail.com');
        freeEmailDomains.add('theoffice.net');
        freeEmailDomains.add('thepostmaster.net');
        freeEmailDomains.add('theracetrack.com');
        freeEmailDomains.add('thereisnogod.com');
        freeEmailDomains.add('thesimpsonsfans.com');
        freeEmailDomains.add('thewatercooler.com');
        freeEmailDomains.add('thewebpros.co.uk');
        freeEmailDomains.add('thirdage.com');
        freeEmailDomains.add('thundermail.com');
        freeEmailDomains.add('tibetemail.com');
        freeEmailDomains.add('timormail.com');
        freeEmailDomains.add('tipsandadvice.com');
        freeEmailDomains.add('tiran.ru');
        freeEmailDomains.add('tiscali.co.uk');
        freeEmailDomains.add('tiscali.it');
        freeEmailDomains.add('tiscali.se');
        freeEmailDomains.add('tkcity.com');
        freeEmailDomains.add('tlcfan.com');
        freeEmailDomains.add('tmicha.net');
        freeEmailDomains.add('tokyo.com');
        freeEmailDomains.add('topchat.com');
        freeEmailDomains.add('topmail.com.ar');
        freeEmailDomains.add('topsurf.com');
        freeEmailDomains.add('toquedequeda.com');
        freeEmailDomains.add('torba.com');
        freeEmailDomains.add('torchmail.com');
        freeEmailDomains.add('totalmail.com');
        freeEmailDomains.add('totalsurf.com');
        freeEmailDomains.add('toughguy.net');
        freeEmailDomains.add('trainspottingfan.com');
        freeEmailDomains.add('trevas.net');
        freeEmailDomains.add('trjam.net');
        freeEmailDomains.add('truckeremail.net');
        freeEmailDomains.add('tulipsmail.net');
        freeEmailDomains.add('tunisiamail.com');
        freeEmailDomains.add('turkey.com');
        freeEmailDomains.add('tushino.net');
        freeEmailDomains.add('tut.by');
        freeEmailDomains.add('tverskie.net');
        freeEmailDomains.add('tverskoe.net');
        freeEmailDomains.add('tvnet.lv');
        freeEmailDomains.add('twentylove.com');
        freeEmailDomains.add('twinstarsmail.com');
        freeEmailDomains.add('tycoonmail.com');
        freeEmailDomains.add('typemail.com');
        freeEmailDomains.add('tyt.by');
        freeEmailDomains.add('u2club.com');
        freeEmailDomains.add('ua.fm');
        freeEmailDomains.add('uae.ac');
        freeEmailDomains.add('uaemail.com');
        freeEmailDomains.add('ubbi.com');
        freeEmailDomains.add('uboot.com');
        freeEmailDomains.add('uk2.net');
        freeEmailDomains.add('uk2net.com');
        freeEmailDomains.add('ukr.net');
        freeEmailDomains.add('ukrpost.net');
        freeEmailDomains.add('ukrtop.com');
        freeEmailDomains.add('ultimatelimos.com');
        freeEmailDomains.add('ultrapostman.com');
        freeEmailDomains.add('umpire.com');
        freeEmailDomains.add('unbounded.com');
        freeEmailDomains.add('underwriters.com');
        freeEmailDomains.add('uni.de');
        freeEmailDomains.add('unican.es');
        freeEmailDomains.add('uogtritons.com');
        freeEmailDomains.add('uol.com.ar');
        freeEmailDomains.add('uol.com.br');
        freeEmailDomains.add('uol.com.co');
        freeEmailDomains.add('uol.com.mx');
        freeEmailDomains.add('uol.com.ve');
        freeEmailDomains.add('uole.com');
        freeEmailDomains.add('uole.com.ve');
        freeEmailDomains.add('uolmail.com');
        freeEmailDomains.add('uomail.com');
        freeEmailDomains.add('uraniomail.com');
        freeEmailDomains.add('ureach.com');
        freeEmailDomains.add('usa.com');
        freeEmailDomains.add('usanetmail.com');
        freeEmailDomains.add('userbeam.com');
        freeEmailDomains.add('userzap.com');
        freeEmailDomains.add('uymail.com');
        freeEmailDomains.add('uyuyuy.com');
        freeEmailDomains.add('uzhe.net');
        freeEmailDomains.add('v-sexi.com');
        freeEmailDomains.add('v8email.com');
        freeEmailDomains.add('valudeal.net');
        freeEmailDomains.add('velnet.com');
        freeEmailDomains.add('verizonmail.com');
        freeEmailDomains.add('verticalheaven.com');
        freeEmailDomains.add('vip.gr');
        freeEmailDomains.add('vipmail.ru');
        freeEmailDomains.add('virgilio.it');
        freeEmailDomains.add('virgin.net');
        freeEmailDomains.add('virtual-mail.com');
        freeEmailDomains.add('virtualguam.com');
        freeEmailDomains.add('virtualmail.com');
        freeEmailDomains.add('visitmail.com');
        freeEmailDomains.add('visto.com');
        freeEmailDomains.add('viwanet.ru');
        freeEmailDomains.add('vjtimail.com');
        freeEmailDomains.add('vlcity.ru');
        freeEmailDomains.add('vnn.vn');
        freeEmailDomains.add('vnukovo.net');
        freeEmailDomains.add('voila.fr');
        freeEmailDomains.add('volcanomail.com');
        freeEmailDomains.add('vovan.ru');
        freeEmailDomains.add('vyhino.net');
        freeEmailDomains.add('wahoye.com');
        freeEmailDomains.add('wales2000.net');
        freeEmailDomains.add('wam.co.za');
        freeEmailDomains.add('wanaboo.com');
        freeEmailDomains.add('wapda.com');
        freeEmailDomains.add('warmmail.com');
        freeEmailDomains.add('watchmail.com');
        freeEmailDomains.add('waumail.com');
        freeEmailDomains.add('wearab.net');
        freeEmailDomains.add('web-mail.com.ar');
        freeEmailDomains.add('web.de');
        freeEmailDomains.add('webaddressbook.com');
        freeEmailDomains.add('webbworks.com');
        freeEmailDomains.add('webcity.ca');
        freeEmailDomains.add('webdream.com');
        freeEmailDomains.add('webemaillist.com');
        freeEmailDomains.add('webindia123.com');
        freeEmailDomains.add('webjump.com');
        freeEmailDomains.add('webmail.co.yu');
        freeEmailDomains.add('webmail.co.za');
        freeEmailDomains.add('webmail.ru');
        freeEmailDomains.add('webmails.com');
        freeEmailDomains.add('webmailv.com');
        freeEmailDomains.add('webskulker.com');
        freeEmailDomains.add('webstation.com');
        freeEmailDomains.add('websurfer.co.za');
        freeEmailDomains.add('webtopmail.com');
        freeEmailDomains.add('webtribe.net');
        freeEmailDomains.add('weedmail.com');
        freeEmailDomains.add('weekonline.com');
        freeEmailDomains.add('wesleymail.com');
        freeEmailDomains.add('whale-mail.com');
        freeEmailDomains.add('wheelweb.com');
        freeEmailDomains.add('whipmail.com');
        freeEmailDomains.add('whoever.com');
        freeEmailDomains.add('wholefitness.com');
        freeEmailDomains.add('wildmail.com');
        freeEmailDomains.add('winmail.com.au');
        freeEmailDomains.add('winning.com');
        freeEmailDomains.add('winrz.com');
        freeEmailDomains.add('witty.com');
        freeEmailDomains.add('wombles.com');
        freeEmailDomains.add('women-only.net');
        freeEmailDomains.add('wongfaye.com');
        freeEmailDomains.add('wooow.it');
        freeEmailDomains.add('work4teens.com');
        freeEmailDomains.add('workmail.co.za');
        freeEmailDomains.add('workmail.com');
        freeEmailDomains.add('worldbreak.com');
        freeEmailDomains.add('worldemail.com');
        freeEmailDomains.add('wowmail.com');
        freeEmailDomains.add('wp.pl');
        freeEmailDomains.add('writeme.com');
        freeEmailDomains.add('writemeback.com');
        freeEmailDomains.add('writeremail.com');
        freeEmailDomains.add('wrongmail.com');
        freeEmailDomains.add('www.com');
        freeEmailDomains.add('wxs.net');
        freeEmailDomains.add('x-mail.net');
        freeEmailDomains.add('xaker.ru');
        freeEmailDomains.add('xmenfans.com');
        freeEmailDomains.add('xmsg.com');
        freeEmailDomains.add('xoom.com');
        freeEmailDomains.add('xpectmore.com');
        freeEmailDomains.add('xsmail.com');
        freeEmailDomains.add('xtram.com');
        freeEmailDomains.add('xzapmail.com');
        freeEmailDomains.add('yaho.com');
        freeEmailDomains.add('yahoo.co.jp');
        freeEmailDomains.add('yahoo.co.kr');
        freeEmailDomains.add('yahoo.co.nz');
        freeEmailDomains.add('yahoo.co.uk');
        freeEmailDomains.add('yahoo.com');
        freeEmailDomains.add('yahoo.com.ar');
        freeEmailDomains.add('yahoo.com.au');
        freeEmailDomains.add('yahoo.com.br');
        freeEmailDomains.add('yahoo.com.co');
        freeEmailDomains.add('yahoo.com.hk');
        freeEmailDomains.add('yahoo.com.is');
        freeEmailDomains.add('yahoo.com.mx');
        freeEmailDomains.add('yahoo.com.ru');
        freeEmailDomains.add('yahoo.com.sg');
        freeEmailDomains.add('yahoo.de');
        freeEmailDomains.add('yahoo.dk');
        freeEmailDomains.add('yahoo.es');
        freeEmailDomains.add('yahoo.fr');
        freeEmailDomains.add('yahoo.ie');
        freeEmailDomains.add('yahoo.it');
        freeEmailDomains.add('yahoo.jp');
        freeEmailDomains.add('yahoo.ru');
        freeEmailDomains.add('yahoo.se');
        freeEmailDomains.add('yahoofs.com');
        freeEmailDomains.add('yahoomail.com');
        freeEmailDomains.add('yam.com');
        freeEmailDomains.add('yandex.ru');
        freeEmailDomains.add('yeehaa.com');
        freeEmailDomains.add('yehey.com');
        freeEmailDomains.add('yemenmail.com');
        freeEmailDomains.add('yepmail.net');
        freeEmailDomains.add('yeswebmaster.com');
        freeEmailDomains.add('yifan.net');
        freeEmailDomains.add('yourinbox.com');
        freeEmailDomains.add('yours.com');
        freeEmailDomains.add('yourwap.com');
        freeEmailDomains.add('youthfire.com');
        freeEmailDomains.add('youthpost.com');
        freeEmailDomains.add('yuuhuu.net');
        freeEmailDomains.add('yyhmail.com');
        freeEmailDomains.add('z6.com');
        freeEmailDomains.add('zdorovja.net');
        freeEmailDomains.add('zensearch.com');
        freeEmailDomains.add('zip.net');
        freeEmailDomains.add('zipido.com');
        freeEmailDomains.add('ziplip.com');
        freeEmailDomains.add('zipmail.com');
        freeEmailDomains.add('zipmail.com.br');
        freeEmailDomains.add('zipmax.com');
        freeEmailDomains.add('zmail.pt');
        freeEmailDomains.add('zmail.ru');
        freeEmailDomains.add('zonai.com');
        freeEmailDomains.add('zoneview.net');
        freeEmailDomains.add('zonnet.nl');
        freeEmailDomains.add('zubee.com');
        freeEmailDomains.add('zvmail.com');
        freeEmailDomains.add('zwallet.com');
        freeEmailDomains.add('zybermail.com');
        return freeEmailDomains;
    }

}