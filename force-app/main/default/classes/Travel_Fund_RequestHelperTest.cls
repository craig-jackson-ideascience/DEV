/**
 * Test class for Travel_Fund_RequestHelper
 */
@isTest
public class Travel_Fund_RequestHelperTest {
    /**
	 *testSetup: create the required data for testing
	 */
     @testSetup static void setup(){
        // create project
        Project__c project = new Project__c(
            Name = 'The Linux Foundation',       
            Status__c = 'Planned', 
            Funding__c ='Funded',
            Model__c ='Membership',
            Slug__c = 'tlf_test',
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
            Manual_Status_Check__c = true                                                                                                                                            
        );
        insert project;
        
        // updating Project Status to Active
        project.Manual_Status_Check__c = false;
        project.Status__c ='Active';
        update project;
        
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

    /**
	 * CongaComposerInvocationTest: test method for Travel_Fund_RequestHelper
	 */
    @isTest static void CongaComposerInvocationTest() {
        Travel_Fund_Request__c request = new Travel_Fund_Request__c();
        Travel_Fund_RequestHelper helper = new Travel_Fund_RequestHelper();
        Boolean result = helper.CongaComposerInvocation(request, 'TestName');
        System.assertEquals(TRUE, result, 'CongaComposerInvocation should have returned true');
    }
	/**
	 * CongaComposerContinuationHandlerTest: test method for Travel_Fund_RequestHelper
	 */
    @isTest static void CongaComposerContinuationHandlerTest() {
        Travel_Fund_Request__c requestResult = Travel_Fund_RequestTest.setUp('CongaComposerContinuationHandlerTest', FALSE);
        Travel_Fund_RequestHelper helper = new Travel_Fund_RequestHelper();
        helper.CongaComposerContinuationHandler();
        System.assertNotEquals(null, requestResult.Id, 'CongaComposerContinuationHandlerTest should have returned true');
    }
}