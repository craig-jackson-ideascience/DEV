@isTest
public class CampaignMemberTriggerHandlerTest {

    @testSetup static void setup() {
 	
	Account acc1 = new Account(Name = 'Test account' , website = 'testing123.com1');
    insert acc1;
        
	Project__c project= new Project__c(Name='TestProject', Category__c = 'Directed fund', Slug__c = 'test_slug');
    insert project;
        
	Campaign C1 = new Campaign();
        C1.Name ='Test Subscription Center';
        C1.Description ='Test for Email Opt Out';
        C1.Project__c = project.Id;
        C1.Type ='Subscription Center';
        C1.Status ='In Progress';
        C1.StartDate = Date.today();
        C1.IsActive = true;
        C1.Add_to_Subscription_Center__c = true;
	    C1.Technology__c ='System Administration';
        insert C1;
        
        CampaignMemberStatus ms1= new CampaignMemberStatus();
		ms1.CampaignId = C1.Id;
		ms1.Label = 'Subscribed';
		ms1.SortOrder = 3;
		insert ms1;
        
        CampaignMemberStatus ms2 = new CampaignMemberStatus();
		ms2.CampaignId = C1.Id;
		ms2.Label = 'Unsubscribed';
		ms2.SortOrder = 4;
		insert ms2;
        
        Campaign C2 = new Campaign();
         C2.Name = 'TestCampaign 1';
         C2.IsActive = true ;                                           
         C2.Status = 'In Progress' ;                                         
         C2.Description = 'TestCampaign' ;
         C2.Technology__c ='Blockchain' ;
         C2.Type ='Training' ;
         C2.LF_Training__c = true ;
         C2.Project__c = project.id ;
         insert C2;
         
        CampaignMemberStatus ms3= new CampaignMemberStatus();
		ms3.CampaignId = C2.Id;
		ms3.Label = 'Subscribed';
		ms3.SortOrder = 3;
		insert ms3;
        
        CampaignMemberStatus ms4 = new CampaignMemberStatus();
		ms4.CampaignId = C2.Id;
		ms4.Label = 'Unsubscribed';
		ms4.SortOrder = 4;
		insert ms4;
	 	 
        LeadCountry__c objLeadCon = new LeadCountry__c();
         objLeadCon.Name ='1';
         objLeadCon.Country__c='India';
         objLeadCon.User__c ='0052M000006hOUm';
         insert objLeadCon;       
        
         Lead lead1 = new Lead();
         lead1.LastName = 'Lead Opt Out Check';
         lead1.Email = 'testOptOut@lead1.com';
         lead1.Country= 'India';
         insert  lead1;
        
         Contact contact1 = new Contact();
         contact1.LastName ='Contact Opt Out Check';
         contact1.Email ='testOptOut@contact1.com';
         contact1.AccountId = acc1.Id;
         insert contact1;

	     Lead lead2 = new Lead();
         lead2.LastName = 'Lead Opt Out Check2';
         lead2.Email = 'testOptOut@lead2.com';
         lead2.Country= 'India';
         insert  lead2;
        
         Contact contact2 = new Contact();
         contact2.LastName ='Contact Opt Out Check2';
         contact2.Email ='testOptOut@contact2.com';
         contact2.AccountId = acc1.Id;
         insert contact2;
        
        List<campaignMember> lstCM = new List<CampaignMember>();
	    CampaignMember CM1 = new CampaignMember();
        CM1.CampaignID = C1.Id;
        CM1.LeadId = lead1.Id;
        CM1.Status = 'Subscribed';
        lstCm.add(CM1);
        
        CampaignMember CM2 = new CampaignMember();
        CM2.CampaignID = C1.Id;
        CM2.ContactId = contact1.Id;
        CM2.Status = 'Subscribed';
        lstCM.add(CM2);

        CampaignMember CM3 = new CampaignMember();
        CM3.CampaignID = C2.Id;
        CM3.LeadId = lead2.Id;
        CM3.Status = 'Subscribed';
        lstCm.add(CM3);
        
        CampaignMember CM4 = new CampaignMember();
        CM4.CampaignID = C2.Id;
        CM4.ContactId = contact2.Id;
        CM4.Status = 'Subscribed';
        lstCM.add(CM4);
        
	    CampaignMember CM5 = new CampaignMember();
        CM5.CampaignID = C1.Id;
        CM5.LeadId = lead2.Id;
        CM5.Status = 'Unsubscribed';
        lstCm.add(CM5);
        
        CampaignMember CM6 = new CampaignMember();
        CM6.CampaignID = C1.Id;
        CM6.ContactId = contact2.Id;
        CM6.Status = 'Unsubscribed';
        lstCM.add(CM6);
        
        insert lstCM;
        
     }

     
    
    @IsTest
    static void updateContactEmailOptOutClone_Test(){
        List<CampaignMember> lstCM = new List<CampaignMember>();
        CampaignMember CM1 = [SELECT Id,Status,LeadID FROM CampaignMember WHERE Lead.LastName='Lead Opt Out Check' AND Status ='Subscribed' LIMIT 1];
		CampaignMember CM2 = [SELECT Id,Status,ContactID FROM CampaignMember WHERE Contact.LastName='Contact Opt Out Check' AND Status ='Subscribed'LIMIT 1];
        CampaignMember CM3 = [SELECT Id,Status,LeadID FROM CampaignMember WHERE Lead.LastName='Lead Opt Out Check2' AND Status ='Unsubscribed'LIMIT 1];
		CampaignMember CM4 = [SELECT Id,Status,ContactID FROM CampaignMember WHERE Contact.LastName='Contact Opt Out Check2' AND Status ='Unsubscribed'LIMIT 1];
        CM1.Status ='Unsubscribed';
        CM2.Status = 'Unsubscribed';
        CM3.Status ='Subscribed';
        CM4.Status = 'Subscribed';
        lstCM.add(CM1);
        lstCM.add(CM2);
        lstCM.add(CM3);
        lstCM.add(CM4);
        Update lstCM;
    }
    
    
    @isTest private static void prepDataForMassDispositionTests(){
        
        //create and insert test projects
        Project__c lfn = new Project__c();
        lfn.Name = 'LF Networking';
        lfn.Category__c = 'Incorporated';
        lfn.Slug__c = 'lfn';
        insert lfn;
        
        Project__c cncf = new Project__c();
        cncf.Name = 'CNCF';
        cncf.Category__c = 'Incorporated';
        cncf.Slug__c = 'cncf';
        insert cncf;
        
        Project__c hyp = new Project__c();
        hyp.Name = 'Hyperledger';
        hyp.Category__c = 'Incorporated';
        hyp.Slug__c = 'hyp';
        insert hyp;
        
        //create and insert test campaigns
        List<Campaign> campaigns = new List<Campaign>();
        
        Campaign camp1 = new Campaign();
        camp1.Name = 'Campaign 1';
        camp1.Project__c = lfn.Id;
        camp1.Type = 'Webinar';
        camp1.StartDate = Date.today();
        camp1.Auto_Disposition_Allowed__c = true;
        campaigns.add(camp1);
        
        Campaign camp2 = new Campaign();
        camp2.Name = 'Campaign 2';
        camp2.Project__c = lfn.Id;
        camp2.Type = 'Webinar';
        camp2.StartDate = Date.today();
        camp2.Auto_Disposition_Allowed__c = true;
        campaigns.add(camp2);
        
        Campaign camp3 = new Campaign();
        camp3.Name = 'Campaign 3';
        camp3.Project__c = lfn.Id;
        camp3.Type = 'Webinar';
        camp3.StartDate = Date.today();
        camp3.Auto_Disposition_Allowed__c = false;
        campaigns.add(camp3);
        
        Campaign camp4 = new Campaign();
        camp4.Name = 'Campaign 4';
        camp4.Project__c = cncf.Id;
        camp4.Type = 'Webinar';
        camp4.StartDate = Date.today();
        camp4.Auto_Disposition_Allowed__c = true;
        campaigns.add(camp4);
        
        Campaign camp5 = new Campaign();
        camp5.Name = 'Campaign 5';
        camp5.Project__c = cncf.Id;
        camp5.Type = 'Webinar';
        camp5.StartDate = Date.today();
        camp5.Auto_Disposition_Allowed__c = true;
        campaigns.add(camp5);
        
        Campaign camp6 = new Campaign();
        camp6.Name = 'Campaign 6';
        camp6.Project__c = hyp.Id;
        camp6.Type = 'Webinar';
        camp6.StartDate = Date.today();
        camp6.Auto_Disposition_Allowed__c = true;
        campaigns.add(camp6);
        
        insert campaigns;
        
        //create and insert statuses for test campaigns
        List<CampaignMemberStatus> statuses = new List<CampaignMemberStatus>();
        List<String> dispositionStatuses = Label.Campaign_Disposition_Statuses.split('\\r?\\n');
        
        for(Campaign camp : campaigns){
            for(String label : dispositionStatuses){
            	CampaignMemberStatus status = new CampaignMemberStatus();
            	status.Label = label;
            	status.CampaignId = camp.Id;
            	statuses.add(status);
            }
        }

        insert statuses;
    }
    
    @isTest private static void testMassDispositionForLead(){
        
        //prep most data
        prepDataForMassDispositionTests();
        
        //get campaigns created in data prep
        List<Campaign> testCampaigns = [SELECT Name FROM Campaign];
        Map<String, Id> campaignNameToID = new Map<String, Id>();
        for(Campaign camp : testCampaigns){
            campaignNameToID.put(camp.Name, camp.Id);
        }

        //prep data specific to this test
        Lead ld = new Lead();
        ld.LastName = 'Smith';
        ld.Company = 'Test';
        ld.Email = 'smith@test.com';
        insert ld;
        
        Lead anotherLd = new Lead();
        anotherLd.LastName = 'Jones';
        anotherLd.Company = 'Test';
        anotherLd.Email = 'jones@test.com';
        insert anotherLd;
     
        //insert all CMs with the status of 0. New
        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = ld.Id;
        cm1.Status = '0. New';
        cm1.CampaignId = campaignNameToID.get('Campaign 1');
        insert cm1;
        
        CampaignMember cm2 = new CampaignMember();
        cm2.LeadId = ld.Id;
        cm2.Status = '0. New';
        cm2.CampaignId = campaignNameToID.get('Campaign 2');
        insert cm2;
        
        CampaignMember cm3 = new CampaignMember();
        cm3.LeadId = ld.Id;
        cm3.Status = '0. New';
        cm3.CampaignId = campaignNameToID.get('Campaign 3');
        insert cm3;
        
        CampaignMember cm4 = new CampaignMember();
        cm4.LeadId = ld.Id;
        cm4.Status = '0. New';
        cm4.CampaignId = campaignNameToID.get('Campaign 4');
        insert cm4;
        
        CampaignMember cm5 = new CampaignMember();
        cm5.LeadId = ld.Id;
        cm5.Status = '0. New';
        cm5.CampaignId = campaignNameToID.get('Campaign 5');
        insert cm5;
        
        CampaignMember cm6 = new CampaignMember();
        cm6.LeadId = ld.Id;
        cm6.Status = '0. New';
        cm6.CampaignId = campaignNameToID.get('Campaign 6');
        insert cm6;
        
        CampaignMember cm1B = new CampaignMember();
        cm1B.LeadId = anotherLd.Id;
        cm1B.Status = '0. New';
        cm1B.CampaignId = campaignNameToID.get('Campaign 1');
        insert cm1B;
        
        CampaignMember cm2B = new CampaignMember();
        cm2B.LeadId = anotherLd.Id;
        cm2B.Status = '0. New';
        cm2B.CampaignId = campaignNameToID.get('Campaign 2');
        insert cm2B;
        
        //directly update the status of two CMs
        List<CampaignMember> cmsWithUpdatedStatuses = new List<CampaignMember>();
        cm1.Status = '1. MQL';
        cm4.Status = '3. SAL';
        cm1B.Status = '4. Follow Up';
		cmsWithUpdatedStatuses.add(cm1);
        cmsWithUpdatedStatuses.add(cm4);
        cmsWithUpdatedStatuses.add(cm1B);
        update cmsWithUpdatedStatuses;
        
        //get updated statuses for all CMs
        List<CampaignMember> updatedCMs = [SELECT Status, Skip_Mass_Disposition_Trigger__c FROM CampaignMember];
        
        //create and populate map of Campaign IDs to the Status of the CM in that Campaign
        Map<Id, String> cmIDToStatus = new Map<Id, String>();
        for(CampaignMember cm : updatedCMs){
            cmIDToStatus.put(cm.Id, cm.Status);
        }
        
        //check that the statuses used in this test class are still being used for dispositioning
        //(otherwise later assertions will fail)
        List<String> dispositionStatuses = Label.Campaign_Disposition_Statuses.split('\\r?\\n');
        System.assert(dispositionStatuses.contains('0. New'));
        System.assert(dispositionStatuses.contains('1. MQL'));
        System.assert(dispositionStatuses.contains('3. SAL'));
        System.assert(dispositionStatuses.contains('4. Follow Up'));
        
        //cm1a should have the status of '1. MQL' because it was directly updated to that status
        System.assertEquals('1. MQL', cmIDToStatus.get(cm1.Id), 'cm1 does not have expected Status');
        
        //cm2 should have the same status as cm1 as a result of mass dispositioning
        System.assertEquals('1. MQL', cmIDToStatus.get(cm2.Id), 'cm2 does not have expected Status');
        
        //cm3 should have the original status of '0. New' because Campaign 3 is set to Auto Disposition = FALSE
        System.assertEquals('0. New', cmIDToStatus.get(cm3.Id), 'cm3 does not have expected Status');
        
        //cm4 should have the status of '3. SAL' because it was directly updated to that status
        System.assertEquals('3. SAL', cmIDToStatus.get(cm4.Id), 'cm4 does not have expected Status');
        
        //cm5 should have the same status as cm4 as a result of mass dispositioning
        System.assertEquals('3. SAL', cmIDToStatus.get(cm5.Id), 'cm5 does not have expected Status');
        
        //cm6 should still have original status of '0. New' because Campaign 6 has a different project than Campaign 1 and Campaign 4
        System.assertEquals('0. New', cmIDToStatus.get(cm6.Id), 'cm6 does not have expected Status');
        
        //cm1B should have the status of '4. Follow Up' because it was directly updated to that status
        System.assertEquals('4. Follow Up', cmIDToStatus.get(cm1B.Id), 'cm1B does not have expected Status');
        
        //cm2B should have the same status as cm1B as a result of mass dispositioning
        System.assertEquals('4. Follow Up', cmIDToStatus.get(cm2B.Id), 'cm2B does not have expected Status');
        
        //at the end of the update, the Skip Mass Dispositioning Trigger checkbox should be false on all CMs,
		//so that the next human update to the Status will kick off mass-dispositioning as expected
        for(CampaignMember cm : updatedCMs){
        	String errorMessage = 'Skip Mass Dispositioning Trigger checkbox was not set back to false';
        	System.assertEquals(false, cm.Skip_Mass_Disposition_Trigger__c, errorMessage);
        }
    }
    
    @isTest private static void testMassDispositionForContact(){
        
        //prep most data
        prepDataForMassDispositionTests();
        
        //get campaigns created in data prep
        List<Campaign> testCampaigns = [SELECT Name FROM Campaign];
        Map<String, Id> campaignNameToID = new Map<String, Id>();
        for(Campaign camp : testCampaigns){
            campaignNameToID.put(camp.Name, camp.Id);
        }

        //prep data specific to this test
        Contact con = new Contact();
        con.LastName = 'Smith';
        con.Email = 'smith@test.com';
        insert con;
        
        Contact anotherCon = new Contact();
        anotherCon.LastName = 'Jones';
        anotherCon.Email = 'jones@test.com';
        insert anotherCon;
     
        //insert all CMs with the status of 0. New
        CampaignMember cm1 = new CampaignMember();
        cm1.ContactId = con.Id;
        cm1.Status = '0. New';
        cm1.CampaignId = campaignNameToID.get('Campaign 1');
        insert cm1;
        
        CampaignMember cm2 = new CampaignMember();
        cm2.ContactId = con.Id;
        cm2.Status = '0. New';
        cm2.CampaignId = campaignNameToID.get('Campaign 2');
        insert cm2;
        
        CampaignMember cm3 = new CampaignMember();
        cm3.ContactId = con.Id;
        cm3.Status = '0. New';
        cm3.CampaignId = campaignNameToID.get('Campaign 3');
        insert cm3;
        
        CampaignMember cm4 = new CampaignMember();
        cm4.ContactId = con.Id;
        cm4.Status = '0. New';
        cm4.CampaignId = campaignNameToID.get('Campaign 4');
        insert cm4;
        
        CampaignMember cm5 = new CampaignMember();
        cm5.ContactId = con.Id;
        cm5.Status = '0. New';
        cm5.CampaignId = campaignNameToID.get('Campaign 5');
        insert cm5;
        
        CampaignMember cm6 = new CampaignMember();
        cm6.ContactId = con.Id;
        cm6.Status = '0. New';
        cm6.CampaignId = campaignNameToID.get('Campaign 6');
        insert cm6;
        
        CampaignMember cm1B = new CampaignMember();
        cm1B.ContactId = anotherCon.Id;
        cm1B.Status = '0. New';
        cm1B.CampaignId = campaignNameToID.get('Campaign 1');
        insert cm1B;
        
        CampaignMember cm2B = new CampaignMember();
        cm2B.ContactId = anotherCon.Id;
        cm2B.Status = '0. New';
        cm2B.CampaignId = campaignNameToID.get('Campaign 2');
        insert cm2B;
        
        //directly update the status of two CMs
        List<CampaignMember> cmsWithUpdatedStatuses = new List<CampaignMember>();
        cm1.Status = '1. MQL';
        cm4.Status = '3. SAL';
        cm1B.Status = '4. Follow Up';
		cmsWithUpdatedStatuses.add(cm1);
        cmsWithUpdatedStatuses.add(cm4);
        cmsWithUpdatedStatuses.add(cm1B);
        update cmsWithUpdatedStatuses;
        
        //get updated statuses for all CMs
        List<CampaignMember> updatedCMs = [SELECT Status, Skip_Mass_Disposition_Trigger__c FROM CampaignMember];
        
        //create and populate map of Campaign IDs to the Status of the CM in that Campaign
        Map<Id, String> cmIDToStatus = new Map<Id, String>();
        for(CampaignMember cm : updatedCMs){
            cmIDToStatus.put(cm.Id, cm.Status);
        }
        
        //check that the statuses used in this test class are still being used for dispositioning
        //(otherwise later assertions will fail)
        List<String> dispositionStatuses = Label.Campaign_Disposition_Statuses.split('\\r?\\n');
        System.assert(dispositionStatuses.contains('0. New'));
        System.assert(dispositionStatuses.contains('1. MQL'));
        System.assert(dispositionStatuses.contains('3. SAL'));
        System.assert(dispositionStatuses.contains('4. Follow Up'));
        
        //cm1 should have the status of '1. MQL' because it was directly updated to that status
        System.assertEquals('1. MQL', cmIDToStatus.get(cm1.Id), 'cm1 does not have expected Status');
        
        //cm2 should have the same status as cm1 as a result of mass dispositioning
        System.assertEquals('1. MQL', cmIDToStatus.get(cm2.Id), 'cm2 does not have expected Status');
        
        //cm3 should have the original status of '0. New' because Campaign 3 is set to Auto Disposition = FALSE
        System.assertEquals('0. New', cmIDToStatus.get(cm3.Id), 'cm3 does not have expected Status');
        
        //cm4 should have the status of '3. SAL' because it was directly updated to that status
        System.assertEquals('3. SAL', cmIDToStatus.get(cm4.Id), 'cm4 does not have expected Status');
        
        //cm5 should have the same status as cm4 as a result of mass dispositioning
        System.assertEquals('3. SAL', cmIDToStatus.get(cm5.Id), 'cm5 does not have expected Status');
        
        //cm6 should still have original status of '0. New' because Campaign 6 has a different project than Campaign 1 and Campaign 4
        System.assertEquals('0. New', cmIDToStatus.get(cm6.Id), 'cm6 does not have expected Status');
        
        //cm1B should have the status of '4. Follow Up' because it was directly updated to that status
        System.assertEquals('4. Follow Up', cmIDToStatus.get(cm1B.Id), 'cm1B does not have expected Status');
        
        //cm2B should have the same status as cm1B as a result of mass dispositioning
        System.assertEquals('4. Follow Up', cmIDToStatus.get(cm2B.Id), 'cm2B does not have expected Status');
        
        //at the end of the update, the Skip Mass Dispositioning Trigger checkbox should be false on all CMs,
		//so that the next human update to the Status will kick off mass-dispositioning as expected
        for(CampaignMember cm : updatedCMs){
        	String errorMessage = 'Skip Mass Dispositioning Trigger checkbox was not set back to false';
        	System.assertEquals(false, cm.Skip_Mass_Disposition_Trigger__c, errorMessage);
        }
    }
    
    @isTest private static void testSkippingMassDisposition(){
        
        //check that the statuses used in this test class are still being used for
        //dispositioning (otherwise this isn't a very meaningful test)
        List<String> dispositionStatuses = Label.Campaign_Disposition_Statuses.split('\\r?\\n');
        System.assert(dispositionStatuses.contains('0. New'));
        System.assert(dispositionStatuses.contains('Customer'));
        
        //prep most data (only the first two campaigns are actually needed for this test)
        prepDataForMassDispositionTests();
        
        //get campaigns created in data prep
        List<Campaign> testCampaigns = [SELECT Name FROM Campaign];
        Map<String, Id> campaignNameToID = new Map<String, Id>();
        for(Campaign camp : testCampaigns){
            campaignNameToID.put(camp.Name, camp.Id);
        }

        //prep data specific to this test
        Lead ld = new Lead();
        ld.LastName = 'Smith';
        ld.Company = 'Test';
        ld.Email = 'smith@test.com';
        insert ld;
     
        //insert both CMs with the status of 0. New
        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = ld.Id;
        cm1.Status = '0. New';
        cm1.CampaignId = campaignNameToID.get('Campaign 1');
        cm1.Skip_Mass_Disposition_Trigger__c = true; //critical for this test
        insert cm1;
        
        CampaignMember cm2 = new CampaignMember();
        cm2.LeadId = ld.Id;
        cm2.Status = '0. New';
        cm2.CampaignId = campaignNameToID.get('Campaign 2');
        insert cm2;
        
        //update the status of the CM on the first Campaign to '1. MQL'
        cm1.Status = 'Customer';
        update cm1;
        
        //get updated statuses for all CMs
        List<CampaignMember> updatedCMs = [SELECT Status, CampaignId, Skip_Mass_Disposition_Trigger__c FROM CampaignMember];
        
        //create and populate map of Campaign IDs to the Status of the CM in that Campaign
        Map<Id, String> campaignIDToCMStatus = new Map<Id, String>();
        for(CampaignMember cm : updatedCMs){
            campaignIDToCMStatus.put(cm.CampaignId, cm.Status);
        }
        
        //cm1 should have the status of 'Customer' because it was directly updated to that status
        System.assertEquals('Customer', campaignIDToCMStatus.get(cm1.CampaignId), 'cm1 does not have expected Status');
        
        //cm2 should NOT have the new status as a result of mass dispositioning, since Skip Mass Dispositioning Trigger
        //checkbox on cm1 was set to true
        System.assertEquals('0. New', campaignIDToCMStatus.get(cm2.CampaignId), 'cm2 does not have expected Status');
        
		//at the end of the update, the Skip Mass Dispositioning Trigger checkbox should be false on all CMs,
		//so that the next human update to the Status will kick off mass-dispositioning as expected
        for(CampaignMember cm : updatedCMs){
        	String errorMessage = 'Skip Mass Dispositioning Trigger checkbox was not set back to false';
        	System.assertEquals(false, cm.Skip_Mass_Disposition_Trigger__c, errorMessage);
        }
    }
    
    @isTest private static void prePopulateCouponCodeTest(){
        Campaign campaign = [SELECT Id FROM Campaign LIMIT 1];
        campaign.Thirdparty_Coupon__c = true;
        update campaign;

        Coupon_Code__c couponCode = new Coupon_Code__c(Name='TestCoupon123',
        Expiration_Date__c=System.today()+1,
        Campaign_Name__c=campaign.Id);
        insert couponCode;

        Lead lead =new Lead(LastName='Test Lead 2021',email='test2021@gmail.com');
        insert lead;

        CampaignMember CM1 = new CampaignMember();
        CM1.CampaignID = campaign.Id;
        CM1.LeadId = lead.Id;
        Test.StartTest();
        insert CM1;
        Test.StopTest();

        System.assertEquals('TestCoupon123',[SELECT Id,Coupon_Code__c FROM CampaignMember 
        WHERE Id=:CM1.Id].Coupon_Code__c);

        System.assertEquals(System.today(),[SELECT Id,Date_Sent__c FROM Coupon_Code__c 
        WHERE Id=:couponCode.Id].Date_Sent__c);
    }
}