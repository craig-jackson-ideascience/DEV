@IsTest
private class Chart_LeadSubmissionControllerTest {
    @TestSetup
    static void testSetup(){
        Project__c parentProj = new Project__c(Name = 'Parent project', slug__c = 'parent');
        insert parentProj;
        
        Project__c proj = new Project__c(Name = 'testProject1', Project_Status__c='Active', Category__c='Subproject');
        proj.Slug__c = 'testproj';
        proj.Funding__c = 'Unfunded';
        proj.Project_Entity_Name__c = 'The Linux Foundation';
        proj.Start_Date__c = system.today();
        proj.Industry__c = 'Non-profit Organizations';
        proj.Model__c = 'Alternate Funding';
        proj.Technology__c = 'Blockchain';
        proj.Technical_Activity_Type__c = 'Open Source Software';
        proj.Description__c = 'description';
        proj.Parent_Entity_Relationship__c = parentProj.Id;
        proj.Parent_Project__c = parentProj.Id;
        insert proj;
        Account account = new Account(Name = 'TestAbc');
        insert account;
        List<Lead> listOfLead = new List<Lead>();
        for (Integer i = 0; i < 2; i++) {
            String leadEmail = 'testlead' + i + '@gmail.com';
            Lead lead = new Lead(FirstName = 'Test', LastName = 'leadTest' + i, Company = 'TestLeadCompany' + i, Status = 'Unqualified', Email = leadEmail, LeadSource = 'Event');
            listOfLead.add(lead);
        }
        insert listOfLead;
        Campaign camp = new Campaign();
            camp.Name ='Test Subscription Center';
            camp.Description ='Test for Email Opt Out';
            camp.Project__c = proj.Id;
            camp.Type ='Subscription Center';
            camp.Status ='In Progress';
            camp.StartDate = Date.today();
            camp.IsActive = true;
            camp.Add_to_Subscription_Center__c = true;
	        camp.Technology__c ='System Administration';
            insert camp;
            List<CampaignMember> listOfcampMember = new List<CampaignMember>();
        for (Integer i = 0; i < 2; i++) {
            CampaignMember campMember = new CampaignMember();
            campMember.CampaignID = camp.Id;
            campMember.LeadId = listOfLead[i].Id;
            campMember.Status = 'Subscribed';
            listOfcampMember.add(campMember);
        }
        insert listOfcampMember;
    }
    
    @IsTest
    static void getSelectedProjectDetailsTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        Project__c result = Chart_LeadSubmissionController.getSelectedProjectDetails(proj.Id);
        System.assertEquals(proj.Id, result.Id);
        
    }

    @IsTest
     static void getLeadDetailsTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];   
        List<String> leadSource = new List<String>{'Event'};  
        List<String> selectedDates=new List<String>{'2021-02-22', '2021-03-22'};
        String result = Chart_LeadSubmissionController.getLeadDetails(proj.Id, leadSource, '', 'between', selectedDates);
        System.assertNotEquals(null, result);  
    }

    @IsTest
     static void getLeadDetailsLessThanTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];   
        List<String> leadSource = new List<String>{'Event'};  
        List<String> selectedDates=new List<String>{'2021-02-22', '2021-03-22'};
        String result = Chart_LeadSubmissionController.getLeadDetails(proj.id, leadSource, '', 'lessThanEqual', selectedDates);
        System.assertNotEquals(null, result);
     }

     @IsTest
     static void getLeadDetailsGreaterThanTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];   
        List<String> leadSource = new List<String>{'Event'};  
        List<String> selectedDates=new List<String>{'2021-02-22', '2021-03-22'};
        String result = Chart_LeadSubmissionController.getLeadDetails(proj.id, leadSource, '', 'greaterThanEqual', selectedDates);
        System.assertNotEquals(null, result);
     }

     @IsTest
     static void getLeadDetailsEqualsLessTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];   
        List<String> leadSource = new List<String>{'Event'};  
        List<String> selectedDates=new List<String>{'2021-02-22', '2021-03-22'};
        String result = Chart_LeadSubmissionController.getLeadDetails(proj.id, leadSource, '', 'equalLessThan', selectedDates);
        System.assertNotEquals(null, result);
     }

     @IsTest
     static void getLeadDetailsEqualsTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];   
        List<String> leadSource = new List<String>{'Event'};  
        List<String> selectedDates=new List<String>{'2021-02-22', '2021-03-22'};
        String result = Chart_LeadSubmissionController.getLeadDetails(proj.id, leadSource, '', 'equal', selectedDates);
        System.assertEquals(null, result);
     }

    @IsTest
     static void getLeadTableDetailsTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        List<String> selectedDates=new List<String>{'THIS_YEAR'};
        List<String> leadSource = new List<String>{'Event'};  
        Chart_LeadSubmissionController.ReturnLeadWrapper result = Chart_LeadSubmissionController.getLeadTableDetails(proj.id, leadSource, null, 'equal', selectedDates, '', 'Event', 'equal', false, false);
        System.assertEquals(2, result.leadWrapper.size());
     }

     @IsTest
     static void getLeadTableDetailsGTTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        List<String> selectedDates=new List<String>{'THIS_Year'};
        List<String> leadSource = new List<String>{'Event'};  
        Chart_LeadSubmissionController.ReturnLeadWrapper result = Chart_LeadSubmissionController.getLeadTableDetails(proj.id, leadSource, null, 'equalLessThan', selectedDates, '', '["Event"]', 'greaterThanEqual', true, true);
        System.assertEquals(2, result.leadWrapper.size());
     }

     @IsTest
     static void getLeadTableDetailsLTTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        List<String> selectedDates=new List<String>{'2021-02-22', '2021-03-22'};
        List<String> leadSource = new List<String>{'Event'};  
            Chart_LeadSubmissionController.ReturnLeadWrapper result = Chart_LeadSubmissionController.getLeadTableDetails(proj.id, leadSource, '"march"', 'lessThanEqual', selectedDates, null, 'Event', 'lessThanEqual', false, false);
        System.assertEquals(0, result.leadWrapper.size());
     }

     @IsTest
     static void getLeadTableDetailsEqualsLessTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        List<String> selectedDates=new List<String>{'2021-02-22', '2021-03-22'};
        List<String> leadSource = new List<String>{'Event'};  
        Chart_LeadSubmissionController.ReturnLeadWrapper result = Chart_LeadSubmissionController.getLeadTableDetails(proj.id, leadSource, null, 'between', selectedDates, null, 'Event', 'equalLessThan', false, false);
        System.assertEquals(0, result.leadWrapper.size());
     }     
   
     @IsTest
     static void getLeadTableDetailsFQTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        List<String> selectedDates=new List<String>{'THIS_Fiscal_Quarter'};
        List<String> leadSource = new List<String>{'Event'};  
        Chart_LeadSubmissionController.ReturnLeadWrapper result = Chart_LeadSubmissionController.getLeadTableDetails(proj.id, leadSource, null, 'equalLessThan', selectedDates, '', '["Event"]', 'greaterThanEqual', true, true);
        System.assertEquals(2, result.leadWrapper.size());
     }

     @IsTest
     static void getLeadTableDetailsFYTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        List<String> selectedDates=new List<String>{'THIS_Fiscal_Year'};
        List<String> leadSource = new List<String>{'Event'};  
        Chart_LeadSubmissionController.ReturnLeadWrapper result = Chart_LeadSubmissionController.getLeadTableDetails(proj.id, leadSource, null, 'equalLessThan', selectedDates, '', '["Event"]', 'greaterThanEqual', true, true);
        System.assertEquals(2, result.leadWrapper.size());
     }

     @IsTest
     static void getLeadTableDetailsQuarterTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        List<String> selectedDates=new List<String>{'THIS_Quarter'};
        List<String> leadSource = new List<String>{'Event'};  
        Chart_LeadSubmissionController.ReturnLeadWrapper result = Chart_LeadSubmissionController.getLeadTableDetails(proj.id, leadSource, null, 'equalLessThan', selectedDates, '', '["Event"]', 'greaterThanEqual', true, true);
        System.assertEquals(2, result.leadWrapper.size());
     }

     @IsTest
     static void getLeadTableDetailsMonthTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        List<String> selectedDates=new List<String>{'THIS_Month'};
        List<String> leadSource = new List<String>{'Event'};  
        Chart_LeadSubmissionController.ReturnLeadWrapper result = Chart_LeadSubmissionController.getLeadTableDetails(proj.id, leadSource, null, 'equalLessThan', selectedDates, '', '["Event"]', 'greaterThanEqual', true, true);
        System.assertEquals(2, result.leadWrapper.size());
     }

     @IsTest
     static void getLeadTableDetailsDefaultTest(){
        Project__c proj = [SELECT Id FROM Project__c where slug__c = 'testproj'];
        List<String> selectedDates=new List<String>();
        List<String> leadSource = new List<String>{'Event'};  
        Chart_LeadSubmissionController.ReturnLeadWrapper result = Chart_LeadSubmissionController.getLeadTableDetails(proj.id, leadSource, null, '', selectedDates, '', '["Event"]', 'greaterThanEqual', true, true);
        System.assertEquals(2, result.leadWrapper.size());
     }

}