({
    loggedInUserRole_Helper : function(component, event, helper) {
        helper.getFoundationDeails_Helper(component, event, helper, 'Current_Year_Revenue__c');
    },
    
    getFoundationDeails_Helper:function(component, event, helper, sortField) {
        var action = component.get("c.getFoundationDeails_Apex");
        action.setParams({
            'sortField': sortField,
            'isAsc': component.get("v.isAsc")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log("state::::=>"+state);
            if (state === "SUCCESS") {
                var oRes = response.getReturnValue();
                if(oRes !=null && oRes.length  > 0 && oRes != undefined) {
                    component.set("v.foundationRecordListForAll", oRes);
                    var foundationRecordListForAll = component.get("v.foundationRecordListForAll");
                    
                    component.set("v.SelectedProject", oRes[0].objProject);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.foundationRecordListForAll").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
                    component.set("v.currentPage", 1);
                    
                    var evnt1 = $A.get('e.c:foundationName');
                    evnt1.setParams({
                        "selectedProject" : foundationRecordListForAll[0].objProject
                        //"productName":oRes1
                    });
                    evnt1.fire();     
                }else{
                    // if there is no records then display message
                    component.set("v.ifNoRecordsFound" , true);
                } 
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    sendFoundationToMembershipCMP: function(component, event, helper, foundationId) {
        var evnt = $A.get('e.c:foundationName');
        evnt.setParams({
            "selectedProject" : foundationId 
        });
        evnt.fire();
    },
    
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },    
    sortHelper: function(component, event, helper, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");        
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendered arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        // call the onLoad function for call server side method with pass sortFieldName 
        this.getFoundationDeails_Helper(component, event, helper, sortFieldName);
    },
})