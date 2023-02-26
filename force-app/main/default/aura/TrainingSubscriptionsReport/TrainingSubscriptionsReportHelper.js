({
    fetchRecords : function(component,event,helper) {
        component.find("service").callApex(component, helper, "c.fetchRecords", {
            "fromDate": component.get("v.fromDate"),
            "toDate":component.get("v.toDate")
        }, this.fetchRecordsSuccess);
    },
    fetchRecordsSuccess : function(component,returnValue,helper){
        component.set("v.showSpinner",true);
        var pageSize = component.get("v.pageSize");
        var records=returnValue;
        if(records.length > 0){
            component.set('v.currentPage', 1);
            component.set("v.pageNumber", 1);
            component.set("v.hasRecords", true);
            component.set("v.AssetProductDetailList", records);
            helper.generateURL(component);
            component.set("v.totalRecords", records.length);
            component.set("v.maxPage", Math.ceil((records.length) / pageSize));
            helper.renderPage(component)
            component.set("v.showSpinner",false);
            component.set("v.showTable", true);
        }else{
            component.set("v.showTable", false);
            component.set("v.showSpinner",false);
            component.set("v.hasRecords", false);
        }
    },
    getRecords:function (component,event,helper){
        console.log('In');
        if($A.util.isUndefinedOrNull(component.get("v.fromDate")) ||
           component.get("v.fromDate") == '' ||
           $A.util.isUndefinedOrNull(component.get("v.toDate")) ||
           component.get("v.toDate") == '' ||
           component.get("v.toDate") == component.get("v.fromDate") ||
           component.get("v.toDate") < component.get("v.fromDate")
          ){
            component.set("v.hasError",true);
        }else{
            component.set("v.showSpinner",true);
            component.set("v.hasError",false);
            this.fetchRecords(component,event,helper);
        }
    },
    
    renderPage: function(component) {
        var pageSize = component.get("v.pageSize");
        var records = component.get("v.AssetProductDetailList"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        component.set("v.PaginationList", pageRecords);  
    },
    
    downloadCsv: function(component,event,helper) {
        
        component.set("v.showSpinner", true);  
        var records =JSON.stringify(component.get("v.AssetProductDetailList"));
        component.find("service").callApex(component, helper, "c.generateCsv", {
            "records": records
        },this.generatedCsvSuccess);
    },
    generatedCsvSuccess : function(component,returnValue,helper){
        var csv=returnValue;
        if(!$A.util.isUndefinedOrNull(csv) && csv != ''){
            var hiddenElement = document.createElement("a");
            hiddenElement.href =
                "data:text/csv;charset=utf-8," + encodeURI(csv);
            hiddenElement.target = "_blank";
            hiddenElement.download ='TrainingSubscriptionReportFrom'+
                JSON.stringify(component.get("v.fromDate"))+'To'+
                JSON.stringify(component.get("v.toDate"))+'.csv';
                //01-04-2020To30-04-2020.csv';
            hiddenElement.click();
            component.set("v.showSpinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"success",
                "title":"Success!",
                "message": "The file has been successfully downloaded."
            });
            toastEvent.fire();
        }else{
            component.set("v.showSpinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"error",
                "title":"Error!",
                "message": "Error while downloading file."
            });
            toastEvent.fire();
        }
    },
    
    generateURL : function(component){
        let records = component.get("v.AssetProductDetailList");        
        records.forEach(record =>{
            record.url = '/lightning/r/Asset/' + record.Id + '/view';
            record.accountUrl='/lightning/r/Account/' + record.accountId + '/view';}
            );
            component.set('v.AssetProductDetailList',records);
        },
            
        })