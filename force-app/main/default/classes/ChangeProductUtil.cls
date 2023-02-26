public with sharing class ChangeProductUtil {
    
    //expects the ID of the OLI that needs to be updated, along with the ID of the Product Detail
    //that the OLI should be updated to
    @AuraEnabled
    public static void changeProductDetailOnOLI(Map<Id, Product_Details__c> oliIDToProdDetail, Map<Id, OpportunityLineItem> oliIdToOli){

        //TODO: bulkify method to accept a map of OLI IDs to PD IDs (instead of one of each)
        map<String, OpportunityLineItem> upsertOlis = new Map<String, OpportunityLineItem>();
        List<OpportunityLineItem> deleteOlis = new List<OpportunityLineItem>();
        Set<String> oliIDStrings = new Set<String>();
        Map<Id, Opportunity> updateOpp = new Map<Id, Opportunity>();

        System.debug('oliIDToProdDetail--'+oliIDToProdDetail);

        for(Id oliId : oliIDToProdDetail.keySet()){
            System.debug('oliId--'+oliID);
            OpportunityLineItem oli = oliIdToOli.get(oliId);
            Product_Details__c pd = oliIDToProdDetail.get(oliId);

            System.debug('pd--'+pd);
            System.debug('oli--'+oli);
            //check if new Product Detail is the same Product as old Product Detail
            Boolean noProductChange = false;
            if(oli.Product2Id == pd.Products__c){
                noProductChange = true;
            }

            //if there's no product change (i.e. there's only a Product Detail change),
            //update the existing OLI
            if(noProductChange){
                System.debug('no product change');

                //updates from Product Detail
                oli.Product_Details__c = pd.Id;
                oli.Start_Tier__c = pd.Start_Tier__c;
                oli.End_Tier__c = pd.End_Tier__c;
                oli.Tier__c = pd.Tier__c;
                oli.Number_of_Years_Required__c = Integer.valueOf(pd.Number_Of_Years_Required__c);
                oli.Renewal_Type__c = pd.Renewal_Type__c;
                oli.NetSuite_Class__c = pd.NetSuite_Class__c;
                oli.NetSuite_Department__c = pd.NS_Department__c;
                oli.NetSuite_Deferred_Revenue_Account__c = pd.NS_Deferred_Revenue_Account__c;
                oli.NetSuite_Income_GL_Account__c = pd.NS_Income_GL_Account__c;
                oli.NetSuite_Revenue_Schedule__c = pd.NS_Revenue_Schedule__c;
                oli.NetSuite_ID__c = pd.Netsuite_ID__c;
                oli.Tax_Class__c = pd.Tax_Class__c;
                oli.UnitPrice = pd.Price__c;

                //update checkbox that will ensure the "Restrict_Discount_And_SP_Membership_Prod"
                //validation rule doesn't cause an error
                oli.Bypass_Validation__c = true;

                String uniqueId = oli.OpportunityId+' '+oli.Projects__c;
                upsertOlis.put(uniqueId, oli);

                //if there IS a product change, clone the existing OLI, modify the clone,
                //insert the clone, then delete the existing OLI -- necessary because
                //SFDC doesn't allow changes to the Product2Id on an existing OLI
            }else{
                System.debug('product change');
                OpportunityLineItem clonedOLI = oli.clone(false, false, false, false);
                
                //updates from Product Detail
                clonedOLI.Product2Id = pd.Products__c;
                clonedOLI.Product_Details__c = pd.Id;
                clonedOLI.Start_Tier__c = pd.Start_Tier__c;
                clonedOLI.End_Tier__c = pd.End_Tier__c;
                clonedOLI.Tier__c = pd.Tier__c;
                clonedOLI.Number_of_Years_Required__c = Integer.valueOf(pd.Number_Of_Years_Required__c);
                clonedOLI.Renewal_Type__c = pd.Renewal_Type__c;
                clonedOLI.NetSuite_Class__c = pd.NetSuite_Class__c;
                clonedOLI.NetSuite_Department__c = pd.NS_Department__c;
                clonedOLI.NetSuite_Deferred_Revenue_Account__c = pd.NS_Deferred_Revenue_Account__c;
                clonedOLI.NetSuite_Income_GL_Account__c = pd.NS_Income_GL_Account__c;
                clonedOLI.NetSuite_Revenue_Schedule__c = pd.NS_Revenue_Schedule__c;
                clonedOLI.NetSuite_ID__c = pd.Netsuite_ID__c;
                clonedOLI.Tax_Class__c = pd.Tax_Class__c;
                clonedOLI.UnitPrice = pd.Price__c;

                //update checkbox that will ensure the "Restrict_Discount_And_SP_Membership_Prod"
                //validation rule doesn't cause an error
                clonedOLI.Bypass_Validation__c = true;

                System.debug('clonedOLI '+clonedOLI);
                String uniqueId = oli.OpportunityId+' '+oli.Projects__c;
                upsertOlis.put(uniqueId, clonedOLI);

                //get 15-digit and 18-digit String versions of oliID, needed for the next query
                String eighteenDigitID = (String)oli.Id;
                oliIDStrings.add(eighteenDigitID);
                String fifteenDigitID = eighteenDigitID.substring(0, 15);
                oliIDStrings.add(fifteenDigitID);

                
                //delete the original OLI
                deleteOlis.add(oli);
            }

            //get the Opportunity to see if its Type needs to be updated
            Opportunity opp = new Opportunity();

            //only need to proceed with checking if the Opp's Type needs to be updated if this is a renewal
            //or if the Opp's Type is blank (edge case)
            if(oli.Opportunity.Type == null ||
            ( oli.Opportunity.Type.indexOf('Renewal') != -1 && oli.Opportunity.Parent_Asset__r.Annual_Full_Price__c != null) ){
                
                //check to see if the full price of the new Product Detail selected is
                //greater than, less than, or equal to the full price of the Parent Asset,
                //and set Type of this Opp accordingly
                String newType = '';
                if(pd.Price__c > oli.Opportunity.Parent_Asset__r.Annual_Full_Price__c){
                    newType += 'Renewal - Upgrade';
                }else if(pd.Price__c < oli.Opportunity.Parent_Asset__r.Annual_Full_Price__c){
                    newType += 'Renewal - Downgrade';
                }else if(pd.Price__c == oli.Opportunity.Parent_Asset__r.Annual_Full_Price__c){
                    newType += 'Renewal';
                }

                //if newType doesn't match the Opp's current Type, update Opp
                if(newType != '' && newType != oli.Opportunity.Type){
                    opp.Id = oli.OpportunityId;
                    opp.Type = newType;
                    updateOpp.put(oli.OpportunityId, opp);
                }

            }
        }

        

        if(!upsertOlis.values().isEmpty()){
            upsert upsertOlis.values();
        }
        
        if(!updateOpp.values().isEmpty()){
            update updateOpp.values();
        }

        if(!oliIDStrings.isEmpty()){
            //query any Membership Roles attached to the existing OLI
            List<Project_Role__c> membershipRoles = new List<Project_Role__c>();
            membershipRoles = [SELECT Opportunity_Line_Item__c
                            FROM Project_Role__c
                            WHERE Opportunity_Line_Item__c IN :oliIDStrings
                            ];
            
            //update Membership Roles attached to the existing OLI to now be attached
            //to the cloned OLI
            if(membershipRoles.size() > 0){
                System.debug('membership roles found to be moved to new OLI');
                for(Project_Role__c mr : membershipRoles){
                    if(oliIdToOli.containsKey(mr.Opportunity_Line_Item__c)){
                        OpportunityLineItem oli = oliIdToOli.get(mr.Opportunity_Line_Item__c);
                        String uniqueId = oli.OpportunityId+' '+oli.Projects__c;
                        if(upsertOlis.containsKey(uniqueId)){
                            mr.Opportunity_Line_Item__c = upsertOlis.get(uniqueId).Id;
                        }
                    }
                }
                update membershipRoles;
            }
        }

        if(!deleteOlis.isEmpty()){
            delete deleteOlis;
        }

    }
}