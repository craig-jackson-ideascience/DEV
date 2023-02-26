public with sharing class OppChangeProductController {

        @AuraEnabled(cacheable=false)
        public static List<List<Product_Details__c>> getOptions(ID oppID){
            //get current membership Opportunity Products on this opp
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            olis = [SELECT Projects__c, Projects__r.Name, Product_Details__c, Product2.Name
                    FROM OpportunityLineItem
                    WHERE OpportunityId = :oppID
                    AND Product2.Family = 'Membership'
                    ORDER BY Product2.Name ASC
                ];
            
            //if no membership Opportunity Products were found, return empty list
            if(olis.size() == 0){
                List<List<Product_Details__c>> emptyList = new List<List<Product_Details__c>>();
                return emptyList;
            }
            
            //create and populate a map of the Projects on the current Opportunity Products
            //create and populate a set of the Product Details on the current Opportunity Products
            Set<ID> projects = new Set<ID>();
            Set<ID> prodDetailsSelected = new Set<ID>();
            for(OpportunityLineItem oli : olis){
                projects.add(oli.Projects__r.Id);
                prodDetailsSelected.add(oli.Product_Details__c);
            }

            //check for a few scenarios (that shouldn't ever happen, but just in case)
            //that could break the LWC, and return null if any are true
            if( olis.size() != projects.size() ){
                System.debug('error: number of distinct Project IDs found on Opp Products does not match number of Opp Products found');
                return null;
            }else if( olis.size() != prodDetailsSelected.size() ){
                System.debug('error: number of distinct Product Detail IDs found on Opp Products does not match number of Opp Products found');
                return null;
            }else if(olis.size() > 2){
                System.debug('error: more than two membership Opp Products were found');
                return null;
            }
            
            //get all possible (active) Product Details for these Projects,
            //except the ones that are already on this opportunity
            List<Product_Details__c> prodDetails = new List<Product_Details__c>();
            prodDetails = [SELECT Project__c, Start_Tier__c, End_Tier__c, Price__c,
                                Project__r.Name, Products__r.Name
                        FROM Product_Details__c
                        WHERE Project__c IN :projects
                        AND Id NOT IN :prodDetailsSelected
                        AND Status__c = 'Active'
                        AND Products__r.Family = 'Membership'
                        AND Products__r.Name != 'Individual Supporter'
                        AND Products__r.Name != 'Lifetime Linux.com Email Add-On'
                        AND Products__r.Name != 'Silver Membership - MPSF'
                        ORDER BY Products__r.Name ASC, Price__c DESC
                        ];

            //split the prodDetails returned into two different lists (one for each project),
            //if there were two OLIs
            List<Product_Details__c> prodDetails1 = new List<Product_Details__c>();
            List<Product_Details__c> prodDetails2 = new List<Product_Details__c>();
            for(Product_Details__c pd : prodDetails){
                if(pd.Project__c == olis[0].Projects__c){
                    prodDetails1.add(pd);
                }else if(olis.size() == 2 && pd.Project__c == olis[1].Projects__c){
                    prodDetails2.add(pd);
                }
            }

            //create and populate list to be returned
            List<List<Product_Details__c>> listOfLists = new List<List<Product_Details__c>>();
            if(prodDetails1.size() > 0){
                listOfLists.add(prodDetails1);
            }
            if(prodDetails2.size() > 0){
                listOfLists.add(prodDetails2);
            }
            return listOfLists;
        }

        @AuraEnabled
        public static void updateProducts(ID oppID, List<ID> selectedProdDetailIDs){
            //get current membership Opportunity Products on this opp
            Map<Id, OpportunityLineItem> olis = new Map<Id, OpportunityLineItem>([SELECT OpportunityId, Product2Id, Product_Details__c, Prorate__c, 
            PO_Number__c, Skip_NetSuite_Sync__c, Skip_Sync_Updated_By__c,
            Skip_Sync_Updated_On__c, CNCF_Level__c, Renewal_Campaign__c,
            Membership_Tier__c, Quote_Product__c, Account_Team_Member__c,
            Team_Member_Title__c, AgreementDate__c, Quantity, Type__c,
            Start_Date__c, End_Date__c, Year__c, NetSuite_Invoice_Memo__c,
            Display_Logo_On_Website__c, No_Press_Release_Announcement__c,
            Send_Date__c, Parent_Product__c, Projects__c,
            Opportunity.Parent_Asset__r.Annual_Full_Price__c, Opportunity.Type
                    FROM OpportunityLineItem
                    WHERE OpportunityId = :oppID
                    AND Product2.Family = 'Membership'
                    ]);

            //create a map of Project ID to OLI ID
            Map<ID, Id> projectIDToOLIID = new Map<ID, Id>();
            for(OpportunityLineItem oli : olis.values()){
                projectIDToOLIID.put(oli.Projects__c, oli.Id);
            }

            //get the Project of each Product Detail selected
            List<Product_Details__c> selectedProdDetails = new List<Product_Details__c>();
            selectedProdDetails = [SELECT Project__c, Products__c, Start_Tier__c, End_Tier__c, Tier__c, Number_Of_Years_Required__c,
            Renewal_Type__c, NetSuite_Class__c, toLabel(NS_Department__c),
            toLabel(NS_Deferred_Revenue_Account__c), toLabel(NS_Income_GL_Account__c),
            toLabel(NS_Revenue_Schedule__c), Netsuite_ID__c, Tax_Class__c, Price__c
                                FROM Product_Details__c
                                WHERE Id IN :selectedProdDetailIDs
                                ];
            
            //map each Product Detail selected to the correct Opp Product
            //by looking at the Project on each
            Map<Id, Product_Details__c> oliIDToProdDetailID = new Map<ID, Product_Details__c>();
            for(Product_Details__c pd : selectedProdDetails){
                oliIDToProdDetailID.put( projectIDToOLIID.get(pd.Project__c), pd );
            }
            
            //Added by Priyesh @cloudroute to bulkify
            ChangeProductUtil.changeProductDetailOnOLI(oliIDToProdDetailID, olis);

            return;
        }

    }