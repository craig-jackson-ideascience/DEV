@isTest
private class NetSuiteToSalesforce_Test {
	
    @testSetup
    static void setup(){
        Endpoints__c obj = new Endpoints__c(Name='To Get Sales Order ID From NS',Endpoint__c='https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=39&deploy=1',
                                            Password__c='G6zevGabGM46MQRM',User_Id__c='nsapi@linuxfoundation.org');
        insert obj; 
    }
    
    @IsTest
    static void testCallout1(){ 
        Test.setMock(HttpCalloutMock.class, new NetSuiteToSalesforce_Mock ());
        Test.startTest();
        Database.executeBatch(new NetSuiteToSalesforce ());
        Test.stopTest();
     }
    
    @IsTest
    private static void testSchedulable(){ 
        Test.setMock(HttpCalloutMock.class, new NetSuiteToSalesforce_Mock ());
        Test.startTest();
        System.schedule('Netsuite Schedulable', '0 0 1 * * ?', new NetsuiteToSalesforceScheduler());
        Test.stopTest();
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE ApexClass.Name = 'NetSuiteToSalesforce' AND JobType = 'BatchApex'];
        System.assertEquals(1, batchJobs.size(), 'Unexpected number of batch jobs ran: ' + batchJobs);
    }
}