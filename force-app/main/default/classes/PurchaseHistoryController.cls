public class PurchaseHistoryController {

Public string getCustombaseUrl(){return URL.getSalesforceBaseUrl().toExternalForm();}

/*Display All records with filter SalesOrderNumber__c,
Skip_NetSuite_Sync__c,createddate,Status,RecordType.Name
For More Detail JIRA SFDC-1847
*/
public list<Asset> getAssetList(){
        
		return [SELECT Name,
                        CreatedDate
                        FROM Asset 
                        WHERE SalesOrderNumber__c='' 
                        AND Skip_NetSuite_Sync__c = false
                        AND Price !=0
                        AND createddate <:System.now()-1
                        AND Status IN ('Purchased','Active')
                        AND RecordType.Name IN ('Corporate','Corporate_Training')
                        LIMIT 1000
                        ];
        

    }
}