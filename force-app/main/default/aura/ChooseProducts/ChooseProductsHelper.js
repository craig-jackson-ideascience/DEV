({
    fetchProducts : function(component,event,helper) {
        component.find("service").callApex(component, helper, "c.getProducts", {
            "selectedProductType" : !$A.util.isUndefinedOrNull(component.get('v.selectedProductType')) ? component.get('v.selectedProductType') : '',
            "selectedProductCategory": !$A.util.isUndefinedOrNull(component.get('v.selectedProductCategory')) ? component.get('v.selectedProductCategory') : '',
            "selectedProjectOrEvent": !$A.util.isUndefinedOrNull(component.get('v.selectedProjectOrEvent')) ? component.get('v.selectedProjectOrEvent') : '',
            "selectedCurrency" : !$A.util.isUndefinedOrNull(component.get('v.selectedCurrency')) ? component.get('v.selectedCurrency') : 'USD',
        }, this.fetchProductsSuccess);
    },
    fetchProductsSuccess : function(component,returnValue,helper){
        component.set('v.selectedProducts',[]);
        returnValue.sort(helper.sortBy('productName', false));
        component.set('v.products',returnValue);
        component.set('v.filteredProducts',returnValue);
        component.set('v.showSpinner',false);
        component.set('v.showSelectedProducts',true);
    },
    getColumns : function(component,event,helper){
        var columns;
        var selectedType = component.get('v.selectedProductType');
        if(selectedType=='Membership'){
            var currencyType = !$A.util.isUndefinedOrNull(component.get('v.selectedCurrency')) ? component.get('v.selectedCurrency') : 'USD';
            columns = [
                {label: 'Product', fieldName: 'productName', type: 'text',sortable : true,fixedWidth:270},
                {label: 'Description', fieldName: 'productDescription', type: 'text',sortable : true,fixedWidth:730},
                {label: 'Tier', fieldName: 'productTier', type: 'number',sortable : true,fixedWidth:90},
                {label: 'Start Tier', fieldName: 'productStartTier', type: 'number',sortable : true,fixedWidth:90},
                {label: 'End Tier', fieldName: 'productEndTier', type: 'number',sortable : true,fixedWidth:90},
                {label: 'Price', fieldName: 'productPrice', type: 'currency', typeAttributes: { currencyCode: currencyType},sortable : true,fixedWidth:100}
            ];
        }else if(selectedType=='Training'){
            columns = [
                {label: 'Product', fieldName: 'productName', type: 'text',sortable : true,fixedWidth:450,wrapText:true},
                {label: 'SKU', fieldName: 'productCode', type: 'text',sortable : true,fixedWidth:200}                
                 ]; 
            if(component.get('v.selectedProductCategory')=='Instructor-Led'){
                columns.push({label: 'Start Date', fieldName: 'startDate', type: 'date-local',sortable : true,fixedWidth:150});
            }
            columns.push(
                {label: 'Training', fieldName: 'trainingName', type: 'text',sortable : true,fixedWidth:900},
                {label: 'Price', fieldName: 'productPrice', type: 'currency', typeAttributes: { currencyCode: 'USD'},sortable : true,fixedWidth:90},
                {label: 'Description', fieldName: 'productDescription', type: 'text',sortable : true,fixedWidth:700}
               );
        }else{
            columns = [
                {label: 'Product', fieldName: 'productName', type: 'text',sortable : true,fixedWidth:270},
                {label: 'Description', fieldName: 'productDescription', type: 'text',sortable : true,fixedWidth:900},
                {label: 'Tier', fieldName: 'productTier', type: 'number',sortable : true,fixedWidth:90},
                {label: 'Price', fieldName: 'productPrice', type: 'currency', typeAttributes: { currencyCode: 'USD'},sortable : true,fixedWidth:90},
                {label: 'Product Detail Name', fieldName: 'productDetailName', type: 'test',sortable : true,fixedWidth:90}
            ];
        }
        component.set('v.columns',columns);
        helper.fetchProducts(component,event,helper);
    },
    handleRowSelectHelper : function(component,event,helper){
        var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows :'+JSON.stringify(selectedRows));
        component.set('v.selectedProducts',selectedRows);
        var mainSelectedProducts = component.get('v.mainSelectedProducts');
        selectedRows.forEach(record => {
            if (mainSelectedProducts.includes(record) === false) mainSelectedProducts.push(record);
        });
        component.set('v.mainSelectedProducts',mainSelectedProducts);
        var selectedProductsCmp = component.find('selectedProducts');
        selectedProductsCmp.set('v.mainSelectedProducts',mainSelectedProducts);
    },
    handleSortHelper : function(component,event,helper){
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        var data = component.get("v.filteredProducts");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.filteredProducts", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    filterHelper : function(component,event,helper){
        var selectedType = component.get('v.selectedProductType');
        var data = component.get("v.products"),
            term = component.get("v.filter"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            if(selectedType == 'Membership'){
                results = data.filter(row=>regex.test(row.productName) || regex.test(row.productDescription) || regex.test(row.productTier) || regex.test(row.productStartTier)
                                      || regex.test(row.productEndTier) || regex.test(row.productPrice));
            }else if(selectedType == 'Training'){
                results = data.filter(row=>regex.test(row.productName) || regex.test(row.productDescription) || regex.test(row.productPrice) || regex.test(row.productDuration));
            }else{
                results = data.filter(row=>regex.test(row.productName) || regex.test(row.productDescription) || regex.test(row.productPrice) || regex.test(row.productTier));
            }
        } catch(e) {
            // invalid regex, use full list
        }
        component.set("v.filteredProducts", results);
    },
    
    removeProductFromListHelper : function(component,event,helper){
        var productId = event.getParam("productId");
        console.log('productId :',productId);
        var dataTable = component.find('chooseProducts');
        var selectedRows = dataTable.get('v.selectedRows');
        const index = selectedRows.indexOf(productId);
        console.log('index :',index);
        if (index > -1) {
            selectedRows.splice(index, 1);
        }
        dataTable.set('v.selectedRows',selectedRows);
    }
})