public class ProductDetail_Action {

    // When Product Detail is inserted in association with Project/Event/Training object, 
    // then fetch netsuite detail from associated Project/Event/Training
    // and update netsuite fields on Product Detail object   
    public void populateNetSuiteFields(List<Product_Details__c> incomingProductDetails) {

        Set<Id> eventIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> trainingIdSet = new Set<Id>();
        Map<Id, Event__c> eventRecords = new Map<Id, Event__c>();
        Map<Id, Project__c> projectRecords = new Map<Id, Project__c>();
        Map<Id, Training__c> trainingRecords = new Map<Id, Training__c>();
        List<Id> productIds = new List<Id>();
        Map<Id, Product2> productRecords = new Map<Id, Product2>();

        //Id directedProjectId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Directed Fund').getRecordTypeId();

        //system.debug('_____directedProjectId____' + directedProjectId);

        for (Product_Details__c pd : incomingProductDetails) {

            if (pd.Event__c != null)
                eventIdSet.add(pd.Event__c); else if (pd.Project__c != null)
                projectIdSet.add(pd.Project__c); else if (pd.Training__c != null)
                trainingIdSet.add(pd.Training__c);

            if (pd.Products__c != null)
                productIds.add(pd.Products__c);
        }

        if (!eventIdSet.isEmpty()) {
            eventRecords = new Map<Id, Event__c>([Select Id,NS_Revenue_Schedule__c, job_code__c,NS_Deferred_Revenue_Account__c, NS_Department__c, NetSuite_Class__c, NS_Income_GL_Account__c 
                                                  from Event__c where Id In :eventIdSet]);
        }

        if (!projectIdSet.isEmpty()) {
            projectRecords = new Map<Id, Project__c>([Select Id,job_code__c, Status__c, Renewal_Type__c,LF_Membership_Required__c,
                                                      Project_Code__c,Category__c ,NS_Deferred_Revenue_Account__c, NS_Department__c, 
                                                      NetSuite_Class__c, NS_Income_GL_Account__c from Project__c where Id In :projectIdSet]);
            // and RecordTypeId = :directedProjectId 
        }

        if (!trainingIdSet.isEmpty()) {
            trainingRecords = new Map<Id, Training__c>([Select Id, NS_Deferred_Revenue_Account__c, NS_Department__c, NetSuite_Class__c, NS_Income_GL_Account__c from Training__c 
                                                        where Id In :trainingIdSet]);
        }

        if (!productIds.isEmpty()) {
            productRecords = new Map<Id, Product2>([Select Id, name, NetSuite_Revenue_Schedule__c, Tax_Class__c from Product2 where Id In:productIds]);
        }

        system.debug('____projectRecords____' + projectRecords);
        system.debug('**event records---' + eventRecords);
        system.debug('incomingProductDetails' + incomingProductDetails);

        for (Product_Details__c pd : incomingProductDetails) {

            String class_str;
            String department;
            String RevenueAccount;
            String GLAccount;
            String JobCode;
            String RevenueSchedule;
            
            if (pd.Event__c != null && eventRecords.size() > 0 && eventRecords.containsKey(pd.Event__c)) {
                system.debug('I am in');
                Event__c event = eventRecords.get(pd.Event__c);
                class_str = event.NetSuite_Class__c ;
                department = event.NS_Department__c ;
                RevenueAccount =event.NS_Deferred_Revenue_Account__c ;
                GLAccount = event.NS_Income_GL_Account__c ;
                JobCode = event.job_code__c ;
                RevenueSchedule = event.NS_Revenue_Schedule__c ;
            } else if (pd.Project__c != null && projectRecords.size() > 0 && projectRecords.containsKey(pd.Project__c)) {
                Project__c project = projectRecords.get(pd.Project__c);
                if (project.LF_Membership_Required__c) {//for directed fund
                    System.debug('in----');
                    class_str = project.NetSuite_Class__c;
                    department = project.NS_Department__c;
                    RevenueAccount = project.NS_Deferred_Revenue_Account__c ;
                    GLAccount = project.NS_Income_GL_Account__c ;
                    JobCode = project.job_code__c ;
                    // pd.Project_Code__c = projectRecords.get(pd.Project__c).Project_Code__c;
                    // pd.SubsidiaryID__c = projectRecords.get(pd.Project__c).Subsidiary_ID__c;            
                    //pd.Status__c = projectRecords.get(pd.Project__c).Status__c; 
                    pd.Renewal_Type__c = project.Renewal_Type__c;
                    RevenueSchedule = '29';
                    pd.NS_Revenue_Schedule__c = '29';
                    System.debug(pd);
                    //pd.Number_of_Years_Required__c = projectRecords.get(pd.Project__c).Number_of_Years_Required__c;
                }else if(project.Category__c == 'Incorporated Entity'){ //for incorporated projects
                    department = project.NS_Department__c;
                    RevenueAccount = project.NS_Deferred_Revenue_Account__c ;
                   	JobCode = project.job_code__c ;
                    //pd.SubsidiaryID__c = projectRecords.get(pd.Project__c).Subsidiary_ID__c;
                    RevenueSchedule = '6';
                    pd.NS_Revenue_Schedule__c = '6';
                    pd.Project_Code__c = project.Project_Code__c;
                }
                /* if(pd.Products__c!=null && productRecords.size()>0 && productRecords.containsKey(pd.Products__c)){

pd.Number_of_Years_Required__c = productRecords.get(pd.Products__c).Number_of_Years_Required__c;
}*/

            } else if (pd.Training__c != null && trainingRecords.size() > 0 && trainingRecords.containsKey(pd.Training__c)) {
                class_str =  String.IsNotEmpty(pd.NetSuite_Class__c) ?pd.NetSuite_Class__c :trainingRecords.get(pd.Training__c).NetSuite_Class__c;
                department = String.IsNotEmpty(pd.NS_Department__c) ?pd.NS_Department__c :trainingRecords.get(pd.Training__c).NS_Department__c ;
                RevenueAccount = String.IsNotEmpty(pd.NS_Deferred_Revenue_Account__c) ?pd.NS_Deferred_Revenue_Account__c :trainingRecords.get(pd.Training__c).NS_Deferred_Revenue_Account__c ;
                GLAccount = String.IsNotEmpty(pd.NS_Income_GL_Account__c) ?pd.NS_Income_GL_Account__c :trainingRecords.get(pd.Training__c).NS_Income_GL_Account__c ;
                //JobCode = trainingRecords.get(pd.Training__c).job_code__c ;
            }

            
                pd.NetSuite_Class__c = class_str;
                pd.NS_Department__c = department;
                pd.NS_Deferred_Revenue_Account__c = RevenueAccount;
                pd.NS_Income_GL_Account__c = GLAccount;
                pd.job_code__c = JobCode;
                pd.NS_Revenue_Schedule__c = String.IsEmpty(pd.NS_Revenue_Schedule__c) ? RevenueSchedule : pd.NS_Revenue_Schedule__c;
                //
                system.debug('*pd*' + pd);
                //pd.Project_Code__c = projectRecords.get(pd.Project__c).Project_Code__c;
                //pd.SubsidiaryID__c = projectRecords.get(pd.Project__c).Subsidiary_ID__c;
            

            if (pd.Products__c != null && productRecords.size() > 0 && productRecords.containsKey(pd.Products__c)) {
                //pd.NS_Revenue_Schedule__c = productRecords.get(pd.Products__c).NetSuite_Revenue_Schedule__c;
                pd.Tax_Class__c = productRecords.get(pd.Products__c).Tax_Class__c;
            }

            system.debug('**pd**' + pd);
        }
    }


    public void sendEmailtoEvents(List<Product_Details__c> productDetails) {
        Set<Id> eventsSet = new Set<Id>();
        for (Product_Details__c pd : productDetails) {
            if(pd.Event__c != null){
                eventsSet.add(pd.Event__c);
            }            
        }
        
        if(!eventsSet.isEmpty()){
            EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Alert_Finance_of_New_Event'];
            List<Event__c> eventsProductDetailsList = [
                SELECT Id, Name, Email_Sent__c,BillFromProject__c
                FROM Event__c
                WHERE Id IN :eventsSet AND Status__c = 'Planned'
                AND Email_Sent__c = False
            ];
        //String emailId = Label.Product_Details_Email;
        List<Event__c> eventsToUpdate = new List<Event__c>();


        /*List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN (SELECT Id FROM Group WHERE DeveloperName = :Label.ProductDetailsGroupName)];
        System.debug(groupMembers + '  ===> groupMembers');
        Set<Id> userIdSet = new Set<Id>();
        for (GroupMember gm : groupMembers) {
            if (gm.UserOrGroupId != null && String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                userIdSet.add(gm.UserOrGroupId);
            }
        }
        System.debug(userIdSet + '  ===> userIdSet');
        List<User> users = [SELECT Id, Email FROM User WHERE Id IN :userIdSet];*/
        List<String> sendTo = Utility.getEmailAddresses(Label.ProductDetailsGroupName);
        /*for (User u : users) {
            if (u.Email != null) {
                sendTo.add(u.Email);
            }
        }
        System.debug(sendTo + '  ===> sendTo');*/
        if (sendTo.size() > 0) {
            for (Event__c evt : eventsProductDetailsList) {

                Boolean emailSuccess = sendMail(sendTo, evt, et);
                if (emailSuccess) {
                    evt.Email_Sent__c = true;
                    eventsToUpdate.add(evt);
                }
            }
            update eventsToUpdate;
        }
    }
    }

    public boolean sendMail(List<String> sendTo, Event__c evt, EmailTemplate et) {
        Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(et.Id, UserInfo.getUserId(), evt.Id);

        email.setOrgWideEmailAddressId(orgWideEmailAddress);
        email.setToAddresses(sendTo);

        email.setSaveAsActivity(false);
        try {

            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    email
            });
            System.debug('Email Result : ' + emailResult);
            return emailResult[0].isSuccess();
        } catch (Exception e) {
            System.debug('Exception : ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
            return false;
        }
    }


}