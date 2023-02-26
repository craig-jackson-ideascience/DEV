/*
 Test Class of AddCampaignMemberEmailHandler
 */
@istest
public class AddCampaignMemberEmailHandler_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@TestSetup
	static void createTestData(){
		User user = TestFactory.getUser();
		Contact contact = TestFactory.getContact();
	}

	/**
	 * sendEmail : common method for calling handleInboundEmail of AddCampaignMemberEmailHandler
	 * It doesn't contains any asserts as it is common method to send email as we send different string based on condition 
	 * and the respective methods contains the asserts which called it
	 */
	private static void sendEmail(String str){

		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		Messaging.InboundEmail.BinaryAttachment inboundAttachment = new Messaging.InboundEmail.BinaryAttachment();

		email.subject = 'testsub';
		email.fromAddress = 'test@gmail.in';
		email.plainTextBody = ('Hal Jordan');   //Added
		email.toAddresses = new String[]{'standarduser123@testorg.com'};
		inboundAttachment.body = blob.valueOf(str);
		inboundAttachment.fileName = 'Email_Attachment.csv';


		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[]{inboundAttachment};

		// create an instance of the EmailToSalesForce class and test it with the data in the testMethod
		AddCampaignMemberEmailHandler addcampaignHandler = new AddCampaignMemberEmailHandler();
		addcampaignHandler.handleInboundEmail(email, env);
	}

	/**
	 * TestMethod for Inserting lead by comma seperated string
	 */
	@isTest
	static void leadInsert_Test(){
		Campaign campaign = TestFactory.getCampaign();
		string str = 'Campaign Name,First Name,Last Name,Email Address,Job Title,Company,Street,City,State,Country,Zip,Linkedin Id,Github Id,Phone,Industry,Lead Source,Lead Source Detail,Notes \n' + 
					 'TestCampaign,Jubbi,Pearce,sneh@gmail.com,PM,Splunk,,Plano,Texas,USA,,zbpears,,,Software,,,Tests notes \n' + 
					 'TestCampaign,Julia,Pearce,jul@sp.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n' + 
					 'TestCampaign,TestData,Pearce,hal.jordan@example.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n';

		//Test
		Test.startTest();
		sendEmail(str);
		Test.stopTest();

		//Asserts
		System.AssertEquals(2, [Select id
		                        From Lead].size(),'2 Lead Records Must be returned');
	}

	/**
	 * TestMethod for having the email which is already a campaignmember of that campaign
	 */
	@isTest
	static void alreadyMember_Test(){
		List<CampaignMember> campMemberList = TestFactory.getCampaignMember();

		string str = 'Campaign Name,First Name,Last Name,Email Address,Job Title,Company,Street,City,State,Country,Zip,Linkedin Id,Github Id,Phone,Industry,Lead Source,Lead Source Detail,Notes \n' + 
					 'TestCampaign,Jubbi,Pearce,jb@test.org,PM,Splunk,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests ,notes" \n' + 
					 'TestCampaign,Julia,Pearce,jul@sp.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests,notes" \n' + 
					 'TestCampaign,TestData,Pearce,hal.jordan@example.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n';

		//Test
		Test.startTest();
		sendEmail(str);
		Test.stopTest();

		//Asserts
		System.assertEquals(2, [Select ContactId
		                        From CampaignMember
		                        WHERE ContactId != null].size(),'2 CampaignMember records Must be returned');
	}

	/**
	 * TestMethod for getting error on campaignmemberrecordLog Object as input contains error
	 */
	@isTest
	static void errolog_Test(){
		//Sending Wrong Email
		string str = 'Campaign Name,First Name,Last Name,Email Address,Job Title,Company,Street,City,State,Country,Zip,Linkedin Id,Github Id,Phone,Industry,Lead Source,Lead Source Detail,Notes \n' + 
					 'TestCampaign,Jubbi,Pearce,test@c.com,PM,Splunk,,Plano,Texas,USA,,zbpears,,' + getlargeText(41)+',Software,,,Tests notes \n' + 
					 'TestCampaign,Julia,Pearce,test@a.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n' + 
					 'TestCampaign,TestData,Pearce,b@test,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n';

		TestFactory.getCampaign();

		//Test
		Test.startTest();
		sendEmail(str);
		Test.stopTest();

		//Asserts
		System.assertEquals(1, [SELECT Id
		                        FROM Campaign_Member_Record_Log__c
		                        WHERE Status__c = 'Error'].size(),'There Must be one Campaign_Member_Record_Log__c \'s record');
	}

	//Method to get large character of string
	private static String getlargeText(Integer len){
		String str = '';
		for (Integer i = 0; i <= len; i++){
			str += 't';
		}
		return str;
	}
}