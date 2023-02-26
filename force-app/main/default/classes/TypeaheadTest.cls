/********************************************************
 * Created by: megatron @ CloudRoute Solutions
 * Created Date: 15-Feb-19.
 * Description: TypeaheadTest
 ********************************************************/
@IsTest
private class TypeaheadTest {
    static testMethod void testBehavior() {
        String query = 'Test Contact';
        String objectName = 'Contact';
        List<String> queryfields = new  List<String>{'Id, Name'};
        String fieldsTOSearch = 'Name';
        String filter = 'AccountId!=null';
        String orderBy = 'Name';
        Integer reclimit = 100;
        String queryName = 'SOQL';
        //Typeahead obj = new Typeahead();
        Typeahead.searchRecords(query, objectName, queryfields, fieldsTOSearch, filter, orderBy, reclimit,queryName);
    }
    static testMethod void testBehavior2() {
        String query = 'Test Contact';
        String objectName = 'Contact';
        List<String> queryfields = new  List<String>{'Id, Name'};
        String fieldsTOSearch = 'Name';
        String filter = '';
        String orderBy = 'Name';
        Integer reclimit = 100;
        String queryName = 'SOSL';
        //Typeahead obj = new Typeahead();
        Typeahead.searchRecords(query, objectName, queryfields, fieldsTOSearch, filter, orderBy, reclimit,queryName);
    }
}