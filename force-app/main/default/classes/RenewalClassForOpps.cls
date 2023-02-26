/********************************************************
This class is referred in RenewalOpportunityCreationBatch
and CreateRenewal class
********************************************************/
public class RenewalClassForOpps{

Set<ID> oliIDs = new Set<ID>();
Map<ID,ID> oliIDToOpportunityID = new Map<ID,ID>();
Map<ID,ID> assetIdToOliId = new Map<ID,ID>();
Map<ID,ID> oliIdToAssetID = new Map<ID,ID>();
Set<ID> oppIDs = new Set<ID>();
Map<String,ID> oppIDwithAssetID = new Map<String,ID>();
Map<Id,Asset> asstMap = new Map<Id,Asset>();
Map <Id, Opportunity> oppWithOlis = new Map<Id, Opportunity>();
Map<String, Project_Role_Map__c> projectRoleMapping = Project_Role_Map__c.getAll();
Map<ID,ID> ownerWithProjectManager = new Map<ID,ID>();
Map<ID,ID> purchaseHistoryBillToAdressMap = new Map<ID,ID>();
Map<ID,ID> purchaseHistoryBillToAccountMap = new Map<ID,ID>();
Map<id,id> opportunityParentAssetID;
Set<ID> allOwnerIDs = new Set<ID>();
Map<Id, List<Project_Role__c>> assetWithProjectRole = new Map<Id,List<Project_Role__c>>();
Map<Asset,Id> assetVsOppID = new Map<Asset,ID>();
Savepoint sp = Database.setSavepoint();
public List<Opportunity> createRenewalOpps(List<Asset> assetsList){
    List<Opportunity> renewalOppsToInsert = new List<Opportunity>();
    try{
        sp = Database.setSavepoint();
        List<Project_Role__c> projRoles = new List<Project_Role__c>();

        for(Asset ast : assetsList){
            if(ast.Renewal_Opportunity_Created__c == false){

                //SET OF OLI IDs
                oliIDs.add(ast.OpportunityLineItem__c);

                //ASSET TO OLI MAP
                AssetIdToOliId.put(ast.id,ast.OpportunityLineItem__c);

                //OLI TO ASSET MAP
                OliIdToAssetID.put(ast.OpportunityLineItem__c,ast.id);
                purchaseHistoryBillToAdressMap.put(ast.OpportunityLineItem__c,ast.Bill_To_Address__c);
                purchaseHistoryBillToAccountMap.put(ast.OpportunityLineItem__c,ast.Bill_To_Account__c);
                assetVsOppID.put(ast,ast.Opportunity__c);
                asstMap.put(ast.Id,ast);
            }
        }
        system.debug(LoggingLevel.INFO, '---AssetIdToOliId-'+AssetIdToOliId);
        system.debug(LoggingLevel.INFO, '---AssetVsOppID-'+assetVsOppID);
        // FETCH ASSOCIATED PROJECT ROLES - TO POPULATE CONTACT LOOKUP FIELDS ON OLI LEVEL
        if (AssetIdToOliId != null && AssetIdToOliId.size() > 0){
            projRoles = [SELECT Id, Asset__c, Contact__c, Role__c, Status__c, PrimaryContact__c
                         FROM Project_Role__c
                         WHERE Asset__c IN :AssetIdToOliId.keySet() AND (Status__c = 'Active' OR Status__c ='') ];
        }
    

        system.debug(LoggingLevel.INFO, '_____projRoles____'+projRoles);

        
        // CREATES A MAP OF ASSET TO ASSOCIATED PROJECT ROLES
        if (projRoles != null && projRoles.size() > 0){

            for (Project_Role__c pr : projRoles){
                List<Project_Role__c> projectRoleList = new List<Project_Role__c>();
                if (assetWithProjectRole.containskey(pr.Asset__c)){
                    projectRoleList = assetWithProjectRole.get(pr.Asset__c);

                }
                projectRoleList.add(pr);
                assetWithProjectRole.put(pr.Asset__c, projectRoleList);

            }
        }
            system.debug(LoggingLevel.INFO, '____assetWithProjectRole_____'+assetWithProjectRole);

        //QUERY ALL OLIS THAT ARE ASSOCIATED TO EXPIRING ASSETS
        for(OpportunityLineItem oliS : [SELECT id,Opportunityid,Opportunity.ownerid FROM OpportunityLineItem WHERE id=:oliIDs]){

            //OLI TO OPPORTUNITY MAP
            oliIDToOpportunityID.put(oliS.id,oliS.Opportunityid);
            //SET OF OPP IDs
            oppIDs.add(oliS.Opportunityid);
            //OPPORTUNITY + OLI TO ASSET MAP
            OppIDwithAssetID.put(oliS.opportunityid + '' +oliS.id,OliIdToAssetID.get(oliS.id));
            //FETCH ALL OPPORTUNITY OWNER IDs
            allOwnerIDs.add(oliS.Opportunity.ownerid);

            system.debug(LoggingLevel.INFO, 'OppIDwithAssetID '+OppIDwithAssetID);

        }
        system.debug(LoggingLevel.INFO, 'OppIDwithAssetID '+OppIDwithAssetID.size());

        //MAP USER WITH PROJECT MANAGER ROLE OF HIS OPPORTUNITY TEAM
        for(UserTeamMember usr : [SELECT id,OwnerId,UserId  FROM UserTeamMember WHERE TeamMemberRole=:System.label.Renewal_Opportunity_Opp_Team_Role and OwnerId=:allOwnerIDs]){

            ownerWithProjectManager.put(usr.OwnerId,usr.UserId);
        }

        system.debug(LoggingLevel.INFO, '___ownerWithProjectManager____'+ownerWithProjectManager);

        //GET OPPORTUNITY FIELD NAMES
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        String opportunityFieldNames;

        for(String ss : schemaFieldMap.keyset()){
            if(ss != ''){
                if(opportunityFieldNames != null){
                    opportunityFieldNames += ',' + ss;
                }else{
                    opportunityFieldNames = ss;
                }
            }
        }

        //GET OPPORTUNITY PRODUCT FIELD NAMES
        Map<String, Schema.SObjectField> schemaFieldMapOli = Schema.SObjectType.OpportunityLineItem.fields.getMap();
        String oliFieldNames;

        for(String sso : schemaFieldMapOli.keyset()){
            if(sso != '' ){
                if(oliFieldNames != null){
                    oliFieldNames += ',' + sso;
                }else{
                    oliFieldNames = sso;
                }
            }
        }

        Set<ID> oliIDSet = oliIDToOpportunityID.keyset();
        oliFieldNames +=',Product_Details__r.NetSuite_Class__c,toLabel(Product_Details__r.NS_Department__c),'+
                'toLabel(Product_Details__r.NS_Income_GL_Account__c),toLabel(Product_Details__r.NS_Revenue_Schedule__c),'+
                'toLabel(Product_Details__r.NS_Deferred_Revenue_Account__c),Product_Details__r.Price__c';

        String qury = 'select '+ OpportunityFieldNames + ', ( SELECT '+ oliFieldNames +
                ' FROM Opportunitylineitems WHERE id in : oliIDSet ),'+
                '(SELECT id,contactid,opportunityid,role,isprimary FROM OpportunityContactRoles) from Opportunity WHERE Id IN : oppIDs';
        system.debug(LoggingLevel.INFO, '______'+qury);

        oppWithOlis = new Map<Id, Opportunity>((List<Opportunity>)Database.query(String.escapeSingleQuotes(qury)));

        system.debug(LoggingLevel.INFO, '____oppWithOlis____'+oppWithOlis );

        for(Asset oldAsset : assetVsOppID.keySet()){

            Opportunity opp = oppWithOlis.get(assetVsOppID.get(oldAsset));
            if(opp != null){
                //CLONE THE OPPORTUNITY
                Opportunity newOpp = new Opportunity();
                Date startDate = asstMap.get(oldAsset.id).usageEndDate.addDays(1);
                newOpp = opp.clone(false, false, false, false);
                newOpp.SyncedQuoteId = null;
                
                //SOPS-808 set year in Opportunity Name of renewal membership Opps
                if(newOpp.Name.right(4).contains('20')){
                    newOpp.Name = newOpp.name.left(newOpp.name.length() - 4) + startDate.year();
                } else {
                    newOpp.Name = newOpp.name + ' - ' + startDate.year();
                }
                //Truncate New opp name due to 120 Character limit
                if(newOpp.Name.length() > 120){
                    newOpp.Name = newOpp.name.left(113) + newOpp.Name.right(7);
                }
                
                if(oldAsset != NULL && oldAsset.AccountID != NULL){
                    newOpp.AccountID = oldAsset.AccountID;
                }   
                //NEED UPDATES
                if(oldAsset != NULL && oldAsset.Bill_To_Account__c != NULL){
                    newOpp.Bill_To_Account__c = oldAsset.Bill_To_Account__c;
                }
                if(oldAsset != NULL && oldAsset.Bill_To_Address__c != NULL){
                    newOpp.Bill_To_Address__c = oldAsset.Bill_To_Address__c;
                }
                
                newOpp.stagename = '2. Discovery';
                newOpp.type = 'Renewal';
                newOpp.Amount = 0;
                newOpp.ForecastCategoryName = 'Pipeline';
                newOpp.Record_Locked__c=false;
                newOpp.NextStep = null;
                newOpp.Description = null;
                newOpp.SugarOpportunityID__c = '';
                newOpp.parent_asset__c = oldAsset.Id;
                
                
                //Clearing fields on Renewal Opportunity
                newOpp.Hold__c=false;
                newOpp.JoinNow_Update__c=null;
                newOpp.Contract_Sent_By__c=null;
                newOpp.Renewal_Hold_Comment__c=null;
                newOpp.Renewal_Likelihood__c=null;
                newOpp.Renewal_Opportunity_Closed__c=null;
                newOpp.Renewal_Date__c=null;
                newOpp.Hold_Reason__c = null;
                //added by harshad
                newOpp.Employee_Count_Needs_Verified__c = false;
                newOpp.Product_Tier_Needs_Verification__c = false;
                newOpp.Company_Type_Needs_Verified__c = false;
                newOpp.ApplicationStatus__c = null;
                //newOpp.Correct_Tier__c = null;
                //newOpp.Correct_Tier_Price__c = null;
                //newOpp.Tier_Upgrade_Value__c = null;
                
                
                //set closedate
                Utility util = new Utility();
                Date endDate = oldAsset.UsageEndDate;
                String defaultDays = oldAsset.Projects__r.Days_to_Deduct__c != null ? oldAsset.Projects__r.Days_to_Deduct__c : '2';
                Integer days = Integer.valueOf(defaultDays);
                newOpp.closedate = util.getRenewalCloseDate(endDate, days);

               /* Integer year = oldAsset.UsageEndDate.year();
                if(Date.valueOf((year +'-11-19')) > oldAsset.UsageEndDate ){
                    newOpp.closedate = oldAsset.UsageEndDate - 1;
                }else if(Date.valueOf((year +'-11-19')) <= oldAsset.UsageEndDate &&
                        Date.valueOf((year +'-11-30')) >= oldAsset.UsageEndDate){
                    newOpp.closedate = Date.newInstance(year,11,19);
                }else if(Date.valueOf((year +'-12-01')) <= oldAsset.UsageEndDate &&
                        Date.valueOf((year +'-12-31')) >= oldAsset.UsageEndDate){
                    newOpp.closedate = Date.newInstance(year,11,20);
                }
*/
                /* if(opp.Opportunitylineitems.size()>0 && opp.Opportunitylineitems[0].End_Date__c!=null)
newOpp.closedate = opp.Opportunitylineitems[0].End_Date__c.addDays(1);*/

                system.debug(LoggingLevel.INFO, '__ownerid____'+opp.ownerid);
                system.debug(LoggingLevel.INFO, '__lf_product_count____'+opp.LF_Product_Count__c);
                system.debug(LoggingLevel.INFO, '__ownerWithProjectManager____'+ownerWithProjectManager);

                //GET THE ASSET FROM ITS OPPORTUNITY LINE ITEM
                /*for(opportunitylineitem oli : opp.opportunitylineitems){
                    if(purchaseHistoryBillToAdressMap.containsKey(oli.id) && purchaseHistoryBillToAdressMap.get(oli.id) != null){

                        system.debug('--Inside Contains Key--');
                        //newOpp.Bill_To_Address__c = purchaseHistoryBillToAdressMap.get(oli.id);
                    }
                    // newOpp.Bill_To_Account__c  = purchaseHistoryBillToAccountMap.containskey(oli.id) && purchaseHistoryBillToAccountMap.get(oli.id) != null ? purchaseHistoryBillToAccountMap.get(oli.id) : opp.Bill_To_Account__c;
                    if(OppIDwithAssetID != null && OppIDwithAssetID.containsKey((opp.id+ '' +oli.id))){
                        system.debug('--Inside  Key--'+oli);
                        newOpp.closedate = oli.End_Date__c;

                        system.debug('OppIDwithAssetID '+OppIDwithAssetID.get(opp.id+ '' +oli.id));
                        newOpp.parent_asset__c = OppIDwithAssetID.get(opp.id+ '' +oli.id);
                        OppIDwithAssetID.remove((opp.id+ '' +oli.id));
                        break;
                    }
                }*/
                system.debug(LoggingLevel.INFO, '----newOpp.closedate----'+newOpp.closedate);
                system.debug(LoggingLevel.INFO, '----Bill_To_Address__c----'+newOpp.Bill_To_Address__c);
                system.debug(LoggingLevel.INFO, '-----Bill_To_Account__c---'+newOpp.Bill_To_Account__c);
                renewalOppsToInsert.add(newOpp);
            }}
        system.debug(LoggingLevel.INFO, '--BeforeInsertrenewalOppsToInsert-'+renewalOppsToInsert);
        if(renewalOppsToInsert!=null && renewalOppsToInsert.size() > 0){

            List<Database.SaveResult> renewalOppsToInsertResult = Database.insert(renewalOppsToInsert,false);
            system.debug(LoggingLevel.INFO, '--renewalOppsToInsertResult-'+renewalOppsToInsertResult);
            Integer i = 0;
            for (Database.SaveResult sr : renewalOppsToInsertResult) {
                system.debug(LoggingLevel.INFO, '-----'+sr);
                for(Database.Error err : sr.getErrors()){
                    system.debug(LoggingLevel.INFO, '-----'+err);
                    //
                    database.rollback(sp);
                    throw new RenewalBatchClassException(err.getMessage()+';-;'+renewalOppsToInsert[i].get('parent_asset__c')+';-;'+err.getStatuscode());

                }
                i++;
            }
            cloneOLI_OCRForRenewalOpps(renewalOppsToInsert);
            createQuoteOnRenewalOf_POReqd_Opp(renewalOppsToInsert);
        }

    }
    catch(Exception e){
        throw e;
    }

    return renewalOppsToInsert;
}

public Map<Id,Asset> setCheckboxOnAsset(List<Asset> ast_List){

    Map<Id,Asset> astToUpdate = new Map<Id,Asset>();

    for(Asset ast : ast_List){
        if(ast.Renewal_Opportunity_Created__c==false){
            astToUpdate.put(ast.Id , new Asset(id=ast.id,Renewal_Opportunity_Created__c=false,Marked_for_Renewal_Processing__c=true));
        }

    }

    return astToUpdate;

}

public Map<Id,Opportunity> updateOppStageForRenewalOpps(List<Opportunity> renewalOpps){

    Map<Id,Opportunity> oppsToUpdate = new Map<Id,Opportunity>();

    for(Opportunity opp : renewalOpps){
        oppsToUpdate.put(opp.id,new Opportunity(id=opp.id,stageName = System.label.Renewal_Opportunity_Stage));
    }

    return oppsToUpdate;
}

/* public void createTasksForRenewalOpps(List<Opportunity> renewalOpts){

    List<Task> tasksForRenewalOpp = new List<Task>();

    List<Opportunity> opportunityList = [Select id,ownerid,name FROM Opportunity WHERE Id IN:  renewalOpts];
    for(Opportunity opp : opportunityList){
        String subjectName = '​Renewal Created - ' + '' + opp.name;
        tasksForRenewalOpp.add(new Task(whatid=opp.id,subject=subjectName,ownerid=opp.ownerid,Priority='High',Status='Open', Type='Renewal Reminder', ActivityDate=Date.today().addDays(1)));
    }

    if(tasksForRenewalOpp!=null)
        insert tasksForRenewalOpp;
}*/

public void cloneOLI_OCRForRenewalOpps(List<Opportunity> renewalOpps){
    system.debug(LoggingLevel.INFO, '--renewalOpps--'+renewalOpps);
    try{
        // Savepoint sp = Database.setSavepoint();
        opportunityParentAssetID = new Map<id,id>();
        List<OpportunitylineItem> olisToInsert = new List<OpportunitylineItem>();
        Map<Id,Set<OpportunityContactRole>> newOppIdWithOCRS = new Map<Id,Set<OpportunityContactRole>>();
        Map<Id, OpportunityLineItem> parentAssetVsNewLineItem = new Map<Id, OpportunityLineItem>();
        //Set<OpportunityContactRole> ocrs = new Set<OpportunityContactRole>();
        system.debug(LoggingLevel.INFO, '--AssetIdToOliId--'+AssetIdToOliId);
        for(Opportunity opp : renewalOpps){
            if(oppWithOlis.containskey(oliIDToOpportunityID.get(AssetIdToOliId.get(opp.Parent_Asset__c)))){
                List<Opportunitylineitem> olis = oppWithOlis.get(oliIDToOpportunityID.get(AssetIdToOliId.get(opp.Parent_Asset__c))).Opportunitylineitems;
                Set<OpportunityContactRole> ocrs = new Set<OpportunityContactRole>();
                Id oldOppId;
                //CLONE THE OPPORTUNITY LINE ITEMS
                for(Opportunitylineitem oli : olis){
                    if(oli.Id == AssetIdToOliId.get(opp.Parent_Asset__c)){
                        system.debug(LoggingLevel.INFO, 'In O');
                        oldOppId = oliIDToOpportunityID.get(AssetIdToOliId.get(opp.Parent_Asset__c));
                        opportunityParentAssetID.put(opp.id,opp.Parent_Asset__c);
                        system.debug(LoggingLevel.INFO, '___oli___'+oli );

                        Integer order_int=0;

                        OpportunityLineItem clonedOli = new OpportunityLineItem();
                        clonedOli = oli.clone(false, false, false, false);
                        clonedOli.opportunityid = opp.id;
                        clonedOli.PO_Number__c = '';
                        clonedOli.NetSuite_Invoice_Memo__c = '';
                        clonedOli.Converted_to_Asset__c = false;
                        //clonedOli.Start_date__c = oli.End_Date__c.addDays(1);
                        clonedOli.totalprice =  null;
                        clonedOli.Prorate__c = false;
                        clonedOli.Quantity = oli.Zero_Membership__c ? oli.Quantity :  1;
                        clonedOli.Start_date__c = asstMap.get(opp.Parent_Asset__c).usageEndDate.addDays(1);
                        //clonedOli.End_Date__c = asstMap.get(opp.Parent_Asset__c).usageEndDate;
                        clonedOli.NS_Entity_ID__c = asstMap.get(opp.Parent_Asset__c).NS_Entity_ID__c;
                        clonedOli.NetSuite_ID__c = asstMap.get(opp.Parent_Asset__c).NetSuite_ID__c;

                        //adding NetSuite Fields
                        clonedOli.NetSuite_Class__c=oli.Product_Details__r.NetSuite_Class__c;
                        clonedOli.NetSuite_Deferred_Revenue_Account__c=oli.Product_Details__r.NS_Deferred_Revenue_Account__c;
                        clonedOli.NetSuite_Income_GL_Account__c=oli.Product_Details__r.NS_Income_GL_Account__c;
                        clonedOli.NetSuite_Revenue_Schedule__c=oli.Product_Details__r.NS_Revenue_Schedule__c;
                        clonedOli.NetSuite_Department__c=oli.Product_Details__r.NS_Department__c;

                        //added new Condition for Cncf
                        clonedOli.CNCF_Level__c = asstMap.get(opp.Parent_Asset__c).CNCF_Level__c;
                        //set the pr display and logo fields
                        clonedOli.Display_Logo_On_Website__c =  asstMap.get(OliIdToAssetID.get(oli.id)).Display_Logo_On_Website__c;
                        clonedOli.No_Press_Release_Announcement__c = asstMap.get(OliIdToAssetID.get(oli.id)).Press_Release_Announcement__c;

                        if(projectRoleMapping!=null && projectRoleMapping.size()>0){
                            for(Project_Role_Map__c var : projectRoleMapping.values()){
                                clonedOli.put(var.Api_Name__c , null);
                            }
                        }

                        /*if(assetWithProjectRole!=null && assetWithProjectRole.size()>0 && assetWithProjectRole.containsKey(opp.Parent_Asset__c)){
                            List<Project_Role__c> roles_list = new List<Project_Role__c>();
                            roles_List.addAll(assetWithProjectRole.get(opp.Parent_Asset__c));

                            system.debug('____roles_List____'+roles_List);

                            for(Project_Role__c pr : roles_List){
                                if(projectRoleMapping.size()>0 && projectRoleMapping.containsKey(pr.Role__c)){
                                    clonedOli.put(projectRoleMapping.get(pr.Role__c).Api_Name__c , pr.Contact__c);
                                }
                            }
                        }*/

                        if(oli.year__c != null){
                            clonedOli.year__c = String.valueOf(Integer.valueOf(oli.year__c) + 1);
                        }

                        if(oli.Number_of_Years_Required__c!=null){
                            if(oli.Order__c!=null){

                                order_int = Integer.valueOf(oli.Order__c);

                                system.debug(LoggingLevel.INFO, '___order_int___'+order_int);

                                if(oli.Order__c <= oli.Number_of_Years_Required__c){
                                    clonedOli.Order__c = oli.Order__c+1;
                                }
                                else{
                                        clonedOli.Order__c = 1;
                                }
                            }
                            else {
                               
                                if(OliIdToAssetID.containsKey(oli.Id) && asstMap.get(OliIdToAssetID.get(oli.Id)).order__c!=null){

                                    order_int = Integer.ValueOf(asstMap.get(OliIdToAssetID.get(oli.Id)).Order__c);

                                    if(order_int<=oli.Number_of_Years_Required__c){
                                        clonedOli.Order__c = asstMap.get(OliIdToAssetID.get(oli.Id)).Order__c+1;
                                    }
                                    else {
                                            clonedOli.Order__c = 1;
                                    }
                                }
                            }
                        }

                        system.debug(LoggingLevel.INFO, '____Number_of_years_required__c___'+oli.Number_of_years_required__c);
                        system.debug(LoggingLevel.INFO, '____Order__c__'+oli.Order__c );
                        
                        system.debug(LoggingLevel.INFO, 'Renewal_type__c== '+oli.Renewal_type__c );
                        if(oli.Renewal_type__c == 'Prorate'){
                            if(oli.Product_Details__c != null && oli.Product_Details__r.Price__c != null){
                                clonedOli.UnitPrice = oli.Zero_Membership__c ? oli.UnitPrice : oli.Product_Details__r.Price__c;
                            }

                            if(oli.Number_of_years_required__c>0 && order_int != 0 && order_int == oli.Number_of_years_required__c){

                                if(asstMap.get(opp.Parent_Asset__c).usageEndDate.month()==12 && asstMap.get(opp.Parent_Asset__c).usageEndDate.day()==31){
                                    clonedOli.Prorate__c = false;
                                }
                                else{
                                    Date newStartDate = asstMap.get(opp.Parent_Asset__c).usageEndDate.addDays(1);
                                    Integer monthOfStartDate = newStartDate.month();
                                    Integer diffBetweenMonths = 12-monthOfStartDate ;
                                    Integer dayOfStartDate =  newStartDate.day();
                                    Integer diffBetweenDays = 31-dayOfStartDate ;
                                    Date endDate1 ;

                                    system.debug(LoggingLevel.INFO, '___newStartDate___'+newStartDate);
                                    system.debug(LoggingLevel.INFO, '___monthOfStartDate____'+monthOfStartDate+' _____diffBetweenMonths____'+diffBetweenMonths+'____diffBetweenDays____'+diffBetweenDays );

                                    if(monthOfStartDate!=1){
                                        if(diffBetweenMonths > 0){
                                            endDate1 = newStartDate.addMonths(diffBetweenMonths);
                                            clonedOli.quantity =  oli.Zero_Membership__c ? oli.Quantity : Decimal.ValueOf(diffBetweenMonths + 1)/12;
                                            system.debug(LoggingLevel.INFO, '____quantity____'+clonedOli.quantity);
                                            if(diffBetweenDays > 0){
                                                endDate1 = endDate1.addDays(diffBetweenDays);
                                            }
                                        }
                                        else if(diffBetweenMonths == 0){
                                            clonedOli.quantity =  oli.Zero_Membership__c ? oli.Quantity : Decimal.ValueOf(0 + 1)/12;
                                            if(diffBetweenDays > 0){
                                                endDate1 = newStartDate.addDays(diffBetweenDays);
                                            }
                                        }
                                    }
                                    else if(monthOfStartDate==1 && dayOfStartDate!=1){
                                        if(diffBetweenDays > 0){
                                            endDate1 = newStartDate.addDays(diffBetweenDays);
                                        }
                                    }

                                    system.debug(LoggingLevel.INFO, '__111_endDate1___'+endDate1);

                                    if(endDate1!=null){
                                        clonedOli.End_Date__c = endDate1;
                                        system.debug(LoggingLevel.INFO, '__if_endDate1___'+endDate1);
                                    }
                                    else{
                                        Date dt = newStartDate;
                                        Integer daysToAdd = 31 - dt.day();

                                        system.debug(LoggingLevel.INFO, '__else_dt___'+dt);

                                        system.debug(LoggingLevel.INFO, '__daysToAdd___'+daysToAdd);

                                        if(daysToAdd!=0){
                                            clonedOli.End_Date__c = dt.addDays(daysToAdd);
                                            system.debug(LoggingLevel.INFO, '____if____daystoadd___'+dt.addDays(daysToAdd));
                                        }else{
                                            clonedOli.End_Date__c = dt;
                                            system.debug(LoggingLevel.INFO, '___entered___else___');
                                        }
                                    }

                                    clonedOli.Prorate__c = true;
                                }
                            }
                        }
                        else if(oli.Renewal_type__c == 'Non-Prorate' || OLI.Renewal_type__c=='Calendar Year'){
                            clonedOli.End_Date__c = asstMap.get(opp.Parent_Asset__c).usageEndDate.addYears(1) - 1;
                        }

                        system.debug(LoggingLevel.INFO, '-clonedOli--'+clonedOli);
                        olisToInsert.add(clonedOli);

                        system.debug(LoggingLevel.INFO, '___olisToInsert____'+olisToInsert);

                    }
                }

                if(oldOppId!=null && oppWithOlis.get(oldOppId).Opportunitycontactroles.size()>0){
                    ocrs.addAll(oppWithOlis.get(oldOppId).Opportunitycontactroles);
                }
                if(ocrs!=null && ocrs.size()>0){
                    newOppIdWithOCRS.put(opp.Id,ocrs);
                }
            }}
        system.debug(LoggingLevel.INFO, '--olisToInsert-'+olisToInsert.size()+olisToInsert);
        list<Database.SaveResult> olisToInsertResults = new list<Database.SaveResult>();
        Integer i = 0;
        if(olisToInsert!=null && olisToInsert.size()>0){
            olisToInsertResults= Database.insert(olisToInsert,false);
            for (Database.SaveResult sr : olisToInsertResults) {
                if (sr.isSuccess()){
                    Id parentAssetId = opportunityParentAssetID.get((ID)olisToInsert[i].get('OpportunityID'));
                    parentAssetVsNewLineItem.put(parentAssetId, olisToInsert[i]);

                }
                for(Database.Error err : sr.getErrors()){
                    system.debug(LoggingLevel.ERROR, '-----'+err);
                    //String temp = (String)olisToInsert[i].getSobject('opportunities').get('Name');
                    System.debug(LoggingLevel.ERROR, '----'+olisToInsert[i]);
                    //Opportunity temp1 = (Opportunity)olisToInsert[i].getSobject('Opportunity');
                    //system.debug('---'+temp);
                    //system.debug('---'+temp1);
                    database.rollback(sp);
                    throw new RenewalBatchClassException(err.getMessage()+';-;'+opportunityParentAssetID.get((ID)olisToInsert[i].get('OpportunityID'))+';-;'+err.getStatuscode());
                }
                i++;
            }
        }
        system.debug(LoggingLevel.INFO, '__after__insert___olisToInsert____'+olisToInsert[0].quantity);

        if(newOppIdWithOCRS!=null && newOppIdWithOCRS.size()>0){
            cloneOCRS(newOppIdWithOCRS);
        }
        if (!assetWithProjectRole.isEmpty()){
            cloneProjectRoles(parentAssetVsNewLineItem);

        }

    }
    catch(Exception e){
        system.debug(LoggingLevel.ERROR, '----'+e);
        throw(e);
    }


}

public void cloneProjectRoles(Map<Id, OpportunityLineItem> parentAssetVsNewLineItem){
    try{
        List<Project_Role__c> projectRoleToInserted = new List<Project_Role__c>();
        for (Id assetId : assetWithProjectRole.keySet()){
            if (parentAssetVsNewLineItem.containsKey(assetId)){
                OpportunityLineItem oppLineItem = parentAssetVsNewLineItem.get(assetId);
                for (Project_Role__c projectRole : assetWithProjectRole.get(assetId)){
                    Project_Role__c pRole = projectRole.clone(false, false, false, false);
                    pRole.Type__c = 'Renewal';
                    pRole.Start_Date__c = oppLineItem.Start_Date__c;
                    pRole.End_Date__c = oppLineItem.End_Date__c;
                    pRole.Asset__c = null;
                    pRole.Opportunity__c = oppLineItem.OpportunityId;
                    pRole.Opportunity_Line_Item__c = oppLineItem.Id;
                    System.debug('##Renew Before Insert :' + pRole);
                    projectRoleToInserted.add(pRole);

                }
            }
        }
        if (!projectRoleToInserted.isEmpty()){
            list<Database.SaveResult> projectRolesInsertResults = Database.insert(projectRoleToInserted, false);
            Integer i = 0;
            for (Database.SaveResult sr : projectRolesInsertResults){
                system.debug(LoggingLevel.INFO, '-----' + sr);
                if (!sr.isSuccess()){
                    for (Database.Error err : sr.getErrors()){
                        system.debug(LoggingLevel.INFO, '-----' + err);
                        database.rollback(sp);
                        throw new RenewalBatchClassException(err.getMessage()+';-;'+ opportunityParentAssetID.get((ID)projectRoleToInserted[i].get('Opportunity__c'))+';-;'+ err.getStatuscode());
                    }
                    i++;
                }
            }
        }

    } catch (Exception e){
        system.debug(LoggingLevel.INFO, 'error while project role insertion----' + e);
        throw (e);
    }
}

public void cloneOCRS(Map<Id,Set<OpportunityContactRole>> oppIdWithocrsToClone){
    try{
        List<OpportunityContactRole> ocrsToInsert = new List<OpportunityContactRole>();

        //CLONE THE OPPORTUNITY CONTACT ROLES
        for(Id oId : oppIdWithocrsToClone.KeySet()){
            for(OpportunityContactRole ocr : oppIdWithocrsToClone.get(oId)){
                OpportunityContactRole clonedOcr = new OpportunityContactRole();
                clonedOcr = ocr.clone(false, false, false, false);
                clonedOcr.Opportunityid = oId;
                ocrsToInsert.add(clonedOcr);
            }
        }

        list<Database.SaveResult> oocrsToInsertResults = new list<Database.SaveResult>();
        Integer i = 0;

        if(ocrsToInsert!=null && ocrsToInsert.size()>0){
            oocrsToInsertResults= Database.insert(ocrsToInsert,false);
            for (Database.SaveResult sr : oocrsToInsertResults) {
                system.debug(LoggingLevel.INFO, '-----'+sr);
                for(Database.Error err : sr.getErrors()){
                    system.debug(LoggingLevel.ERROR, '-----'+err);
                    database.rollback(sp);
                    throw new RenewalBatchClassException(err.getMessage()+';-;'+opportunityParentAssetID.get((ID)ocrsToInsert[i].get('OpportunityID'))+';-;'+err.getStatuscode());
                }
                i++;
            }
        }
    }
    catch(Exception e){
        system.debug(LoggingLevel.ERROR, '----'+e);
        throw(e);
    }
}
public Map<Id,String> getParentAssetVsRenewalNameMap(List<Opportunity> renewalOpps){
    Map<Id,String> parentAssetIdVsRenewalOppName = new Map<Id,String>();
    for(Opportunity opp : renewalOpps){
        parentAssetIdVsRenewalOppName.put(opp.Parent_Asset__c,opp.Name);
    }
    return parentAssetIdVsRenewalOppName;
}

public Map<Id,Id> createQuoteOnRenewalOf_POReqd_Opp(List<Opportunity> renewalOpps) {
    Map<Id,Id> oppIdVsQuoteId = new Map<Id,Id>();
    Map<Id, Quote> oppIdVSquoteMap = new Map<Id, Quote>();
    for (Opportunity opp : renewalOpps) {
        if (opp.Opportunity_PO_Required__c) {
            Quote quote = new Quote(Name = opp.Name, 
                                    OpportunityId = opp.Id,
                                    Pricebook2Id = opp.Pricebook2Id);
            oppIdVSquoteMap.put(opp.Id, quote);  
        }
    }
    if (!oppIdVSquoteMap.isEmpty()) {
        insert oppIdVSquoteMap.values();            
        List<OpportunityLineItem> oliList = [SELECT Id,OpportunityId,UnitPrice,Quantity,PricebookEntryId,Product2Id,Zero_Membership__c,
                                             Discount,ServiceDate,SortOrder
                                             FROM OpportunityLineItem
                                             WHERE OpportunityId IN : oppIdVSquoteMap.keySet()];
        
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        //Iterate on oppLineItem
        for (OpportunityLineItem oli : oliList) {
            if (oppIdVSquoteMap.containsKey(oli.OpportunityId)) {
                //create instance of quotelineitem
                QuoteLineItem qli = new QuoteLineItem();
                qli.quoteId = oppIdVSquoteMap.get(oli.OpportunityId).Id;
                qli.UnitPrice = oli.UnitPrice;
                qli.Product2Id = oli.Product2Id;
                qli.Quantity = oli.Quantity;
                qli.PriceBookentryid = oli.PriceBookentryId;
                qli.OpportunityLineItemId = oli.Id;
                qli.Discount = oli.Discount;
                qli.ServiceDate = oli.ServiceDate;
                qliList.add(qli);
                oppIdVsQuoteId.put(oli.opportunityId, qli.quoteId);
            }
        }
        system.debug(' qliList' + qliList);
        system.debug(' qliList size' + qliList.size());
        if (!qliList.isEmpty()) 
            insert qliList;
    }
    syncQuote(oppIdVsQuoteId);
    return oppIdVsQuoteId;
    
}

public static void syncQuote(Map<Id,Id> oppIdVsQuoteId){
    List<Opportunity> updateOpp = new List<Opportunity>();
    //query opp again incase opp is not created
    for(Opportunity opp : [SELECT Id,SyncedQuoteId FROM Opportunity WHERE Id IN: oppIdVsQuoteId.keySet()]){
        opp.SyncedQuoteId = oppIdVsQuoteId.get(opp.Id);
        updateOpp.add(opp);
    }

    if(!updateOpp.isEmpty())
        update updateOpp;
}
public class RenewalBatchClassException extends Exception {


}
}