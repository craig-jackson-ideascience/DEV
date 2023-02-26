/**
 * Test class for VisaRequestTriggerHandler
 */
@isTest
public class VisaRequestTriggerHandlerTest {
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
            Slug__c = 'testing',
            Model__c = 'Alternate Funding',
            Billfrom_ID__c = 'bf98299e-6a68-0f85-236b-52a0a366caba',                                                                                                                  
            Manual_Status_Check__c = true                                                                                                                                            
        );
        insert project;
        
        // updating Project Status to Active
        project.Manual_Status_Check__c = false;
        project.Status__c ='Active';
        update project;
        
        // Create event
        Event__c event = new Event__c(Event_Name__c = 'KubeCon',
                                      Name= 'KubeCon',    
                                      Status__c = 'Complete',                                                                                                                                                 
                                      Category__c = 'LF Event',                                                                                                                                                
                                      BillFromProject__c = project.id,                                                                                                                                
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
        
        // create contact
        Contact con = new Contact();
        con.LastName = 'Test Contact';
		con.Email = 'abc@gmail.com';
        insert con;
        System.assert(con.Id != null, 'The Test Contact did not insert properly');
        
        Lead lead = new Lead(
            LastName = 'test lead',
            Email = 'abc1@gmail.com',
            Company ='Test Account'
        );
        insert lead;
        System.assert(lead.Id != null, 'The Test lead did not insert properly');
        
    }
    
    @isTest public static void contactInsertIfEmailPresent_Test(){
        
        Contact con =[Select Id from Contact Where Email='abc@gmail.com'];
        
        Event__c event = [Select Id from Event__c Where Name='KubeCon'];
 
        Event_Registrations__c eventReg = new Event_Registrations__c();
        eventReg.Name = 'test eventregis';
        eventReg.Contact__c = con.Id;
        eventReg.Event__c = event.Id;
        eventReg.Data_Source__c = 'Cvent';
        eventReg.Cvent_Registration_Status__c = 'Accepted';
        insert eventReg;
        
        Visa_Request__c visaReq =new Visa_Request__c();
        visaReq.Name = 'visa Test';
        visaReq.Event__c = event.Id;
        visaReq.FirstName__c = 'test firstName';
        visaReq.LastName__c = 'test LastName';
        visaReq.ContactEmail__c = 'abc@gmail.com';
        visaReq.Register_Event__c = true;
        insert visaReq;
        System.assert(visaReq.Id != null, 'The Test visaReq did not insert properly');
    }
    
    @isTest public static void contactInsertIfEmailPresentForLead_Test(){
        
        Contact con =[Select Id from Contact Where Email='abc@gmail.com'];
        
        Event__c event = [Select Id from Event__c Where Name='KubeCon'];
         
        Visa_Request__c visaReq =new Visa_Request__c();
        visaReq.Name = 'visaReq Test';
        visaReq.Event__c = event.Id;
        visaReq.FirstName__c = 'test firstName';
        visaReq.LastName__c = 'test LastName';
        visaReq.ContactEmail__c = 'abc@gmail.com';
        visaReq.Register_Event__c = true;
        
        try{
            insert visaReq;
        }
        catch(Exception e)
        {
            String message = e.getMessage();
            system.assert(message.contains('No event registration found'), 'message=' + message);
            
        }
    }
     
    @isTest public static void validateContactRegistration_Test(){
       
        Contact cont =[Select Id from Contact Where Email='abc@gmail.com'];
        
        Event__c event = [Select Id from Event__c Where Name='KubeCon'];   
        
        Event_Registrations__c eventReg = new Event_Registrations__c();
        eventReg.Name = 'test eventregis';
        eventReg.Contact__c = cont.Id;
        eventReg.Event__c = event.Id;
        eventReg.Data_Source__c = 'Cvent';
        eventReg.Cvent_Registration_Status__c = 'Accepted';
        insert eventReg;
        
        Visa_Request__c visaReq =new Visa_Request__c();
        visaReq.Name = 'vr Test';
        visaReq.Event__c = event.Id;
        visaReq.FirstName__c = 'test firstName';
        visaReq.LastName__c = 'test LastName';
        visaReq.Contact__c = cont.Id;
        insert visaReq;
        System.assert(visaReq.Id != null, 'The Test visaReq did not insert properly');
        
        System.assertEquals(TRUE, [SELECT Registered__c FROM Visa_Request__c WHERE Contact__c =: cont.Id][0].Registered__c,'The visa Request not registered properly');
    }
    
    @isTest public static void updateVisaOrgpay_Test(){
        
        Contact cont =[Select Id from Contact Where Email='abc@gmail.com'];
        
        Event__c event = [Select Id from Event__c Where Name='KubeCon'];
        
        Event_Registrations__c eventReg = new Event_Registrations__c();
        eventReg.Name = 'test eventregis';
        eventReg.Contact__c = cont.Id;
        eventReg.Event__c = event.Id;
        eventReg.Data_Source__c = 'Cvent';
        eventReg.Cvent_Registration_Status__c = 'Accepted';
        insert eventReg;
        
        Visa_Request__c visaReq =new Visa_Request__c();
        visaReq.Name = 'vr Test';
        visaReq.FirstName__c = 'test firstName';
        visaReq.LastName__c = 'test LastName visa';
        visaReq.Company_or_Organization__c = 'Linux';
        visaReq.Accommodation_Paid_by__c = 'Delegate';
        visaReq.Contact__c = cont.Id;
        visaReq.Event__c = event.Id;
        visaReq.Register_Event__c = true;
        insert visaReq;
        System.assert(visaReq.Id != null, 'The Test visaReq did not insert properly');
        System.assertEquals('Linux', [SELECT Org_paying_for_your_travel__c FROM Visa_Request__c WHERE LastName__c = 'test LastName visa'].Org_paying_for_your_travel__c,'Visa Request Paying Org Not populated correctly');
    }
}