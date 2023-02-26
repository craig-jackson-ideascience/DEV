//Test Class for CompareEventsController
@isTest
public class CompareEventsControllerTest {
    
    //Method to create TestData
    @TestSetup
    static void createData(){
        //Account
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        //ContactList
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact contact = new Contact();
            contact.AccountId = account.Id;
            contact.FirstName = 'Test';
            contact.LastName = 'Contact'+i;
            contact.Email = 'testUnknown@noreply'+i+'.com';
            contactList.add(contact);
        }
        insert contactList;
        
        //ProjectList
        List<Project__c> projects = new List<Project__c>();
        projects.add(new Project__c(Name = 'testing11',Notifications_Group__c = 'test@test.com',Do_Not_Invoice__c = true,Category__c = 'Directed Fund', Subsidiary_ID__c = 8, Project_code__c = 'LF'
                                    ,Status__c='Active',Funding__c='Funded',Slug__c ='testing',Model__c ='Membership'));
        projects.add(new Project__c(Name = 'The Linux Foundation',Slug__c ='tlf',Notifications_Group__c = 'test@test.com',Do_Not_Invoice__c = true, Status__c = 'Planned',Category__c = 'Directed Fund',Subsidiary_ID__c = 8));
        insert projects;
        
        //EventList
        List<Event__c> eventListToInsert = new List<Event__c>();
        for(Integer i=1 ; i<5 ; i++){
            Event__c eventObj = new Event__c(name = 'test event'+i,Status__c = 'Active', 
                                             BillFromProject__c = projects[0].id, End_Date__c = System.today()+1, Start_Date__c = System.today());
            eventListToInsert.add(eventObj);
        }
        insert eventListToInsert;

        //EventRegistrationList
        List<Event_Registrations__c> EventRegListToInsert = new List<Event_Registrations__c>();
        Integer j=0,l=0;
        for (Integer i = 2; i < 8; i++) {
            if( math.mod(i, 2) == 0){
                j++;
                l=0;
            }
            Event_Registrations__c eventReg = new Event_Registrations__c();
            eventReg.Name = 'Test eventReg';
            eventReg.Contact__c = contactList[l].Id;
            eventReg.Event__c = eventListToInsert[j].Id;
            eventReg.Cvent_Registration_FirstName__c = 'test FirstName';
            eventReg.Cvent_Registration_LastName__c = 'test LastName';
            eventReg.Data_Source__c = 'Cvent';
            eventReg.Cvent_Registration_Status__c='Accepted';
            eventReg.Cvent_Registration_RegistrationDate__c=System.today()-1;
            EventRegListToInsert.add(eventReg);
            l++;
        }
        insert EventRegListToInsert;
        
        
    }
    
    //Test Method to Test the Controller
    @isTest
    private static void testCompareEventsController() {
        Event__c event = [SELECT Id FROM Event__c WHERE Event_Registrations__c != 0 Limit 1];
        
        // Actual test
        Test.startTest();
        Map<String, Object> responseMap = CompareEventsController.getAllEvents(JSON.serialize(new List<Id>{event.Id}));
        System.debug('Map<String, Object> responseMap '+ responseMap);
        Test.stopTest();
        // Asserts
        System.assertEquals(true, responseMap.containsKey('Details'));
        System.assertEquals(true, responseMap.containsKey('Events'));  
        
    }
}