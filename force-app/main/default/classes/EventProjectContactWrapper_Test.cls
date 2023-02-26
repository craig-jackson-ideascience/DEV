@isTest
public class EventProjectContactWrapper_Test {
    
    @isTest
    static void sortyByProjectRole(){
        Asset ast =  TestFactory.getAsset();
        Contact con2 = new Contact();
        con2.LastName = 'Phil';
        con2.FirstName ='Wright';
        insert con2;
        Project_Role__c projRole1 = new Project_Role__c(Contact__c = con2.Id, Role__c = 'Representative/Voting Contact', Asset__c = ast.Id);
        Project_Role__c projRole2 = new Project_Role__c(Contact__c = con2.Id, Role__c = 'Marketing Contact', Asset__c = ast.Id);
        Project_Role__c projRole3 = new Project_Role__c(Contact__c = con2.Id, Role__c = 'Marketing Contact', Asset__c = ast.Id,PrimaryContact__c = true);

        List<EventProjectContactWrapper> wrapper = new List<EventProjectContactWrapper>();
        wrapper.add(new EventProjectContactWrapper(null,projRole1,con2));   
        wrapper.add(new EventProjectContactWrapper(null,projRole2,con2));   
        wrapper.add(new EventProjectContactWrapper(null,projRole3,con2)); 
        
        EventProjectContactWrapper.compareField = 'projRole.PrimaryContact__c';
        EventProjectContactWrapper.sortOrder = 'ASC';
        wrapper.sort();
        
        EventProjectContactWrapper.compareField = 'projRole.Asset__r.Projects__r.Name';
        EventProjectContactWrapper.sortOrder = 'ASC';
        wrapper.sort();
        System.assertEquals('Representative/Voting Contact', wrapper[0].projRole.Role__c);

        EventProjectContactWrapper.compareField = 'projRole.Role__c';
        EventProjectContactWrapper.sortOrder = 'ASC';
        wrapper.sort();
        System.assertEquals('Marketing Contact', wrapper[0].projRole.Role__c);
        
        
    }
    
    @isTest
    static void sortyByContact(){
        List<EventProjectContactWrapper> wrapper = new List<EventProjectContactWrapper>();
        Contact cnt = new Contact(LastName = 'Name',FirstName='test',MailingCountry = 'US',HasOptedOutOfEmail= true);
        Contact cnt1 = new Contact(LastName = 'Name2',FirstName='test2',MailingCountry='EU',HasOptedOutOfEmail =false,Email='test1@12.com');
        Contact cnt2 = new Contact(LastName = 'Name1',FirstName='test',MailingCountry='US');
        Contact cnt3 = new Contact(LastName = 'Name',FirstName='test1',Email ='test@test.com');
        
        
        wrapper.add(new EventProjectContactWrapper(null,null,cnt));   
        wrapper.add(new EventProjectContactWrapper(null,null,cnt1));
        wrapper.add(new EventProjectContactWrapper(null,null,cnt2));            
        wrapper.add(new EventProjectContactWrapper(null,null,cnt3));            
        
        
        EventProjectContactWrapper.compareField = 'cnt.Name';
        EventProjectContactWrapper.sortOrder = 'ASC';
        wrapper.sort();
        System.assertEquals(null, wrapper[0].cnt.Name);
        
        EventProjectContactWrapper.compareField = 'cnt.LastName';
        wrapper.sort();
        System.assertEquals('Name', wrapper[0].cnt.LastName);
        
        EventProjectContactWrapper.compareField = 'cnt.FirstName';
        wrapper.sort();
        System.assertEquals('test', wrapper[0].cnt.FirstName);
        
        EventProjectContactWrapper.compareField = 'cnt.MailingCountry';
        wrapper.sort();
        System.assertEquals(null, wrapper[0].cnt.MailingCountry);
        
        EventProjectContactWrapper.compareField = 'cnt.Email';
        wrapper.sort();
        
        EventProjectContactWrapper.compareField = 'cnt.HasOptedOutOfEmail';
        wrapper.sort();
    }
    
    @isTest
    static void sortyByEvent(){
        List<EventProjectContactWrapper> wrapper = new List<EventProjectContactWrapper>();
        Project__c prj = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Directed Fund', 'Planned');
        prj.Subsidiary_ID__c = 8;
        prj.Status__c = 'Active';
        prj.Funding__c = 'Funded';
        update prj;
        
        Event__c evt = TestDataUtils.createEvent(false, 'Test Event', 'Unfunded', 'LF Event', 'Planned');
        evt.BillFromProject__c = prj.Id;
        evt.Event_Location_Country__c = 'United Kingdom';
        
        Event__c evt1 = TestDataUtils.createEvent(false, 'Test Event1', 'Unfunded', 'LF Event', 'Planned');
        evt.BillFromProject__c = prj.Id;
        evt.Event_Location_Country__c = 'United States';
        
        Event__c evt2 = TestDataUtils.createEvent(false, 'Test Event2', 'Unfunded', 'LF Event', 'Planned');
        evt.BillFromProject__c = prj.Id;
        evt.Event_Location_Country__c = 'United Kingdom';
        
        
        wrapper.add(new EventProjectContactWrapper(evt,null,null));
        wrapper.add(new EventProjectContactWrapper(evt1,null,null));
        wrapper.add(new EventProjectContactWrapper(evt2,null,null));
        
        
        EventProjectContactWrapper.compareField = 'event.Name';
        EventProjectContactWrapper.sortOrder = 'ASC';
        wrapper.sort();
        System.assertEquals('Test Event', wrapper[0].event.Name);
        
        EventProjectContactWrapper.compareField = 'event.Start_Date__c';
        EventProjectContactWrapper.sortOrder = 'ASC';
        wrapper.sort();
        System.assertEquals('Test Event', wrapper[0].event.Name);
        
        EventProjectContactWrapper.compareField = 'event.Event_Location_Country__c';
        EventProjectContactWrapper.sortOrder = 'ASC';
        wrapper.sort();        
    }
    
    
    
}