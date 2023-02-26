public class PicklistOptionsUtility {
    public static final String LABEL = 'label';
    public static final String VALUE = 'value';
    public static List<Map<String, String>> getPicklistOptions(DescribeFieldResult fieldResults, boolean addNone,boolean addAll) {
        List<Map<String, String>> selectOptionObjects = new List<Map<String, String>>();
        if (addNone) {
            selectOptionObjects.add(new Map<String, String> {LABEL => '--None--', VALUE => ''});           
        }
         if (addAll) {
            selectOptionObjects.add(new Map<String, String> {LABEL => '--All--', VALUE => ''});           
        }
        List<Schema.PicklistEntry> ple = fieldResults.getPicklistValues();
        for (Schema.PicklistEntry p : ple)
            selectOptionObjects.add(new Map<String, String> {LABEL => p.getLabel(), VALUE => p.getValue()});
        return selectOptionObjects;
    }
    
    public static String getProductDetailsRecordTypeId(String recordTypeName){
        return Schema.SObjectType.Product_Details__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    
}