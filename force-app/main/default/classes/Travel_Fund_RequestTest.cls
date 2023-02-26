/**
 * Test class for TravelFundRequestTriggerHandler
 */
@isTest
public class Travel_Fund_RequestTest {

	private static final String TEST_KEY = 'ABC123'; 
    /**
	 *testSetup: create the required data for testing
	 */
    @testSetup static void setup(){
        // create project
        Project__c project = new Project__c(
            Name = 'The Linux Foundation',       
            Status__c = 'Planned', 
            Funding__c ='Funded',
            Category__c = 'Incorporated Entity',    
            ProjectSector__c = 'Platforms',         
            Membership_Autorenew__c = 'Yes',       
            Start_Date__c = system.today() - 10,   
            Renewal_Type__c = 'Prorate',           
            Payment_Frequency__c = 'Annually',     
            Bill_From_Name__c = 'The Linux Foundation',            
            Email_From_Name__c = 'Accounts Receivable',            
            Bill_From_Address__c = '1 Letterman Drive, Suite D4700',                  
            Email_From_Address__c = 'accountsreceivable@linuxfoundation.org',            
            Bill_From_City__c = 'San Francisco',                   
            Bill_From_Phone__c = '+1 415-723-9709',               
            Bill_From_State__c = 'CA',                             
            Bill_From_Website__c = 'www.linuxfoundation.org',      
            Bill_From_Zip__c = '94129',                     
            Image_File_for_PDF__c = 'the_linux_foundation_pdf_logo.jpg',            
            Bill_From_Country__c = 'United States',                        
            Include_W9__c = true,                            
            Project_Code__c = 'LF',                         
            Type__c = 'Membership',                                                                                                                                               
            Billfrom_ID__c = 'bf98299e-6a68-0f85-236b-52a0a366caba',                                                                                                                  
            Manual_Status_Check__c = true,
            Project_Entity_Name__c = 'The Linux Foundation',
            Industry__c = 'Non-profit Organizations',
            Model__c = 'Alternate Funding',
            Technology__c = 'Blockchain',
            Technical_Activity_Type__c = 'Open Source Software',
            Description__c = 'description',
            slug__c = 'thelf'
        );
        insert project;
        
        // updating Project Status to Active
        project.Manual_Status_Check__c = false;
        project.Status__c ='Active';
        update project;
        
        Event__c event = new Event__c(Event_Name__c = 'KubeCon',
            Name= 'KubeCon',    // Event Name
            Status__c = 'Complete',                                                                                                                                               
            Category__c = 'LF Event',                                                                                                                                                
            BillFromProject__c = project.id, //ID                                                                                                                                  
            Start_Date__c = system.today() - 20,                                                                                                                          
            Capacity__c = 0,                                                                                                                                         
            End_Date__c = system.today() - 10,                                                                                                                             
            Registration_Source__c = 'RegOnline',                                                                                                                                       
            Event_Location_Name__c = 'Twitter HQ One 10th Street Expansion',                                                                                                 
            Event_Published__c = false,                                                                                                                                         
            Event_Location_Address__c = 'One 10th Street',                                                                                                                       
            Event_Location_City__c = 'San Francisco',                                                                                                                             
            Event_Location_State__c = 'California',                                                                                                                              
            Event_Location_Country__c = 'United States',                                                                                                                          
            Event_Location_Zip__c = '94103',                                                                                                                                      
            Embassy__c = 'US',                                                                                                                                                  
            Cvent_Event_Is_Sandbox__c = false,                                                                                                                                      
            //Type__c = 'Email',                                                                                                                                               
            Netsuite_Sync__c = false );
        insert event;
        System.assert(event.Id != null, 'The Test Event did not insert properly');
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        insert con;
        System.assert(con.Id != null, 'The Test Contact did not insert properly');
        
        Alternate_Email__c alt = new Alternate_Email__c(
        	Alternate_Email_Address__c	= 'abc@gmail.com',
            Contact_Name__c = con.Id,
            Active__c = true
        );
        insert alt;
        System.assert(alt.Id != null, 'The Alternate Email did not insert properly');
        
        Lead lead = new Lead(
            LastName = 'test lead',email='abc1@gmail.com'
        );
        insert lead;
        System.assert(lead.Id != null, 'The Test lead did not insert properly');
        
    }

    public static Travel_Fund_Request__c setUp(String RecordName, Boolean SpecifyTestKeyFirst) {
        Event__c event = [Select ID From Event__c Where Name='KubeCon']; 
        
        Project__c project = [Select ID from Project__c Where Name='The Linux Foundation'];

        Contact contact = new Contact(FirstName='Tux',LastName='Rocks');
        insert contact;
        System.debug('Contact ID is ' + contact.Id);

        Map<String,String> SetupMap = new Map<String,String>{
            'EventId' => event.Id,
            'ContactId' => contact.Id
        };

        Travel_Fund_Request__c request = new Travel_Fund_Request__c(
            Name = RecordName,
            Contact__c = SetupMap.get('ContactId'),
            Event__c = SetupMap.get('EventId')
        );

        if(SpecifyTestKeyFirst) {
            request.Requestor_Key__c = TEST_KEY;
        }

        insert request;
        System.debug('Travel_Fund_Request__c ID is ' + request.Id);

	    Travel_Fund_Request__c requestResult = [select Id, Requestor_Key__c from Travel_Fund_Request__c where Id = :request.Id];
        System.debug('Travel_Fund_Request__c Requestor_Key__c is ' + requestResult.Requestor_Key__c);
        return requestResult;
    }

    @isTest static void RequestKeyIsGenerated() {
        Travel_Fund_Request__c requestResult = setUp('RequestKeyIsGenerated', FALSE);
        System.assert(!String.isBlank(requestResult.Requestor_Key__c), 'testing that a request key is generated');
    }

    @isTest static void ExistingRequestKeyIsRespected() {
        Travel_Fund_Request__c requestResult = setUp('ExistingRequestKeyIsRespected', TRUE);
        System.assertEquals(TEST_KEY, requestResult.Requestor_Key__c, 'testing that an existing request key is respected and kept');
    }
    
    @isTest public static void test1(){
        Event__c event = [Select ID From Event__c Where Name='KubeCon']; 
        
        Travel_Fund_Request__c tfr =new Travel_Fund_Request__c();
        tfr.Name = 'TFR Test';
        tfr.Event__c = event.Id;
        tfr.FirstName__c = 'test firstName';
        tfr.LastName__c = 'test LastName';
        tfr.TFREmail__c = 'abc@gmail.com';
        insert tfr;
        System.assert(tfr.Id != null, 'The Test tfr did not insert properly');
    }
    @isTest public static void test2(){
        Event__c event = [Select ID From Event__c Where Name='KubeCon']; 
        
        Lead lead =[Select ID From Lead Where Email='abc1@gmail.com'];
        
        Alternate_Email__c alt =[Select id from Alternate_Email__c where Lead_Name__c =: lead.Id LIMIT 1];
        System.assert(alt.Id != null, 'The Alternate Email did not insert properly');
        
        Travel_Fund_Request__c tfr =new Travel_Fund_Request__c();
        tfr.Name = 'TFR Test';
        tfr.Event__c = event.Id;
        tfr.Expensify_Approved_Amount__c = 200;
        tfr.Expensify_Paid_Amount__c = 100;
        tfr.FirstName__c = 'test firstName';
        tfr.LastName__c = 'test LastName';
        //tfr.TFREmail__c = 'abc1@gmail.com';
        insert tfr;
        System.assert(tfr.Id != null, 'The Test tfr did not insert properly');
    }
    
    @isTest public static void test3(){
        Event__c event = [Select ID From Event__c Where Name='KubeCon']; 
        
        Travel_Fund_Request__c tfr =new Travel_Fund_Request__c();
        tfr.Name = 'TFR Test';
        tfr.Event__c = event.Id;
        tfr.FirstName__c = 'test firstName';
        tfr.LastName__c = 'test LastName';
        tfr.TFREmail__c = 'abc4@gmail.com';
        insert tfr;
        System.assert(tfr.Id != null, 'The Test tfr did not insert properly');
    }
    
    @isTest public static void test4(){
        Event__c event = [Select ID From Event__c Where Name='KubeCon']; 
        
        Travel_Fund_Request__c tfr =new Travel_Fund_Request__c();
        tfr.Name = 'TFR Test';
        tfr.Event__c = event.Id;
        tfr.FirstName__c = 'test firstName';
        tfr.LastName__c = 'test LastName';
        tfr.TFREmail__c = 'abc@gmail.com';
        insert tfr;
        
        tfr.Amount_Approved__c = 1000;
        tfr.Status__c='Request Approved - Waiting For Expense Report';
        update tfr;
        
        tfr.Status__c = 'Expense Report Approved';
        update tfr;
        System.assert(tfr.Id != null, 'The Test tfr did not insert properly');
    }
    
    @isTest public static void test5(){
        Event__c event = [Select ID From Event__c Where Name='KubeCon']; 
        
        Travel_Fund_Request__c tfr =new Travel_Fund_Request__c();
        tfr.Name = 'TFR Test';
        tfr.Event__c = event.Id;
        tfr.FirstName__c = 'test firstName';
        tfr.LastName__c = 'test LastName';
        tfr.TFREmail__c = 'xyz@gmail.com';
        tfr.Title__c = 'abc';
        insert tfr;
        System.assert(tfr.Id != null, 'The Test tfr did not insert properly');
    }
    
    @isTest public static void test6(){
        Event__c event = [Select ID From Event__c Where Name='KubeCon']; 
        
        Travel_Fund_Request__c tfr =new Travel_Fund_Request__c();
        tfr.Name = 'TFR Test';
        tfr.Event__c = event.Id;
        tfr.FirstName__c = 'test firstName';
        tfr.LastName__c = 'test LastName';
        tfr.TFREmail__c = 'abc@gmail.com';
        tfr.Title__c = 'abc';
        tfr.Office_phone__c = '12345';
        tfr.mailing_Address1__c = 'Test Street';
        tfr.City__c = 'Test City';
        tfr.State__c = 'Test State';
        tfr.Country__c = 'Test Country';
        tfr.DateofBirth__c = System.today();
        insert tfr;
        System.assert(tfr.Id != null, 'The Test tfr did not insert properly');
    }
    
     @isTest public static void test7(){
        Event__c event = [Select ID From Event__c Where Name='KubeCon']; 
        
        Travel_Fund_Request__c tfr =new Travel_Fund_Request__c();
        tfr.Name = 'TFR Test';
        tfr.Event__c = event.Id;
        tfr.FirstName__c = 'test firstName';
        tfr.LastName__c = 'test LastName';
        tfr.TFREmail__c = 'abc@gmail.com';
        tfr.Expensify_Approved_Amount__c = 1000;
        tfr.Amount_Approved__c = 1000;
        insert tfr;
        System.assert(tfr.Id != null, 'The Test tfr did not insert properly');
         
        delete tfr;
         
        undelete tfr;
    }
    
    @isTest public static void updatePreviousApprovals_Test(){
        Event__c event = [Select ID From Event__c Where Name='KubeCon']; 
        
        Project__c project = [Select ID from Project__c Where Name='The Linux Foundation'];
        
        Contact con = [Select ID From Contact Where LastName='Test Contact'];
        
        Event__c event2 = new Event__c();
        event2.Name = 'Test Event 2';
        event2.Category__c = 'Project Event';
        event2.BillFromProject__c = project.id;
        insert event2;
        
        Travel_Fund_Request__c tfr =new Travel_Fund_Request__c();
        tfr.Name = 'TFR Test';
        tfr.Event__c = event.Id;
        tfr.FirstName__c = 'test firstName';
        tfr.LastName__c = 'test LastName';
        tfr.Contact__c = con.Id;
        tfr.First_Approval__c = 'Yes';
        tfr.Title__c = 'abc';
        insert tfr;
        System.assert(tfr.Id != null, 'The Test tfr did not insert properly');
        
        Travel_Fund_Request__c tfReq =new Travel_Fund_Request__c();
        tfReq.Name = 'TFR Test 2';
        tfReq.Event__c = event2.Id;
        tfReq.FirstName__c = 'test firstName 2';
        tfReq.LastName__c = 'test LastName 2';
        tfReq.Contact__c = con.Id;
        tfReq.Title__c = 'abc 2';
        insert tfReq;
        System.assert(tfReq.Id != null, 'The Test tfr did not insert properly');
    }
}