public class Utils {
  @future
  public static void createContact(List<string> userIDs) {
    List<user> usrRecords=[select id,firstName,LastName,Email from user where id in : userIDs];
        list<Contact> ContRecordsList=new list<Contact>();
        list<String> emailAdressList=new list<String>();
        List<Account> LFAccountRecord=[select id from Account where Name='Apple Pvt Ltd'];
        system.debug('LFAccountRecord'+LFAccountRecord.size());
         for(user usrRecord :usrRecords){
           
            Contact contRec=new Contact();
            contRec.FirstName=usrRecord.firstName;
            contRec.LastName=usrRecord.LastName;
            contRec.Email=usrRecord.Email;
            contRec.AccountId=(LFAccountRecord.size()>0?LFAccountRecord[0].id:null);
            emailAdressList.add(usrRecord.Email);
            ContRecordsList.add(contRec);

        }
            
             if(ContRecordsList.size()>0){
            //Getting Existing Account with Same Email Addesss
            map<String,Contact> emailContactMap=new map<string,Contact>();
            for(Contact contactObj:[select id,email from Contact where email IN: emailAdressList]){
                emailContactMap.put(contactObj.Email,contactObj);
            }
            list<Contact> newContactList=new list<Contact>();
            for(Contact contRec1 :ContRecordsList){
                if(!emailContactMap.containsKey(contRec1.Email)){
                    newContactList.add(contRec1);
                }
            }
            if(newContactList.size()>0){
                insert newContactList;
            }
        }

  }
}