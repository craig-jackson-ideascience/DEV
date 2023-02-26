global class PurchaseHistoryScheduleClass  Implements Schedulable{
global void execute(SchedulableContext sc){
        PurchaseHistoryController purchaseHistoryController=new PurchaseHistoryController();
        if(purchaseHistoryController.getAssetList().size()>0){
            sendmail();
        }
       		 
    }
    public void sendmail(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        Id TemplateId=[SELECT Id FROM emailtemplate WHERE developername='Purchase_History_Netsuite_Sync'].Id;
        string [] toaddress= New string[]{label.Purchase_History_To_Address};
        mail.setTargetObjectId(label.Purchase_Sent_Integration_User); 
        //Change with Template ID
        mail.setTemplateId(TemplateId);
        //Record ID for which letter will be generated
        mail.setUseSignature(false); 
        mail.setSenderDisplayName(Label.Purchase_History_Display_Name); 
        mail.setSaveAsActivity(false);
        mail.setToAddresses(toaddress); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}