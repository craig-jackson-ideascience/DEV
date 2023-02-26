// Controller class for the Force.com Typeahead component
public without sharing class Typeahead {


    @RemoteAction
    public static list<sObject> searchRecords(String queryString, String objectName,
            list<String> fieldNames, String fieldsToSearch, String filterClause, String orderBy, Integer recordLimit, String queryName) {

        System.debug(filterClause + '====> filterClause');
        if (queryString == null) return null;
        if (queryName == 'SOSL') {
            String sQuery = String.escapeSingleQuotes(queryString);
            if (sQuery.length() == 0) return null;

            String sObjectName = (objectName == null) ? 'Contact' : String.escapeSingleQuotes(objectName);

            String sInFields =
                    (fieldsToSearch == null || fieldsToSearch == '' || fieldsToSearch.toUpperCase() == 'ALL') ? '' :
                            (' IN ' + String.escapeSingleQuotes(fieldsToSearch) + ' FIELDS');

            String sFields = (fieldNames == null || fieldNames.isEmpty()) ? 'Id, Name' :
                    String.escapeSingleQuotes(String.join(fieldNames, ', '));

            String sOrder = ' ORDER BY ' + ((orderBy == null || orderBy == '') ? 'Name' : String.escapeSingleQuotes(orderBy));

            String sLimit = (recordLimit == null || recordLimit == 0 || recordLimit >= 2000) ? '' :
                    (' LIMIT ' + String.valueOf(recordLimit));

            // can't escape the filter clause
            String sWhere = (filterClause == null || filterClause == '') ? '' :
                    (' WHERE ' + filterClause);

            system.debug('--query---' + 'FIND \'' + sQuery + '*\'' + sInFields +
                    ' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )');
            list<list<sObject>> results = Search.query(
                    'FIND \'' + sQuery + '*\'' + sInFields +
                            ' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )'
            );
            System.debug(results + '==> results');
            System.debug('FIND \'' + sQuery + '*\'' + sInFields + ' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )' + '==> query');
            return results[0];
        } else if (queryName == 'SOQL') {
            String j = '%' + queryString + '%';
            system.debug('----' + fieldsToSearch);
            system.debug('----' + fieldNames);
            system.debug('#--#' + filterClause);
            String query = 'select id,name  from contact where email like :j and ' + filterClause;
            query += ' order by lastModifiedDate desc limit 10000' ;
            list<sobject> results = Database.query(query);
            system.debug('---' + results);
            return results;
        }
        return null;
    }

}