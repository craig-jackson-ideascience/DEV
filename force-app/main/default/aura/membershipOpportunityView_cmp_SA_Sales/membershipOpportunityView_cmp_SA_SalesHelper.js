({
    // get foundation Name
    doInit_helper : function(component, event, helper, sortField,SlctedProject) {  
        var selectedProject;
        if(SlctedProject==null){
        	selectedProject=component.get("v.foundationRecord");
        }
        
        /*if(selectedType==null||event.getSource()!=null){
          oppType=event.getSource().get("v.value"); 
        }else{
          oppType = selectedType.get("v.value");
        }*/
        if(SlctedProject != null){
            selectedProject = SlctedProject; //event.getParam("selectedProject");
            console.log('selectedProject In::: ' + JSON.stringify(selectedProject));
        }
        component.set("v.foundationRecord",selectedProject);
        console.log('selectedProject Id Out:2::: ' + selectedProject.Id);
        helper.opportunityDetails_helper(component, event, helper, sortField);

    },
    
    //getPicklist Values of Opportunity Type
	getOppTypePicklist: function(component, event) {
        var action = component.get("c.getOpportunityType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                component.set("v.oppTypeMap", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    opportunityDetails_helper : function(component, event, helper, sortField) {
        
        var foundationRecord = component.get("v.foundationRecord");
        var foundationId = foundationRecord.Id;
         //console.log('foundationId:::@SK=>' + foundationId);
         
        var action = component.get("c.getOpportunityDetails");
        action.setParams({
            "foundationId": foundationId,
            "sortField": sortField,
            "isAsc": component.get("v.isAsc")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ifNoRecordsFound" , false);
                var oRes = response.getReturnValue();
                
                if(oRes != null && oRes.length > 0 && oRes != undefined) {
                    
                    component.set("v.opportunityList", oRes);
                    var oppDetails = component.get("v.opportunityList");
                    var pageSize = component.get("v.pageSize");
                    //console.log("pageSize::"+pageSize);
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length;
                    //console.log("totalLength::"+totalLength);
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.currentPage",1);
                    //console.log("currentPage::"+component.get("v.currentPage"));
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.opportunityList").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));  
                    //console.log("totalPagesCount::"+component.get("v.totalPagesCount"));
                   
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
        
    viewAll_helper: function(component, event, helper) {
        var foundationRecord = component.get("v.foundationRecord");
        var foundationId = foundationRecord.Id;
        var foundationName = foundationRecord.Name;
        var navService = component.find("navService");        
        var pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__waveAnalyticsOpportunityView_cmp_SA_Sales"
            },
            state: { 
                "c__foundationId" : foundationId,
                "c__foundationName" : foundationName
            }
        };
        component.set("v.pageReference", pageReference);
        
        const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
            navService.generateUrl(pageReference).then(handleUrl, handleError);
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
        //alert(sortFieldName);
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        //helper.doInit_helper(component, event, helper, sortFieldName,null);
        
        var oppType = component.get("v.selectedOppType");
        if(oppType != null){
            helper.handleTypeOnChange_helper(component, event, helper, sortFieldName);
        } else {
            helper.doInit_helper(component, event, helper, sortFieldName, null);
        }
    },
            
    //helper for get the filterData of Opportunity by OppType
    handleTypeOnChange_helper:function(component, event, helper, sortField) {
        
        var oppType = component.get("v.selectedOppType");
        /*var selectedType = component.find("typePicklist");
        
        //alert(oppType);
        if(selectedType==null||event.getSource()!=null){
          oppType=event.getSource().get("v.value"); 
        }else{
          oppType = selectedType.get("v.value");
        }*/
       // alert(oppType);
        //var oppType = event.getSource().get("v.value");
        console.log('ooooppptype::: '+oppType);
        console.log('sortField::: '+sortField);
        var foundationRecord = component.get("v.foundationRecord");
        var foundationId = foundationRecord.Id;
        console.log('foundationId::::: '+foundationId);
        var action = component.get("c.OpportunityListWrapperWithOppTypeFilter");
        action.setParams({            
            "foundationId": foundationId,       
            "sortField": sortField,
            "isAsc": component.get("v.isAsc"),
            "oppType": oppType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state:New:::=>"+state);
            //$A.get('e.force:refreshView').fire();
            if (state === "SUCCESS") {
                component.set("v.ifNoRecordsFound",false);
                var oRes = response.getReturnValue();  
                console.log("oppDetails::"+JSON.stringify(oRes));
                if(oRes != null && oRes.length > 0) {
                    component.set("v.opportunityList", oRes);
                    var oppDetails = component.get("v.opportunityList");
                    //console.log("oppDetails::"+oppDetails);
                    var pageSize = component.get("v.pageSize");
                    //console.log("pageSize::"+pageSize);
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length;
                    //console.log("totalLength::"+totalLength);
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.currentPage",1);
                    //console.log("currentPage::"+component.get("v.currentPage"));
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.opportunityList").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));  
                    //console.log("totalPagesCount::"+component.get("v.totalPagesCount"));
                }else{
                    component.set("v.ifNoRecordsFound",true);
                    var compList=[];
                    component.set("v.opportunityList", compList);
                    //console.log("pageSize::"+pageSize);
                    var totalLength = 0;
                    //console.log("totalLength::"+totalLength);
                    component.set("v.totalRecordsCount", 0);
                    component.set("v.startPage",0);
                    component.set("v.currentPage",0);
                    //console.log("currentPage::"+component.get("v.currentPage"));
                    component.set("v.endPage",0);
                    var PaginationLst = [];
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", 0);  
                    component.set("v.membershipDetails", null);
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
})