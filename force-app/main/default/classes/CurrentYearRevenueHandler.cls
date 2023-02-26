public class CurrentYearRevenueHandler {
    public static void updateCurrentYearRevenue(map<Id, Asset> newMap, map<Id, Asset> oldMap) {
        system.debug('newMap :::: ' + newMap);
        system.debug('oldMap :::: ' + oldMap);
        
        Integer currentYear = system.today().year();
        system.debug('currentYear :::: ' + currentYear);
        
        list<Asset> assetList = [SELECT Id, Price, Project__c FROM Asset WHERE Status != 'Invoice Cancelled' AND ((PurchaseDate != null AND CALENDAR_YEAR(PurchaseDate)=:currentYear) OR (InstallDate!=null AND CALENDAR_YEAR(InstallDate)=:currentYear))];
        system.debug('assetList :::: ' + assetList);
        
    }
}