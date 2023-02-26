/**
 * Created by ANT-MAN on 12-05-2020.
 */
({
    doInitHelper : function(component,event,helper){
        helper.populateColumns(component,event,helper);
    },
            
    populateColumns : function(component,event,helper){
          var columns = [
              {label: 'Product', fieldName: 'productName', type: 'text',fixedWidth:270,wrapText:true},
              {label: 'Description', fieldName: 'productDescription', type: 'text',fixedWidth:900,wrapText:true},
                {label: 'Price', fieldName: 'productPrice', type: 'currency', typeAttributes: { currencyCode: 'USD'},fixedWidth:90},
               	{label: 'Remove Product', type: 'button-icon', typeAttributes: { iconName: 'utility:close', 
                                                                                name: 'remove_product', title: 'Remove Product'},fixedWidth:120},
            ];  
        component.set('v.columns',columns);
    },
    
    removeProductHelper : function(component,event,helper){
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('row :',row);
        var mainSelectedProducts = component.get('v.mainSelectedProducts');
        const index = mainSelectedProducts.indexOf(row);
        console.log('index :',index);
        if (index > -1) {
            mainSelectedProducts.splice(index, 1);
        }
        component.set('v.mainSelectedProducts',mainSelectedProducts);
        var appEvent = $A.get("e.c:RemoveProductEvent");
        appEvent.setParams({
            "productId" : row.productDetailID
        });
        appEvent.fire();
     }
})