public with sharing class OppJoinNowVerificationController {

    @AuraEnabled(cacheable=true)
    public static List<String> getDetails(ID oppID) {
        system.debug('oppID----->'+oppID);
        Id idPDRecordType = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
        Opportunity opp = [SELECT Employee_Count_Needs_Verified__c, Company_Type_Needs_Verified__c, Product_Tier_Needs_Verification__c,
                                  Account.Name, Account.NumberOfEmployees,Account.No_Of_Employess__c, Account.Company_Type__c,
                                  Join_Now_Company_Type__c, Type
                           FROM Opportunity
                           WHERE Id = :oppID
                           LIMIT 1
                          ];
        
        OpportunityLineItem oli = [SELECT Membership_Tier__c, Start_Tier__c ,End_Tier__c, Product_Details__r.RecordTypeId
                                   FROM OpportunityLineItem
                                   WHERE OpportunityId = :oppID
                                   AND Product_Details__r.RecordTypeId = :idPDRecordType
                                   LIMIT 1
                                  ];

        List<String> details = new List<String>();
        details.add(String.valueOf(opp.Employee_Count_Needs_Verified__c)); 
        details.add(String.valueOf(opp.Company_Type_Needs_Verified__c));

        if (opp.Type == 'Renewal') {
            details.add(String.valueOf(opp.Product_Tier_Needs_Verification__c));
        } else {
            details.add('false');
        }
        system.debug('result 2: ' + details[2] );
        details.add(opp.Account.Name);

        if(opp.Account.No_Of_Employess__c != null){
            details.add(opp.Account.No_Of_Employess__c);
        }else {
            details.add('');
        }
        if (opp.Account.NumberOfEmployees != null) {
            details.add(String.valueOf(opp.Account.NumberOfEmployees));
        }else {
            details.add(String.valueOf(opp.Account.NumberOfEmployees));
        }
        
        if(opp.Account.Company_Type__c == null){
            details.add('');
        }else{
            details.add(opp.Account.Company_Type__c);
        }
        
        if(opp.Join_Now_Company_Type__c == null){
            details.add('');
        }else{
            details.add(opp.Join_Now_Company_Type__c);
        }

        if(oli.Membership_Tier__c == null){
            details.add('');
        }else{
            details.add(String.valueOf(oli.Membership_Tier__c));
        }

        if (oli.Start_Tier__c == null ) {
            details.add('');
        } else {
            details.add(string.valueOf(oli.Start_Tier__c));
        }

        if (oli.End_Tier__c == null ) {
            details.add('');
        } else {
            details.add(string.valueOf(oli.End_Tier__c));
        }

        system.debug('details--->'+details);
        return details;
    }





    /*@AuraEnabled(cacheable=true)
    //returns 'error', 'no change', or message describing change to Opportunity Product(s)
    public static List<String> getCorrectProductDetails(ID oppID, String employeesChoice, String typeChoice) {

        //if there's no change, then no need to proceed -- just use current products
        if( (employeesChoice == null || employeesChoice == 'useJoinNowValue') &&
            (typeChoice == null || typeChoice == 'useJoinNowValue')
          ){
            List<String> returnValues = new List<String>();
            returnValues.add('no change'); 
            return returnValues;
          }

        Opportunity opp = [SELECT Employee_Count_Needs_Verified__c, Company_Type_Needs_Verified__c,
                                  Account.Name, Account.NumberOfEmployees, Account.Company_Type__c,
                                  Join_Now_Company_Type__c
                           FROM Opportunity
                           WHERE Id = :oppID
                           LIMIT 1
                          ];
        
        List<OpportunityLineItem> currentOLIs = new List<OpportunityLineItem>();
        currentOLIs = [SELECT Name, Product_Details__r.Start_Tier__c, Product_Details__r.End_Tier__c,
                              Product_Details__r.Restricted_by_Company_Type__c, Membership_Tier__c,
                              Product_Details__c, Projects__c, Projects__r.Name, Product2Id
                       FROM OpportunityLineItem
                       WHERE OpportunityId = :oppID
                      ];

        Integer employees = 0;
        if(employeesChoice == 'useJoinNowValue' && currentOLIs[0].Membership_Tier__c != null ){
            employees = Integer.valueOf(currentOLIs[0].Membership_Tier__c);
        }else if(employeesChoice == 'useAccountValue' || employeesChoice == null){
            employees = opp.Account.NumberOfEmployees;
        }

        String type = '';
        if(typeChoice == 'useJoinNowValue'){
            type = opp.Join_Now_Company_Type__c;
        }else if( (typeChoice == 'useAccountValue' || typeChoice == null) && opp.Account.Company_Type__c != null ){
            type = opp.Account.Company_Type__c;
        //if we're not using the Join Now value, and the Account doesn't have a value, assume private company
        }else{
            type = 'private';
        }

        Boolean employeesChange = false;
        if(opp.Employee_Count_Needs_Verified__c == true && employeesChoice == 'useAccountValue'){
            employeesChange = true;
        }

        Boolean typeChange = false;
        if(opp.Company_Type_Needs_Verified__c == true && typeChoice == 'useAccountValue'){
            typeChange = true;
        }

        //get Projects, Product Details, and Product IDs from the current OLIs
        Set<ID> projectIDs = new Set<ID>();
        List<ID> currentProductDetailIDs = new List<ID>();
        Set<ID> productIDs = new Set<ID>();
        for(OpportunityLineItem oli : currentOLIs){
            projectIDs.add(oli.Projects__c);
            currentProductDetailIDs.add(oli.Product_Details__c);
            productIDs.add(oli.Product2Id);
        }

        //get product details for which this company is eligible, based on employee count only
        List<Product_Details__c> prodDetailOptions = new List<Product_Details__c>();
        prodDetailOptions = [SELECT Start_Tier__c, End_Tier__c, Restricted_by_Company_Type__c,
                                    Products__c, Price__c, Products__r.Family, Products__r.Name,
                                    Project__c, Name, Project__r.Name
                             FROM Product_Details__c
                             WHERE Project__c IN :projectIDs
                             AND Products__r.Family = 'Membership'
                             AND Status__c = 'Active'
                             AND Do_Not_Display_in_JoinNow__c = false
                             AND (Start_Tier__c = null OR
                                  (Start_Tier__c <= :employees AND End_Tier__c >= :employees) OR
                                  (Start_Tier__c <= :employees AND End_Tier__c = null)
                                 )
                             ORDER BY Price__c ASC //do not change
                            ];

        //DEBUG: loop through prodDetailOptions
        System.debug('product detail options found initially:');
        for(Product_Details__c pd : prodDetailOptions){
            System.debug(pd.Project__r.Name + ' : ' + pd.Products__r.Name + ' : ' + pd.Name);
        }
        
        //remove any prod details restricted by company type from list if this account isn't eligible for them
        if(type == 'private' || type == 'public' || type == 'personal'){
            for(Integer i = prodDetailOptions.size()-1; i>=0; i--){
                if(prodDetailOptions[i].Restricted_by_Company_Type__c == true){
                    prodDetailOptions.remove(i);
                }
            }
        }

        //DEBUG: loop through prodDetailOptions
        System.debug('product detail options found after restricted ones were removed:');
        for(Product_Details__c pd : prodDetailOptions){
            System.debug(pd.Project__r.Name + ' : ' + pd.Products__r.Name + ' : ' + pd.Name);
        }

        //create set of IDs from prodDetailsOptions list
        Set<ID> prodDetailOptionIDs = new Set<ID>();
        for(Product_Details__c prodDetail : prodDetailOptions){
            prodDetailOptionIDs.add(prodDetail.Id);
        }

        List<String> returnValues = new List<String>();
        String message = '';
        Boolean errorOccurred = false;
        for(OpportunityLineItem oli : currentOLIs){
            Boolean pdFound = false;
            
            //if the Product Detail on this OLI is NOT in the List of Product Details this company is eligible for,
            if(!prodDetailOptionIDs.contains(oli.Product_Details__c)){

                //first, try choosing a Product Detail this company is eligible for that has the same product as the
                //Product Detail already selected -- in other words: choose a different tier of the same membership level
                for(Product_Details__c pd : prodDetailOptions){
                    if(oli.Projects__c == pd.Project__c && oli.Product2Id == pd.Products__c){
                        returnValues.add(oli.Id);
                        returnValues.add(pd.Id);
                        message += 'The product for ' + oli.Projects__r.Name + ' will change to a ';
                        message += pd.Products__r.Name + ' priced at $' + pd.Price__c.format() + '. ';
                        pdFound = true;
                        break;
                    }
                }

                //if that didn't work (i.e. a Product Detail wasn't found yet), then choose the cheapest membership
                //Product Detail for this Project that this company is eligible for
                //(since the prodDetailOptions query is sorted by price ASC, that will be the first PD in the list)
                if(!pdFound){
                    for(Product_Details__c pd : prodDetailOptions){
                        if(oli.Projects__c == pd.Project__c){
                            returnValues.add(oli.Id);
                            returnValues.add(pd.Id);
                            returnValues.add(pd.Products__c);
                            message += 'The product for ' + oli.Projects__r.Name + ' will change to a ';
                            message += pd.Products__r.Name + ' priced at $' + pd.Price__c.format() + '. ';
                            pdFound = true;
                            break;
                        }
                    }
                }

            }else{
                message += 'The product for ' + oli.Projects__r.Name + ' will not change. ';
                pdFound = true;
            }

            if(!pdFound){
                errorOccurred = true;
            }
        }

        //if an error occurred, overwrite message
        if(errorOccurred){
            message = 'error';
        }

        //add message as first item in list to be returned
        if(returnValues.size() == 0){
            returnValues.add(message);
        }else{
            returnValues.add(0, message);
        }
        
        return returnValues;
    }
*/




    @AuraEnabled
    //expects the data returned by getCorrectProductDetails as the 'result' parameter
    public static Boolean makeUpdates(ID oppID, String employeesChoice, string productsChoice, String typeChoice,
                                      String typeSubmitted) {
                                          
                                              
        /*if(result[0] == 'error'){
            return false;
        }*/

        //query Opp
        Opportunity opp = [SELECT AccountId, Employee_Count_Needs_Verified__c,
                                  Company_Type_Needs_Verified__c, Product_Tier_Needs_Verification__c
                           FROM Opportunity
                           WHERE Id = :oppID
                          ];

        //determine if any changes to Account need to be made
        Boolean accountChanges = false;
        if(employeesChoice == 'useJoinNowValue' || typeChoice == 'useJoinNowValue' || employeesChoice == 'useAccountValue' ){
            accountChanges = true;
        } 

        //handle changes to Account
        if(accountChanges){
            Account acc = [SELECT Id,No_Of_Employess__c, Last_Employee_Size_Verified_Date__c FROM Account WHERE Id = :opp.AccountId];
            if(employeesChoice == 'useJoinNowValue'){
                //update JoinNow Validated date
                acc.Last_Employee_Size_Verified_Date__c = date.today();
                opp.Employee_Count_Needs_Verified__c = false;
            } else if (employeesChoice == 'useAccountValue') {
                //clear JoinNow employees
                acc.No_Of_Employess__c = '';
                opp.Employee_Count_Needs_Verified__c = false;
            }

            if(typeChoice == 'useJoinNowValue'){
                acc.Company_Type__c = typeSubmitted;
                acc.JoinNow_Company_Type__c = date.today();
            }
            try {
                update acc;
            } catch (DmlException e) {
                system.debug('Error updating Account: ' + e.getMessage());
            } 
        }

                                          /*
        //determine if any changes to Opportunity Line Items need to be made
        Boolean oliChanges = true;
        if(result[0] == 'no change'){
            oliChanges = false;
        }

        //handle changes to Opportunity Line Items
        if(oliChanges){
            //create map that will hold all OLIs that need updated with the Product Detail
            //that OLI needs to be updated to
            Map<ID, ID> olisToNewPD = new Map<ID, ID>();

            //create map that will hold all OLIs that need updated with the Product that
            //OLI needs to be updated to
            Map<ID, ID> olisToNewProduct = new Map<ID, ID>();
            
            //populate map from result array
            //note that the item at index 0 of the result array is a message displayed to
            //the user, so it should be ignored here
            ID currentOLI = null;
            for(Integer i=1; i<result.size(); i++){
                //the items at index 1, 4, 7, etc. of the result array is the ID of an
                //Opportunity Line Item that needs to be updated
                if(Math.mod(i, 3) == 1){
                    currentOLI = result[i];

                //the items at index 2, 5, 8, etc. of the result array is the ID of the
                //Product Detail that the previous OLI ID in the array needs to be updated to
                }else if(Math.mod(i, 3) == 2){
                    olisToNewPD.put(currentOLI, result[i]);

                //the items at index 3, 6, 9, etc. of the result array is the ID of the
                //Product that the previous OLI ID in the array needs to be updated to
                }else if(Math.mod(i, 3) == 0){
                    olisToNewProduct.put(currentOLI, result[i]);
                    currentOLI = null;
                }
            }

            //query Opportunity Line Items to update
            List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem>();
            olisToUpdate = [SELECT Id FROM OpportunityLineItem WHERE Id IN :olisToNewPD.keySet()];

            //update Product Detail and Product on all OLIs to be updated
            for(OpportunityLineItem oli : olisToUpdate){
                oli.Product_Details__c = olisToNewPD.get(oli.Id);
                oli.Product2Id = olisToNewProduct.get(oli.Id);
            }
            update olisToUpdate;
        }*/

        //update verification checkboxes on Opp so that LWC will disappear
        opp.Employee_Count_Needs_Verified__c = false;
        opp.Product_Tier_Needs_Verification__c = false;
        opp.Company_Type_Needs_Verified__c = false;
        update opp;
       
        if(employeesChoice=='useAccountValue' || productsChoice == 'useClearbitValue'){
            UpdateProductDetails(oppID);
        }
        system.debug('Products Choice = ' + productsChoice);

        return true;
    }

    //this method has been moved to ChangeProductUtil
    //public static void changeProductDetailOnOLI(ID oliID, ID pdID)
    //
    Private static void UpdateProductDetails(Id oppID){
        system.debug('oppID--->'+oppID);
        Id idPDRecordType = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
        set<Id> setProjectIds = new set<Id>();
        set<Id> setProductIds = new set<Id>();
        set<Id> setAccountIds = new set<Id>();
        map<Id,OpportunityLineItem> mapOpportunity = new map<Id,OpportunityLineItem>();
        Integer NumberOfEmployee;
        
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        for(OpportunityLineItem objOppLineItem : [Select id,Opportunity.AccountId,Projects__c,Product2Id,Opportunity.Account.NumberOfEmployees, Product_Details__r.RecordTypeId,name from OpportunityLineItem where OpportunityId =:oppID and Product_Details__r.RecordTypeId = :idPDRecordType]){
            setAccountIds.add(objOppLineItem.Opportunity.AccountId);
            for(Product_Details__c objProjectDetails:[Select id,Project__r.id,name,Start_Tier__c,End_Tier__c from Product_Details__c where Project__r.id =:objOppLineItem.Projects__c AND Products__c =:objOppLineItem.Product2Id]){
                if(objProjectDetails.Start_Tier__c < Integer.valueOf(objOppLineItem.Opportunity.Account.NumberOfEmployees) && objProjectDetails.End_Tier__c > Integer.valueOf(objOppLineItem.Opportunity.Account.NumberOfEmployees)){
                    system.debug('objopplineitem: ' + objOppLineItem.Name);
                    system.debug('objProjectDetails: ' + objProjectDetails.Name);
                    objOppLineItem.Product_Details__c = objProjectDetails.id;  
                    lstOpportunityLineItem.add(objOppLineItem);
                }else if(objProjectDetails.Start_Tier__c < Integer.valueOf(objOppLineItem.Opportunity.Account.NumberOfEmployees) && objProjectDetails.End_Tier__c == null){
                    system.debug('objopplineitem-no end tier: ' + objOppLineItem.Name);
                    system.debug('objProjectDetails-no end tier: ' + objProjectDetails.Name);
                    objOppLineItem.Product_Details__c = objProjectDetails.id;  
                    lstOpportunityLineItem.add(objOppLineItem);
                }
            }
        }
        if(lstOpportunityLineItem.size()>0){
            mapOpportunity.putAll(lstOpportunityLineItem);
         update mapOpportunity.values();
         //UpdateEmployeeOnAccount(setAccountIds);
        }
    }



    Private static void UpdateEmployeeOnAccount(set<Id> AccountId){
        Account acc = [SELECT Id,No_Of_Employess__c,NumberOfEmployees FROM Account WHERE Id IN:AccountId];
        acc.NumberOfEmployees = Integer.valueOf(acc.No_Of_Employess__c);
        update acc;
    }
}