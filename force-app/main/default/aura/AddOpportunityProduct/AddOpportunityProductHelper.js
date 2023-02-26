({
    fetchOpportunityTypes : function(component,event,helper) {
        component.find("service").callApex(component, helper, "c.getOpportunityTypes", {
            "opportunityId" : component.get('v.opportunityId')
        }, this.fetchOpportunityTypesSuccess);
	},
    fetchOpportunityTypesSuccess : function(component,returnValue,helper){
        component.set('v.productTypes', JSON.parse(returnValue.OpportunityTypes));
        console.log('returnValue.OpportunityRecordType :',returnValue.Currency);
        component.set('v.selectedProductType',returnValue.OpportunityRecordType);
        returnValue.isWon == 'true' ? component.set('v.isWon',true) : component.set('v.isWon',false);
        component.set("v.opportunityCurrency",returnValue.Currency );
        component.find("service").callApex(component, helper, "c.getProductCategoriesAndProjects", {
            "selectedProductType" : component.get('v.selectedProductType'),
            "selectedProductCategory": component.get('v.selectedProductCategory')
        }, helper.getProductCategoriesAndProjectsSuccess);
    },
    handleProductTypeChangeHelper : function(component,event,helper){
        component.set('v.showSpinner',true);
        var errorDiv = component.find('errorDiv');
        $A.util.addClass(errorDiv, 'slds-hide');  
        component.set('v.showChooseProducts',false);
        component.set('v.selectedProductType',event.getParam("value"));
        component.set('v.projectOrEvents', []);
        component.set('v.productCategories', []);
        var projectOrEvent = component.find('projectOrEvent');
        var productCategory = component.find('productCategory');
        component.set('v.selectedProductCategory','');
        component.set('v.selectedProjectOrEvent','');
        if(!$A.util.isUndefinedOrNull(projectOrEvent))
            projectOrEvent.set('v.value', "");
        if(!$A.util.isUndefinedOrNull(productCategory))
            productCategory.set('v.value', "");
        component.find("service").callApex(component, helper, "c.getProductCategoriesAndProjects", {
            "selectedProductType" : component.get('v.selectedProductType'),
            "selectedProductCategory": component.get('v.selectedProductCategory')
        }, this.getProductCategoriesAndProjectsSuccess);
    },
    getProductCategoriesAndProjectsSuccess : function(component,returnValue,helper){
        component.set('v.projectOrEvents', JSON.parse(returnValue.ProjectsOrEvents));
        component.set('v.productCategories', JSON.parse(returnValue.ProductCategories));
        component.set('v.showSpinner',false);
    },
    handleProductCategoryChangeHelper : function(component,event,helper){
        component.set('v.showSpinner',true);
        var errorDiv = component.find('errorDiv');
        $A.util.addClass(errorDiv, 'slds-hide');
        component.set('v.projectOrEvents', []);
        component.set('v.selectedProjectOrEvent','');
        var projectOrEvent = component.find('projectOrEvent');
		if(!$A.util.isUndefinedOrNull(projectOrEvent))
            projectOrEvent.set('v.value', "");        
        component.set('v.showChooseProducts',false);
        component.set('v.selectedProductCategory',event.getParam("value"));
        if(component.get('v.selectedProductType') != 'Training'){
            component.find("service").callApex(component, helper, "c.getProductCategoriesAndProjects", {
                "selectedProductType" : component.get('v.selectedProductType'),
                "selectedProductCategory":component.get('v.selectedProductCategory')
            }, this.getProductCategoriesAndProjectsSuccess);
        }else{
            this.renderChooseProductTable(component,event,helper);
        }
      
    },
    handleProjectChangeHelper : function(component,event,helper){
        component.set('v.showSpinner',true);
        component.set('v.selectedProjectOrEvent',event.getParam("value")); 
        if(component.get('v.selectedProductType') != 'Event'){
            component.find("service").callApex(component, helper, "c.getProjectCategory", {
                "selectedProjectOrEvent" : component.get('v.selectedProjectOrEvent')
            }, this.getProjectCategorySuccess);
        }       
        this.renderChooseProductTable(component,event,helper);
    },
    getProjectCategorySuccess : function(component,returnValue,helper){
        //var rtid = $A.get("$Label.c.Directed_Fund_RT");
        var errorDiv = component.find('errorDiv');
        returnValue == 'Directed Fund' ? $A.util.removeClass(errorDiv, 'slds-hide') : $A.util.addClass(errorDiv, 'slds-hide');
    },
    handleCancelHelper : function(component,event,helper){
        helper.navigateToOpportunity(component);
    },
    navigateToOpportunity : function(component){
        window.open("/"+component.get('v.opportunityId') ,"_self");
    },
    renderChooseProductTable : function(component,event,helper){
        component.set('v.showChooseProducts',false);
        setTimeout(function() {
            component.set('v.showChooseProducts',true);
        }, 50);
    },
    handleInsertHelper: function(component, event, helper) {
        //var chooseProductsComponent = component.find('chooseProducts');
        var records = component.get('v.mainSelectedProducts');//!$A.util.isUndefinedOrNull(chooseProductsComponent) ? chooseProductsComponent.get('v.selectedProducts') : [];
        var type = component.get('v.selectedProductType');
        //IF PRODUCT TYPE IS BLANK
        if(type == '--None--' || $A.util.isUndefinedOrNull(type)){
            alert('Please fill Product Type before submitting');
        }
        //IF PRODUCT TYPE HAS SOME VALUE
        else{
            //IF PRODUCT TYPE IS TRAINING
            if(type == 'Training'){
                if(component.get('v.selectedProductCategory') == '--None--' || $A.util.isUndefinedOrNull(component.get('v.selectedProductCategory')) || records.length == 0){
                    alert('Please select Category and choose any of the Product');
                }else if((component.get('v.selectedProductCategory') == 'Bundle' || (component.get('v.selectedProductCategory') == 'Subscription'))
                         && $A.util.isUndefinedOrNull(component.get('v.contractAmount')) ){
                    alert('Please enter contract Amount');
                }/*else if((component.get('v.selectedProductCategory') == 'Bundle' || (component.get('v.selectedProductCategory') == 'Subscription'))
                         && $A.util.isUndefinedOrNull(component.get('v.endDate')) ){
                    alert('Please enter end Date');
                }*/else if (component.get('v.selectedProductCategory') == 'Subscription' && $A.util.isUndefinedOrNull(component.get('v.certificationNo'))){
                    alert('Please enter certificate no');
                }
                else{
                    helper.saveProducts(component,event,helper,records);
                }
            }
            //IF PRODUCT TYPE IS MEMBERSHIP
            else if(type == 'Membership' || type == 'Alternate Funding'){
                if(component.get('v.selectedProjectOrEvent') == '--None--' || $A.util.isUndefinedOrNull(component.get('v.selectedProjectOrEvent')) || records.length == 0){
                    alert('Please select  Project and any of the Product'); 
                }else{
                    helper.saveProducts(component,event,helper,records);
                }    
            }
            //IF PRODUCT TYPE IS EVENT
                else{
                    if(component.get('v.selectedProductCategory') == '--None--' || $A.util.isUndefinedOrNull(component.get('v.selectedProductCategory'))
                       || component.get('v.selectedProjectOrEvent') == '--None--' || $A.util.isUndefinedOrNull(component.get('v.selectedProjectOrEvent'))
                       || records.length == 0){
                        alert('Please select Category, Project and any of the Product'); 
                    }else{
                        helper.saveProducts(component,event,helper,records);
                    }
                }
        }
    },
    saveProducts : function(component,event,helper,records){
        component.set('v.showSpinner',true);
        records.forEach(record => {
            record.selected = true;
        });
            console.log('SELECTED ROWS  :' + JSON.stringify(records));
            var action;
       var selectedType =  component.get('v.selectedProductCategory');
            if(selectedType =='Bundle'|| selectedType =='Subscription'){
            action = component.get("c.insertSubscriptionProducts");
        action.setParams({ 
            "selectedCategory": component.get('v.selectedProductCategory'),
            "productDetailWrapperJSON": JSON.stringify(records),
        "opportunityID" : component.get('v.opportunityId'),
            "noOfCertification":component.get('v.certificationNo'),
            "OppAmount" :component.get('v.contractAmount')/*,
            "endDate" : component.get('v.endDate')*/});
        }else{
            action = component.get("c.insertProducts");
        action.setParams({ "selectedProductType": component.get('v.selectedProductType'),
            "opportunityId": component.get('v.opportunityId'),
            "productDetailWrapperJSON": JSON.stringify(records) });
        }
        

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               this.navigateToOpportunity(component);
			}
            
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].pageErrors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].pageErrors[0].message);
                        //alert(errors[0].pageErrors[0].message);
                        
                        component.set("v.notificationmessage", errors[0].pageErrors[0].message);
                              $A.util.removeClass(component.find('warningDiv'), 'slds-hide');
                               window.setTimeout($A.getCallback(function() {
                               $A.util.addClass(component.find('warningDiv'), 'slds-hide');
                                  }), 8000);
                        component.set('v.showSpinner',false);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        
        $A.enqueueAction(action);
      
          
    },
   
    
})