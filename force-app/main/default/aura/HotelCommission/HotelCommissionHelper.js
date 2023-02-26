({
    createRecordHelper : function (component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Hotel_Commissions__c",
                "defaultFieldValues": {
                    'Name' : component.get('v.hotelCommissions.Name'),
                    'Event_Name__c' : component.get('v.hotelCommissions.Event_Name__c'),
                    'Product__c' : component.get('v.hotelCommissions.Product__c'),
                    'Amount__c' : component.get('v.hotelCommissions.Amount__c'),
                    'Product_Description__c' : component.get('v.hotelCommissions.Product_Description__c'),
                    'Start_Date__c' : component.get('v.hotelCommissions.Start_Date__c'),
                    'End_Date__c' : component.get('v.hotelCommissions.End_Date__c'),
                    'SubsidiaryId__c' : component.get('v.hotelCommissions.SubsidiaryId__c'),
                    'Bill_to_Account__c' : component.get('v.hotelCommissions.Bill_to_Account__c'),
                    'Bill_to_Contact__c' : component.get('v.hotelCommissions.Bill_to_Contact__c'),
                    'Bill_to_Contact_2__c' : component.get('v.hotelCommissions.Bill_to_Contact_2__c'),
                    'Bill_to_Contact_3__c' : component.get('v.hotelCommissions.Bill_to_Contact_3__c'),
                    'NS_Department__c' : component.get('v.hotelCommissions.NS_Department__c'),
                    'NS_Deferred_Revenue_Account__c' : component.get('v.hotelCommissions.NS_Deferred_Revenue_Account__c'),
                    'NS_Income_GL_Account__c' : component.get('v.hotelCommissions.NS_Income_GL_Account__c'),
                    'NS_Invoice_Memo__c' : component.get('v.hotelCommissions.NS_Invoice_Memo__c')
                }
            });
            createRecordEvent.fire();
        }
    }
    
})