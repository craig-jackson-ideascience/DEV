@isTest
public class MeetingAttendeeTriggerHandlerTest {
    
    public static testmethod void TestDataSetup(){        
        Meeting__c objMeeting = new Meeting__c(
            Name='Test Meeting',
            Subject__c='Test Subject',
            Meeting_Detail__c='Discussion',
            StartDate__c=Date.today(),
            EndDate__c=Date.today(),
            Type__c ='Webinar',
            StartTime__c=Time.newInstance(18, 30, 2, 00),
            EndTime__c=Time.newInstance(19, 30, 2, 00));
        insert objMeeting;
        
        Alternate_Email__c objAlEmail = new Alternate_Email__c(
        Alternate_Email_Address__c ='abc@sforce.com'
        );
        insert objAlEmail;
        
        Meeting_Attendees__c objMeetingAttendees = new Meeting_Attendees__c(
            Meeting__c =objMeeting.id,
             Contact__c = TestFactory.getContact().id ,
            Alternate_Email__c = objAlEmail.id);
           
        insert objMeetingAttendees;
		System.assertEquals(1,[SELECT count() FROM CampaignMember WHERE ContactID =:objMeetingAttendees.Contact__c ]  );      
       
    }
    public static testmethod void TestDataSetup1(){
       
        Meeting__c objMeeting = new Meeting__c(
            Name='Test Meeting',
            Subject__c='Test Subject',
            Meeting_Detail__c='Discussion',
            StartDate__c=Date.today()-10,
            EndDate__c=Date.today()-7,
            Type__c ='Webinar',
            StartTime__c=Time.newInstance(18, 30, 2, 00),
            EndTime__c=Time.newInstance(19, 30, 2, 00));
        insert objMeeting;
        
        Alternate_Email__c objAlEmail = new Alternate_Email__c(
        Alternate_Email_Address__c ='abc@sforce.com'
        );
        insert objAlEmail;
        
        Meeting_Attendees__c objMeetingAttendees = new Meeting_Attendees__c(
            Meeting__c =objMeeting.id,
            Contact__c = TestFactory.getContact().id ,
            Alternate_Email__c = objAlEmail.id,
            Status__c = 'Registered');  
        insert objMeetingAttendees;
    
        objMeetingAttendees.Status__c = 'Attended';
        update objMeetingAttendees;
       	System.assertEquals(1,[SELECT count() FROM CampaignMember WHERE ContactID =:objMeetingAttendees.Contact__c AND Status='Attended' ]  );      

    }
    
    public static testmethod void TestDataSetup2(){      
        Meeting__c objMeeting = new Meeting__c(
            Name='Test Meeting',
            Subject__c='Test Subject',
            Meeting_Detail__c='Discussion',
            StartDate__c=Date.today()-10,
            EndDate__c=Date.today()-7,
            Type__c ='Webinar',
            StartTime__c=Time.newInstance(18, 30, 2, 00),
            EndTime__c=Time.newInstance(19, 30, 2, 00));
        	insert objMeeting;        
        
		Campaign camp=[Select Id From Campaign Where Name =: objMeeting.Name];
        TuxRewardsCampaignData__c tux = new TuxRewardsCampaignData__c(Name='campaign_name',Campaign_ID__c =objMeeting.Id);
        insert tux;
        delete camp;
        
        Alternate_Email__c objAlEmail = new Alternate_Email__c(
        Alternate_Email_Address__c ='abc@sforce.com'
        );
        insert objAlEmail;
        
        Meeting_Attendees__c objMeetingAttendees = new Meeting_Attendees__c(
            Meeting__c =objMeeting.id,
            Lead__c = TestFactory.getLead().id ,
            Alternate_Email__c = objAlEmail.id);
           
        insert objMeetingAttendees;
        System.assertEquals(1,[SELECT count() FROM CampaignMember WHERE LeadId =:objMeetingAttendees.Lead__c ]  ); 
        delete objMeetingAttendees;

    
    }
}