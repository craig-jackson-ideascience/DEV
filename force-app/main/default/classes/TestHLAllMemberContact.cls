@isTest
public class TestHLAllMemberContact {

    public static testmethod void setupTestData(){
        Account objAccount = TestFactory.getAccount();
        Contact objContact = TestFactory.getContact();
        Project__c objProject = TestFactory.getProject();
        User objUser = TestFactory.getUser();
        Asset objAsset =TestFactory.getAsset();
        AccountTeamMember objATM = new AccountTeamMember();
        objATM.AccountId = objAccount.id;
        objATM.TeamMemberRole ='HL- POC';
        objATM.UserId =objUser.id;
        Insert objATM;
        Project_role__c objProjectRole = new Project_role__c();
        objProjectRole.Asset__c = objAsset.id;	
        objProjectRole.Contact__c = objContact.id;
        objProjectRole.Role__c ='Billing Contact';
        insert objProjectRole;
        HLAllMemberContact objClass = new HLAllMemberContact();
        HLAllMemberContact.WrapperClass obj =new HLAllMemberContact.WrapperClass();
        objClass.ExportToExcel();
        objClass.getProjectRole();
        objClass.getselectedAccountTeam();
        objClass.getselectedProject();
        objClass.getselectedUser();
        objClass.Next();
        objClass.Previous();
        
    }
}