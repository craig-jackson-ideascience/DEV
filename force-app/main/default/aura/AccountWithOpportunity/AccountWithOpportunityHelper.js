({
    doInit : function(component, event, sortField) {
        var action = component.get("c.getOpportunityLineItem");
        action.setParams({
            "accountId": component.get("v.recordId"),
            'sortField': sortField,
            'isAsc': component.get("v.isAsc")
        });
        var pageSize = component.get("v.pageSize");
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            component.set("v.contacts", actionResult.getReturnValue());
            if (state === "SUCCESS") {
                var records = component.get('v.contacts');
                console.log('records'+records.length);
                for(var i=0;i<records.length;i++){
                  var value =records[i].Related_To__c;
                  if(value === "" || value == undefined){
                        
                  }
                    else{
                  var RelatetTo = value.substring(value.lastIndexOf('">') + 2, 
                                                  value.lastIndexOf("</a>"));
                  console.log('RelatetTo'+RelatetTo); 
                        records[i].Related_To__c = RelatetTo;
                    }
                    
                }
                if (records.length > 0) {
                    component.set("v.totalRecords", records.length);
                    component.set("v.maxPage", Math.ceil((records.length) / pageSize));
                    var pageNumber = component.get("v.pageNumber");
                    var pageRecords = records.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
                    component.set("v.OpportunityList", pageRecords);
                    component.set("v.backupPaginationList", pageRecords);
                   }
               
                
            }            
        });
        // Invoke the service
        $A.enqueueAction(action);
    },
    
    editAccount : function(component, event, helper) {
        
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
             "recordId": event.target.id
       });
       editRecordEvent.fire();
    }, 
    openRecord: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.target.id
         });
        navEvt.fire();
    },
	searchCommunity: function(component, event, helper) {
    var searchInput = component.find('searchInput').get('v.value');
        var regex = searchInput.toUpperCase();
        console.log('Search input'+regex);
        component.set('v.currentPage', 1);
        component.set("v.pageNumber", 1);
        var pageSize = component.get("v.pageSize");
        console.log('Page size is'+pageSize);
        var records = component.get("v.contacts");
        var items = [];
        records.forEach(function(contacts){
            console.log('First Name is'+contacts.Opportunity.Name);
            if(contacts.Opportunity.Name !== null){
                if(contacts.Opportunity.Name.toUpperCase().indexOf(regex)>-1 || contacts.Related_To__c.toUpperCase().indexOf(regex)>-1)
               {
            		items.push(contacts);
            	}
            }
            
        });
        console.log('Items'+items);
        var pageNumber = component.get("v.pageNumber");
        var pageRecords = items.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        component.set("v.maxPage", Math.ceil((items.length) / pageSize));
        component.set("v.OpportunityList",pageRecords);
        component.set("v.backupPaginationList",items);
        component.set("v.pageSize",pageSize);
    },
    renderPage: function(component) {
        console.log('Hiii');
        var pageSize = component.get("v.pageSize");
        var records = component.get("v.contacts"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        console.log('pageRecords----->>>>>>'+pageRecords);
        component.set("v.OpportunityList", pageRecords);
        component.set("v.pageSize",pageSize);
        component.set('v.backupPaginationList', pageRecords);
    },
    /*renderPage: function(component, event, helper) {
        var searchInput = component.find('searchInput').get('v.value');
        var regex = searchInput.toUpperCase();
        component.set('v.currentPage', 1);
        component.set("v.pageNumber", 1);
        var pageSize = component.get("v.pageSize");
        var records = component.get("v.contacts");
        console.log('records---->'+records);
        var items = [];
        records.forEach(function(contacts){
            if(contacts.Opportunity.Name !== null){
            if(contacts.Opportunity.Name.toUpperCase().indexOf(regex)>-1)
               {
            		items.push(contacts);
            	} 
            }
            
        });
        //console.log('Items'+items);
        var pageNumber = component.get("v.pageNumber");
        var pageRecords = items.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        component.set("v.maxPage", Math.ceil((items.length) / pageSize));
        component.set("v.OpportunityList",pageRecords);
        component.set("v.backupPaginationList",items);
        component.set("v.pageSize",pageSize);
    },*/
      sortHelper: function(component, event, sortFieldName) {
      var currentDir = component.get("v.arrowDirection");
 
      if (currentDir == 'arrowdown') {
         // set the arrowDirection attribute for conditionally rendred arrow sign  
         component.set("v.arrowDirection", 'arrowup');
         // set the isAsc flag to true for sort in Assending order.  
         component.set("v.isAsc", true);
      } else {
         component.set("v.arrowDirection", 'arrowdown');
         component.set("v.isAsc", false);
      }
      // call the onLoad function for call server side method with pass sortFieldName 
      this.doInit(component, event, sortFieldName);
   },

})