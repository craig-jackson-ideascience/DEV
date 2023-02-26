public class AddBeneficiaryfromTravelFundHandler implements Queueable,Database.AllowsCallouts {
    private list<Travel_Fund_Request__c> travelFundList;
    static list<Travel_Fund_Request__c> trvelFundUpdateList=new list<Travel_Fund_Request__c>();
    //Constructer to Set Travel Fund List
    public AddBeneficiaryfromTravelFundHandler(list<Travel_Fund_Request__c> trvlFundList) {        
        this.travelFundList=trvlFundList;        
    }
    //Executing Add Beneficiary into Funding Bridge
    public void execute(QueueableContext context) {
        AddBeneficiaryfromTravelFundHandler.addBeneficiary(travelFundList);
    }
    //Making a Callout from Saleforce once Travel Fund Status changes to Request Approved - Waiting For Expense Report
    public static void addBeneficiary(list<Travel_Fund_Request__c> travelFundList){
        list<Travel_Fund_Request__c> trvelFundList=[select Id,CommunityBridge_Status__c,Approved_Amount__c,
                                                    	ContactEmail__c,Event__r.Expensify_Policy_ID__c ,Contact__r.firstname,Contact__r.lastName,Event__r.Community_Bridge_Event_Id__c,Event__r.Name,FirstName__c,Expensify_ID__c,Status__c 
                                                    FROM 
                                                    	Travel_Fund_Request__c 
                                                    WHERE 
                                                    	Id IN:travelFundList];
        try{
            for(Travel_Fund_Request__c trvlFundObj:trvelFundList) {
                if(trvlFundObj.Status__c.equals('Request Approved - Waiting For Expense Report')){
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint('callout:CommunityBridge/'+ trvlFundObj.Event__r.Community_Bridge_Event_Id__c+'/addbeneficiary');
                    JSONGenerator gen = JSON.createGenerator(true);        
                    gen.writeStartObject();        
                    gen.writeStringField('name', trvlFundObj.Contact__r.firstname+' '+trvlFundObj.Contact__r.lastName);
                    gen.writeStringField('email', trvlFundObj.ContactEmail__c);
                    gen.writeEndObject();        
                    request.setMethod('POST');
                    request.setHeader('x-beneficiary-auth',System.Label.Beneficiary_Authentication);        
                    request.setBody(gen.getAsString());
                    request.setTimeout(120000);
                    HttpResponse response = http.send(request);
                    if(response.getStatusCode()==200){
                        trvlFundObj.CommunityBridge_Status__c=true;            
                        trvelFundUpdateList.add(trvlFundObj);//upsert trvlFundObj;
                    }                
                    System.debug('Res'+response.getBody());
                    System.debug(response.getStatusCode());
                }
            }
            if(trvelFundUpdateList.size()>0){
                RecursiveTriggerHandler.isFirstTime=false;
                update trvelFundUpdateList;
            }            
        }catch(exception ex){
            system.debug(logginglevel.ERROR,ex.getLineNumber()+'ERROR in AddBeneficiaryfromTravelFundHandler.addBeneficiary::'+ex);
        }
    }
}