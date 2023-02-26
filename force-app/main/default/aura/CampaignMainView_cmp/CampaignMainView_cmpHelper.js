({
    onPageReferenceChange_helper : function(component, event, helper, foundationId, sortField) {  
        var action = component.get("c.getCampaignDetails");
        action.setParams({
            "foundationId": foundationId,
            'sortField': sortField,
            'isAsc': component.get("v.isAsc")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ifNoRecordsFound" , false);
                var oRes = response.getReturnValue();
                
                if(oRes != null && oRes.length > 0 && oRes != undefined) {
                    
                    component.set("v.campaignList", oRes);                    
                    //console.log('campaignList:::: ' + oRes);
                    //console.log('campaignList::2:: ');
                    //console.log(component.get("v.campaignList"));
                    var totalLength = oRes.length;
                    //console.log("totalLength::"+totalLength);
                    component.set("v.totalRecordsCount", totalLength);
                    
                }else{
                    // if there is no records then display message
                    //helper.foundationId_helper(component, event, helper);
                    component.set("v.ifNoRecordsFound" , true);
                } 
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            } 
                else if (state === "ERROR") {
                    //  $A.get('e.force:refreshView').fire();
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
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        var fId = component.get("v.foundationId");
        // call the onLoad function for call server side method with pass sortFieldName 
        this.onPageReferenceChange_helper(component, event, helper, fId, sortFieldName);
    },
    
})