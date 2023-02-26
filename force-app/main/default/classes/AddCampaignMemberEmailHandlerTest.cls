@istest
public class AddCampaignMemberEmailHandlerTest {
    
    public static void sendEmail(String str){
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inboundAttachment = new Messaging.InboundEmail.BinaryAttachment();
        
        email.subject = 'testsub';
        email.fromAddress = 'test@gmail.in';
        email.plainTextBody = ('Hal Jordan');   //Added
        email.toAddresses =new String[] {'standarduser123@testorg.com'};
            inboundAttachment.body = blob.valueOf(str);
        inboundAttachment.fileName = 'Email_Attachment.csv';
        
        
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inboundAttachment }; 
            
            // create an instance of the EmailToSalesForce class and test it with the data in the testMethod
            AddCampaignMemberEmailHandler  addcampaignHandler = new AddCampaignMemberEmailHandler();
        addcampaignHandler.handleInboundEmail(email, env ); 
        
        
    }
    
    
    public static testMethod void LeadInsert(){
        string str = 'Campaign Name,First Name,Last Name,Email Address,Job Title,Company,Street,City,State,Country,Zip,Linkedin Id,Github Id,Phone,Industry,Lead Source,Lead Source Detail,Notes \n'
            +'TestCampaign,Jubbi,Pearce,sneh@gmail.com,PM,Splunk,,Plano,Texas,USA,,zbpears,,,Software,,,Tests notes \n'
            +'TestCampaign,Julia,Pearce,jul@sp.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n'
            +'TestCampaign,TestData,Pearce,hal.jordan@example.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n';
        
        
        TestFactory.getAccount();
        TestFactory.getContact();
        TestFactory.getCampaign();
        TestFactory.getUser();
        Test.startTest();
        sendEmail(str);
        Test.stopTest();
        //System.AssertEquals(2,[Select id From Lead].size() );
        
        
        
    }
    
    Public static testMethod void AlreadyMember(){
        string str = 'Campaign Name,First Name,Last Name,Email Address,Job Title,Company,Street,City,State,Country,Zip,Linkedin Id,Github Id,Phone,Industry,Lead Source,Lead Source Detail,Notes \n'
            +'TestCampaign,Jubbi,Pearce,jb@test.org,PM,Splunk,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests ,notes" \n'
            +'TestCampaign,Julia,Pearce,jul@sp.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests,notes" \n'
            +'TestCampaign,TestData,Pearce,hal.jordan@example.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n';
        
        Campaign campaign =  TestFactory.getCampaign();
        List<CampaignMember> camplist = new List<CampaignMember>();
        
        //Contact Campaign Member
        CampaignMember campmember = new CampaignMember(
            CampaignId =  campaign.id,   // Campaign
            ContactId = TestFactory.getContact().id  // contact
        );
        
        camplist.add(campmember);
        //Lead Campaign Member
        CampaignMember campmember2 = new CampaignMember(
            CampaignId =  campaign.id,   // Campaign
            LeadId = TestFactory.getLead().id // lead
        );
        camplist.add(campmember2);
        insert camplist;
        
        System.debug('--- '+camplist.size()+' '+camplist);
        TestFactory.getUser();
        Test.startTest();
        sendEmail(str);
        Test.stopTest();
        System.assertEquals(1,[Select ContactId From CampaignMember WHERE ContactId != null].size());
    }
    
   public static testMethod void Errolog(){
        //Sending Wrong Email 
        string str = 'Campaign Name,First Name,Last Name,Email Address,Job Title,Company,Street,City,State,Country,Zip,Linkedin Id,Github Id,Phone,Industry,Lead Source,Lead Source Detail,Notes \n'
            +'TestCampaign,Jubbi,Pearce,test@c.com,PM,Splunk,,Plano,Texas,USA,,zbpears,,'+getlargeText(41)+',Software,,,Tests notes \n'
            +'TestCampaign,Julia,Pearce,test@a.com,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n'
            +'TestCampaign,TestData,Pearce,b@test,PM,Test,,Plano,Texas,USA,,zbpears,,,Software,,,"Tests notes" \n';
        
        TestFactory.getCampaign();
        Test.startTest(); 
        sendEmail(str);
        Test.stopTest();  
        
    }
    public static String getlargeText(Integer len){
        String str='';
        for(Integer i=0;i<=len;i++){
            str+='t';
        }
        return str;
    }
}