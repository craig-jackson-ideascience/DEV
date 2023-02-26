@isTest
public class PostSsandboxCopyTest {

    public static testMethod void MethodTest(){
        PostSandboxCopy sandboxCopy = new PostSandboxCopy();
        sandboxCopy.runApexClass(null);
        Endpoints__c endpoint = Endpoints__c.getInstance('For Membership Asset');
        system.assertEquals('4010327_SB1',endpoint.Nlauth_Account__c);
    }
}