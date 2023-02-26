@isTest
public class CancelOrResendDocusignControllerTest {
	@isTest
    public static void getDocuSignStatusTest(){
        Docusign_Settings__c setting = new Docusign_Settings__c();
        setting.AccountID__c = '34b9d81f-63d3-48cb-968d-72fc1a9df29f';
        //Docusign_Settings__c setting = Docusign_Settings__c.getOrgDefaults();
        List <OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Account acc = new Account(Name = 'Test account' , billingStreet = 'street');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact' , AccountId=acc.Id);
        insert con;
        
        Project__c project1= new Project__c(Name='test Project',Type__c='Membership',Category__c='Subproject',Status__c='Planned',slug__c = 'testproject');
        insert project1;
        
        Opportunity oppt= new Opportunity(Name='Opportunity testing 1' , accountId=acc.Id , StageName='2. Discovery' ,Type='Renewal', CloseDate=Date.today().addDays(4),Renewal_Opportunity_Closed__c='True' );
        insert oppt;
        
        Id pricebookId = Test.getStandardPricebookId();
        PriceBook2 pbk = new PriceBook2(Name = 'testBook',isActive =true);
        insert pbk; 
        
        Product2 prod = new Product2(Name = 'TestP',productcode='test');
        insert prod;
        
        PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId,Product2Id=prod.ID,isActive=true,unitPrice=34);
        insert standardPbe;
        
        PriceBookEntry pbe=new PriceBookEntry(PriceBook2Id=pbk.Id,isActive=true,Product2Id=prod.ID,unitPrice=20.0,useStandardPrice=false);
        insert pbe;
        
        OpportunityLineItem oli= new OpportunityLineItem(OpportunityId = oppt.Id,Quantity =2, unitPrice = 20,PriceBookEntryId = pbe.ID,Required_Active_LF_Membership__c=true,Projects__c=project1.id);    
        insert oli;
        oliList.add(oli);
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = oppt.id,dsfs__DocuSign_Envelope_ID__c = 'test');
        insert ds;
        
        Test.startTest();
        String envelopId = CancelOrResendDocusignController.getDocuSignStatus(oppt.Id);
        System.assertEquals('test', envelopId);
        String status = CancelOrResendDocusignController.getEnvelopeId(oppt.Id);
        System.assertEquals('OK',status);
        String success = CancelOrResendDocusignController.voidEnvelope(envelopId,'test reason',oppt.Id);
        System.assertEquals('OK',success);
        
        Test.stopTest();

       
    }
}