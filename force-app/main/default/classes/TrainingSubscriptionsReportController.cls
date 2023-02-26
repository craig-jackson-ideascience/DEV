public class TrainingSubscriptionsReportController {
    
    //Method to get the Records to display on table
    @AuraEnabled
    public static List<AssetProductDetail> fetchRecords(Date fromDate,Date toDate){
        
        List<AssetProductDetail> assetProdDetailList = new List<AssetProductDetail>();
        Map<Id,Id> productVSOpportunityId = new Map<Id,Id>();
        Set<Id> trainingIds = new Set<Id>();
        
        //Retrieve the purchase histories between the two dates
        List<Asset> assetList = [SELECT Id,Name,InstallDate,Price,Product2Id,Product2.StockKeepingUnit,Opportunity__c,
                                 Product2.Name,Product2.Type__c,AccountId,Account.Name,Opportunity__r.Amount,
                                 Training__c,OpportunityLineItem__c,Parent_OppLineItem__c
                                 FROM Asset 
                                 Where Training__c != NULL AND
                                 Opportunity__c != NULL AND
                                 Training__r.Category__c ='Subscription' AND
                                 Parent_OppLineItem__c = null AND
                                 InstallDate >=: fromDate AND
                                 InstallDate <=: toDate];
        
        System.debug('assetList '+assetList);
        for(Asset asst:assetList){
            trainingIds.add(asst.Training__c);
            productVSOpportunityId.put(asst.OpportunityLineItem__c,asst.Opportunity__c);
        }
        
        System.debug('trainingIds  '+trainingIds);
        if(!trainingIds.isEmpty()){
            Map<Id,List<OpportunityLineItem>> opprtyIdVSLineItems = new Map<Id,List<OpportunityLineItem>>();
            
            //Retrieve the opportunitylineitem to get the totalprice of Elearning and certification lineitems 
            List<OpportunityLineItem> opportunityLineItemList = [SELECT Id,Totalprice,OpportunityId ,Product2.Name
                                                                 From OpportunityLineItem
                                                                 WHERE Parent_OppLineItem__c IN: productVSOpportunityId.keyset() AND
                                                                 Product2.Type__c IN ('Certification','E-Learning') AND
                                                                 OpportunityId IN: productVSOpportunityId.values()
                                                                 ORDER BY Product2.Name];
            for(OpportunityLineItem oppLineItem : opportunityLineItemList){
                if(!opprtyIdVSLineItems.containsKey(oppLineItem.OpportunityId)){
                    opprtyIdVSLineItems.put(oppLineItem.OpportunityId,new List<OpportunityLineItem>());
                }
                opprtyIdVSLineItems.get(oppLineItem.OpportunityId).add(oppLineItem);
                
            }
            System.debug('opprtyIdVSLineItems '+opprtyIdVSLineItems);
            
            //Retrieve the Product-Details related to the training of Purchase Histories that are retrieved above
            Map<Id,List<Product_Details__c>> TrainingIdVSProductDetail = new Map<Id,List<Product_Details__c>>();
            List<Product_Details__c> productDetailList = [SELECT Name,Products__r.Name,Training__c,Subscription_Calculation__c,
                                                          Products__r.StockKeepingUnit,Price__c,Products__r.Type__c
                                                          FROM Product_Details__c 
                                                          WHERE Training__c IN: trainingIds AND 
                                                          Products__r.Type__c IN ('Certification','E-Learning') AND
                                                          (Price__c != 0 AND Price__c != null)
                                                          ORDER BY Products__r.Type__c
                                                         ];
            
            for(Product_Details__c pr: productDetailList){
                if(!TrainingIdVSProductDetail.containsKey(pr.Training__c)){
                    TrainingIdVSProductDetail.put(pr.Training__c,new List<Product_Details__c>());
                }TrainingIdVSProductDetail.get(pr.Training__c).add(pr);
            }
            System.debug('TrainingIdVSProductDetail  '+TrainingIdVSProductDetail);
            
            if(!TrainingIdVSProductDetail.isEmpty()){
                
                //Iterate over the Purchase History and assigned it to the wrapperclass
                for(Asset ast:assetList){
                    System.debug(ast);
                    System.debug(ast.Account.Name);
                    System.debug(ast.Product2.Name);
                    System.debug(ast.Opportunity__r.amount);
                    AssetProductDetail asstproductDetail = new AssetProductDetail();
                    asstproductDetail.Id=ast.Id;
                    asstproductDetail.accountId=ast.AccountId;
                    asstproductDetail.name=ast.Name;
                    asstproductDetail.accountName=ast.Account.Name;
                    asstproductDetail.installDate = ast.InstallDate;
                    asstproductDetail.amount= ast.Opportunity__r.Amount;
                    asstproductDetail.productName=ast.Product2.Name;
                    asstproductDetail.productCode=ast.Product2.StockKeepingUnit;
                    asstproductDetail.productType=ast.Product2.Type__c;
                    asstproductDetail.trainingProductDetail = new List<TrainingProductDetail>();
                    List<OpportunityLineItem> productPriceList = opprtyIdVSLineItems.get(ast.Opportunity__c);
                    System.debug('productPriceList '+productPriceList);
                    Decimal certificationPrice = productPriceList != null && productPriceList[0] != null ? productPriceList[0].TotalPrice : 0;
                    Decimal elearningPrice = productPriceList != null && productPriceList[1] != null ? productPriceList[1].TotalPrice : 0;
                    System.debug('certificationPrice '+certificationPrice);
                    
                    if(TrainingIdVSProductDetail.containsKey(ast.Training__c)){
                        
                        //Iterate over the product detail
                        for(Product_Details__c prodDetail:TrainingIdVSProductDetail.get(ast.Training__c)){
                            TrainingProductDetail trProductDetail = new TrainingProductDetail();
                            
                            trProductDetail.productName=prodDetail.Products__r.Name;
                            trProductDetail.productCode=prodDetail.Products__r.StockKeepingUnit;
                            trProductDetail.productType=prodDetail.Products__r.Type__c;
                            
                            trProductDetail.price = prodDetail.Products__r.Type__c == 'Certification' ? certificationPrice : elearningPrice ;
                            trProductDetail.revenue = prodDetail.Subscription_Calculation__c != null ? 
                                prodDetail.Subscription_Calculation__c * trProductDetail.price /100 :
                            null;
                            trProductDetail.percentageAmount = prodDetail.Subscription_Calculation__c != null ? prodDetail.Subscription_Calculation__c : null;
                            asstproductDetail.trainingProductDetail.add(trProductDetail);
                        }
                    }
                    
                    System.debug('asstproductDetail '+asstproductDetail);
                    assetProdDetailList.add(asstproductDetail);
                }
            }
        }
        
        //return the wrapperclass instance
        return assetProdDetailList;
    }
    
    //Method to generate the record data as a string to get it download in the form of csv
    @AuraEnabled
    public static String generateCsv(String records){
        
        String csvStringResult;
        List<AssetProductDetail> assetProductDetailList = (List<AssetProductDetail>)JSON.deserialize(records,List<AssetProductDetail>.class);
        System.debug('assetProductDetailList '+assetProductDetailList.size()+' '+assetProductDetailList);
        
        List<String> header = new List<String>{'Purchase History Name','Account Name','Install Date','Amount','ProductName','Product Code','Product Type',' % or amount','Actual revenue'};
        Integer counter;
        
        //Check if the records is empty or not
        if (!assetProductDetailList.isEmpty()) {
            csvStringResult = '';
            csvStringResult += string.join(header,',');
            csvStringResult += '\n';
            List<String> detailRecordsList = new List<String>();
            
            //Iterate over the records and create a string
            for(AssetProductDetail asstProductDetail : assetProductDetailList){
                System.debug('asstProductDetail '+asstProductDetail);
                
                List<String> detailRecord = new List<String>();
                detailRecord.add(asstProductDetail.name);
                detailRecord.add(asstProductDetail.accountName != null ? asstProductDetail.accountName.escapeCsv() : '');
                detailRecord.add(String.valueOf(asstProductDetail.installDate));
                detailRecord.add('$'+String.valueOf(asstProductDetail.amount));
                detailRecord.add(asstProductDetail.productName.escapeCsv());
                detailRecord.add(asstProductDetail.productCode != null ? asstProductDetail.productCode : '');
                detailRecord.add(asstProductDetail.productType);
                detailRecord.add('');
                detailRecord.add('');
                detailRecordsList.add(string.join(detailRecord, ','));
                
                System.debug('asstProductDetail tr'+asstProductDetail.trainingProductDetail);
                for(TrainingProductDetail trngProductDetail : asstProductDetail.trainingProductDetail){
                    detailRecord = new List<String>();
                    detailRecord.add('');
                    detailRecord.add(asstProductDetail.accountName != null ? asstProductDetail.accountName : '');
                    detailRecord.add(String.valueOf(asstProductDetail.installDate));
                    detailRecord.add('$'+String.valueOf(asstProductDetail.amount));
                    detailRecord.add(trngProductDetail.productName.escapeCsv());
                    detailRecord.add(trngProductDetail.productCode != null ? trngProductDetail.productCode : '');
                    detailRecord.add(trngProductDetail.productType != null ? trngProductDetail.productType : '');
                    detailRecord.add(trngProductDetail.percentageAmount != null ? String.valueOf(trngProductDetail.percentageAmount)+'%' : '');                
                    detailRecord.add(trngProductDetail.revenue != null ? '$'+String.valueOf(trngProductDetail.revenue) : '');
                    detailRecordsList.add(string.join(detailRecord, ','));
                }
                
            }
            
            csvStringResult += string.join(detailRecordsList,'\n');
            System.debug('csvStringResult '+csvStringResult);
        }
        return csvStringResult;
    }
    
    //Wrapper class to store the details of Asset and the product details of its associated training
    public class AssetProductDetail{
        @AuraEnabled public String Id;
        @AuraEnabled public String accountId;
        @AuraEnabled public String name;
        @AuraEnabled public String accountName;
        @AuraEnabled public Date installDate;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String productName;
        @AuraEnabled public String productCode;
        @AuraEnabled public String productType;
        @AuraEnabled public List<TrainingProductDetail> trainingProductDetail;
        
    }
    public class TrainingProductDetail{
        
        @AuraEnabled public Decimal price;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal percentageAmount;
        @AuraEnabled public String productCode;
        @AuraEnabled public String productType;
        @AuraEnabled public Decimal revenue;
    }
}