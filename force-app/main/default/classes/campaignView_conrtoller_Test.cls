/****************
* 
* Created Date: 22 NOV 2019
* Class Name : campaignView_conrtoller_Test
* Type : Test Class 
*
*****************/
@isTest
public class campaignView_conrtoller_Test {
    @isTest 
    static void campaignView_Test1() {
        
        //Created Foundation record
        //Id dirFoundationId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Directed Fund'].Id;
        testFactory.getAccount();
        Account acc = new Account(Name='Test',P_O_Required__c=true,Event_PO_required__c=true);
        insert acc;
        Project__c foundationRecord = new Project__c ();
        foundationRecord.Name = 'New Test Project';
        //foundationRecord.RecordTypeId = dirFoundationId;
        foundationRecord.Status__c = 'Planned';
        foundationRecord.Category__c = 'Subproject';
        foundationRecord.Type__c = 'Membership';
        foundationRecord.Manual_Status_Check__c = false;
        foundationRecord.Project_Type__c='Project Group';   
        foundationRecord.Pipeline_Stage__c = 'Engaged';
        foundationRecord.Slug__c = 'testproj';
        insert foundationRecord; 
        
        Campaign campaignRecord = new Campaign();
        campaignRecord.Name = 'My New Campaign';
        campaignRecord.Status = 'Planned';
        campaignRecord.Project__c = foundationRecord.Id;
        campaignRecord.StartDate = date.today().addDays(-5);
        campaignRecord.EndDate = date.today();
        insert campaignRecord;
        
        id RecordtypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.AccountID = acc.ID;
        opportunityRecord.Name = 'My Opp Record';
        opportunityRecord.CloseDate = date.today();
        opportunityRecord.StageName = '2. Discovery';
        opportunityRecord.Opportunity_PO_Required__c = acc.P_O_Required__c;
        opportunityRecord.RecordTypeId=RecordtypeId;
        opportunityRecord.CampaignId = campaignRecord.Id;
        insert opportunityRecord;
        
        Test.startTest();
        campaignView_conrtoller.getCampaignDetails('', 'Name', True);
        campaignView_conrtoller.getCampaignDetails(foundationRecord.Id, 'Name', True);
        campaignView_conrtoller.getCampaignDetails(foundationRecord.Id, 'Name', false);
        campaignView_conrtoller.getSelectedCampaignDetails('', '');
        campaignView_conrtoller.getSelectedCampaignDetails('', campaignRecord.Id);
        campaignView_conrtoller.getSelectedCampaignDetails(foundationRecord.Id, '');
        campaignView_conrtoller.getSelectedCampaignDetails(foundationRecord.Id, campaignRecord.Id);
    }
}