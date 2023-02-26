/*
* Test Class For-AddressTriggerHandler 
*/
@isTest
public class addressTriggerHandlerTest {
    
    @TestSetup
    static void createTestData(){
        // get Account
        Account acc = testFactory.getAccount();
        // get Corporate Training Record Type Id
        Id corporateTrainingRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
        
        // create Alternate Bill to Name and Address
        Address__c objAddress = new Address__c();
        objAddress.Account__c = acc.id;
        objAddress.Name ='Test Address';
        objAddress.City__c = 'Test City';
        objAddress.Country__c = 'Test Country';
        objAddress.State__c = 'Test State';
        objAddress.Street__c = 'Test Street';
        objAddress.Zip_Postal_Code__c = 'CODE';
        insert objAddress;
        
        // get Contact
        Contact con = testFactory.getContact();
        // get OpportunityLineItem
        OpportunityLineItem oli = TestFactory.getOpportunityLineItem();
        
        Product2 prod =[Select ID From Product2 Where Name='TestP' Limit 1];
        // get Project
        Project__c prj = testFactory.getProject();
        prj.NS_Department__c= '	10';
        prj.NS_Income_GL_Account__c= '297';
        prj.NS_Deferred_Revenue_Account__c= '282';
        prj.Project_Code__c='TP';
        prj.Subsidiary_ID__c = 1;
        update prj;
        
        // create product details 
        Product_Details__c prodDetail = new Product_Details__c();
        prodDetail.Price__c = 56;
        prodDetail.Project__c = prj.Id;
        prodDetail.NS_Income_GL_Account__c = '290';
        prodDetail.NS_Deferred_Revenue_Account__c = '284';
        prodDetail.NS_Department__c = '10';
        prodDetail.NS_Revenue_Schedule__c = '29';
        prodDetail.Netsuite_Sync__c = false;
        prodDetail.Products__c = prod.id;
        prodDetail.Duration__c = '45';
        prodDetail.Description__c = 'Description_Test';
        prodDetail.Tier__c = 'Test';
        prodDetail.Netsuite_ID__c = '889955';
        prodDetail.SubsidiaryID__c =1;
        insert prodDetail;
        
        // update line item
        oli.Product_Details__c = prodDetail.Id;
        oli.Start_Date__c = Date.newInstance(2021, 01, 01);
        oli.End_Date__c = Date.newInstance(2021, 12, 31);
        oli.Projects__c = prj.Id;
        oli.Skip_NetSuite_Sync__c = true;
        oli.Representative_Voting_Contact__c = con.Id;
        oli.Billing_Contact__c = con.Id;
        update oli;
        
        Opportunity opp =[Select ID,Type,Bill_To_Address__c,StageName From Opportunity where Name='Opportunity testing 1' Limit 1];
        
        OpportunityContactRole CR = new OpportunityContactRole(OpportunityId = opp.Id,IsPrimary = true, ContactId =con.Id, Role='Membership Decision Maker'); 
        insert CR;
        
        opp.RecordTypeId = corporateTrainingRecordId ;
        opp.Invoice_Only_Opp__c = true;
        opp.Type = 'New Business';
        opp.Bill_To_Address__c = objAddress.Id;
        opp.StageName = 'Closed Won';
        opp.Billing_Contact__c = con.Id;
        Update opp; 
        
    }  
    
    @isTest
    static void testValidateAddressBeforeDelete() {
        
        Opportunity opp =[Select ID,Type,Bill_To_Address__c,StageName From Opportunity Limit 1];
        Address__c objAddress = [Select ID,City__c From Address__c Where Id=:opp.Bill_To_Address__c];
        objAddress.City__c = 'Update City';
        update objAddress;
        
        Test.startTest();
        try {
            delete objAddress;
        }
        catch(Exception e){
            System.debug('Exception: ' + e + ', Message: ' + e.getMessage()+', Line Number: ' + e.getLineNumber()+'\n' + e.getStackTraceString());
            System.Assert(e.getMessage().contains('You can not delete this Address'), 'Delete action is not completed');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteUndeleteMethod() {
        
        map<Id,Address__c> oldMap = new map<Id,Address__c>();
        map<Id,Address__c> newMap = new map<Id,Address__c>();
        
        Opportunity opp =[Select ID,Type,Bill_To_Address__c,StageName From Opportunity Limit 1];
        Address__c objAddress = [Select ID,City__c From Address__c Where Id=:opp.Bill_To_Address__c];
        
        oldMap.put(objAddress.id, objAddress);
        newMap.put(objAddress.id, objAddress);
        
        AddressTriggerHandler objClass = new AddressTriggerHandler();
        
        AddressTriggerHandler.AfterDelete(oldMap);
        AddressTriggerHandler.AfterUnDelete(newMap);
        
    }
}