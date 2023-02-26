/**
* Created by cloudroutesolutions on 20/01/21.
*/
public with sharing class AccountReceivableChartController{
    @AuraEnabled
    public static Project__c getSelectedProjectDetails(String foundationId){
        system.debug('foundationId=> ' + foundationId);
        return [Select Id, Name from Project__c where Id =: foundationId];
    }
    
    @AuraEnabled
    public static String getAccountReceivableDetails(String foundationId, String daysFromPurchaseDate){
        system.debug('<=:::::getARDetails::::=>');
        system.debug('foundationId::::=> ' + foundationId + ' daysFromPurchaseDate::::=> ' + daysFromPurchaseDate);
        //List<Object> listOfPurchaseDate = (List<Object>)JSON.deserializeUntyped(daysFromPurchaseDate);
        Integer daysFromPurchaseDateInt = Integer.valueOf(daysFromPurchaseDate);
        list<AggregateResult> arList = new list<AggregateResult>();
        String sSoql;
        try{
            
            Double sumOfdata = 0;
            Map<String, Double> assetDaysVsPrice = new Map<String, Double>();
            Id recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
            for (Asset a : [SELECT Name, Price, Days__c
                            FROM Asset
                            WHERE Projects__r.Id = :foundationId AND (Status = 'Active' OR Status = 'Purchased') AND SalesOrderStatus__c = 'Open' AND Days__c != 0 AND RecordTypeId =: recordTypeId
                            ORDER BY Days__c ASC]){
                                String days = String.valueOf(Integer.valueOf(a.Days__c));
                                if (assetDaysVsPrice.containsKey(days)){
                                    Double sumPrice = assetDaysVsPrice.get(days)+a.Price;
                                    sumOfdata += a.Price; 
                                    system.debug('sumOfdata '+sumOfdata);
                                    assetDaysVsPrice.put(days, sumPrice);
                                } else{
                                    
                                    sumOfdata += a.Price; 
                                    system.debug('sumOfdata '+sumOfdata);
                                    assetDaysVsPrice.put(days, a.Price);
                                }
                            }

            System.debug('sumOfdata: ' + sumOfdata);
            System.debug('assetDaysVsPrice: ' + assetDaysVsPrice);
            
            List<String> listOfLabel = new List<String>();
            listOfLabel.addAll(assetDaysVsPrice.keySet());
            List<Decimal> listOfData = new List<Decimal>();
            listOfData.addAll((List<Decimal>)assetDaysVsPrice.values());
            Map<String,Double> listOfPercentData = new Map<String,Double>();
            Integer i=0;
            for(Decimal dataValue : listOfData){
                Double percentValue = (dataValue/sumOfdata) * 100;
                String labelKey = listOfLabel[i];
                listOfPercentData.put(labelKey,percentValue);
                i++;

            }
            System.debug('listOfPercentData: ' + listOfPercentData);
            ChartjsData.chartjsDataset dataSet = new ChartjsData.chartjsDataset();
            dataSet.label = 'label';
            dataSet.dataInPercent = listOfData;//[63,73]
            dataSet.listOfPercentData = listOfPercentData;
            dataSet.sumOfdata = sumOfdata;
            dataSet.showCustomValue = true;
            ChartjsData chartjsData = new ChartjsData();
            chartjsData.labels = listOfLabel;//[24thJune,25thJune]
            chartjsData.dataSets = new List<ChartjsData.chartjsDataset>{dataset};
                System.debug('#chart#' + JSON.serialize(chartjsData));
            return JSON.serialize(chartjsData);
        } catch (Exception ex){
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Asset> getAccountReceivableTableDetails(String foundationId, String daysFromPurchaseDate, Boolean applyLimit, String operator, Boolean isList){
        System.debug('#--daysFromPurchaseDate--#' + daysFromPurchaseDate);
        System.debug('#--daysFromPurchaseDate--#' + foundationId);
        list<Asset> arList = new list<Asset>();
        String sSoql;
        Integer daysFromPurchaseDateInt = 0;
        Id recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        String whereClauseDays = 'AND (';
        String columns = 'Id, Name, PurchaseDate, Price, Days_GroupBy__c ';
        if (isList){
            List<Object> listOfPurchaseDate = (List<Object>)JSON.deserializeUntyped(daysFromPurchaseDate);
            System.debug('#--listOfPurchaseDate--#' + listOfPurchaseDate);
            for (Integer i = 0; i < listOfPurchaseDate.size(); i++){
                if (String.valueOf(listOfPurchaseDate[i]) != 'All'){
                    Integer dateInt = Integer.valueOf(listOfPurchaseDate[i]);
                    System.debug('#--dateInt--#' + dateInt);
                    whereClauseDays += operator == 'Equals' || operator == 'contains' ? dateInt == 120 ?  ('Days__c >= '+dateInt) : ('Days__c = '+dateInt) :   dateInt == 120 ?  ('Days__c < '+dateInt ) : ('Days__c != '+dateInt);
                    if (i != listOfPurchaseDate.size() - 1){
                        whereClauseDays += ' OR ';
                    }
                }else{
                    //assign it this because below we are emptying the where clause
                    whereClauseDays = 'And (';
                    break;
                }
            }
            whereClauseDays += ')';
            
        } else{
            List<Object> listOfPurchaseDate = (List<Object>)JSON.deserializeUntyped(daysFromPurchaseDate);
            daysFromPurchaseDateInt = Integer.valueOf(listOfPurchaseDate[0]);
        }
        System.debug('#--whereClauseDays--#' + whereClauseDays);
        System.debug('#--operator--#' + operator);
        if (String.isEmpty(operator)){
            whereClauseDays = daysFromPurchaseDateInt == 0 ? 'AND Days__c != 0' : ' AND Days__c =: daysFromPurchaseDateInt ';
        }
        whereClauseDays = whereClauseDays == 'And ()' ? '' : whereClauseDays;
        sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId AND (Status = \'Active\' OR Status = \'Purchased\') AND SalesOrderStatus__c = \'Open\' AND RecordTypeId =: recordTypeId ' + whereClauseDays + ' ORDER BY PurchaseDate DESC';
        if (applyLimit){
            sSoql += ' LIMIT 10';
        }
        try{
            system.debug('The query is' + sSoql);
            arList = Database.query(sSoql);
            system.debug('assset list' + arList);
            return arList;
        } catch (Exception ex){
            return null;
        }
    }
}