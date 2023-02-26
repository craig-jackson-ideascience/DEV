@isTest
public class customLookUpControllerTest { 
    
    public static testmethod void testDataSetup(){
        List<Contact> lstContact= new List<Contact>();
        for(Integer i=0 ;i <200;i++)
        {
            Contact contact = new Contact();
            contact.lastName ='Name'+i;
            contact.Email =  'test' + i + '@test.com';
            lstContact.add(contact);
        }

        insert lstContact;

        string searchKeyWord ='Test';
        string ObjectName ='Alternate_Email__c';
        customLookUpController objClass = new customLookUpController();
        customLookUpController.fetchLookUpValues(searchKeyWord,ObjectName,'');
    }

}