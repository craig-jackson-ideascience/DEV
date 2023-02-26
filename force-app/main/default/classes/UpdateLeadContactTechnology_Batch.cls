global class UpdateLeadContactTechnology_Batch implements Database.Batchable<sObject>{
    
    private String strParameter;

    public UpdateLeadContactTechnology_Batch(String strParam) {
        strParameter = strParam;
    }

    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        system.debug('>>>>> START >>>' );
        
        String strCondition = ( strParameter == 'Contact' ? ' AND Contact_Name__c != null ' : ' AND Lead_Name__c != null ' );
        String strOrderBy = ( strParameter == 'Contact' ? ' ORDER BY Contact_Name__r.lastmodifiedDate ASC ' : ' ORDER BY Lead_Name__r.lastmodifiedDate ASC ' );
        
        string strQuery = 'SELECT Id, Contact_Name__r.lastmodifiedDate, Product_Technology__c, Contact_Technology__c, Lead_Technology__c, '
            +' Contact_Name__c, Lead_Name__c, Contact_Name__r.Technology__c, Lead_Name__r.Technology__c '
            + ' From Enrollment__c '
            + ' WHERE CreatedDate > 2020-04-20T00:00:00.000Z '
            + strCondition
            + ' AND Product_Name__c != null  '
            + ' AND Product_Technology__c != null '
            //+ ' AND Contact_Name__r.lastmodifieddate != TODAY  '
            //+ ' AND Contact_Name__r.lastmodifiedBYID != \'0052M00000934En\''
             + strOrderBy;
        
        system.debug('>>>>> strQuery >>>' + strQuery);
        
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext bc, List<Enrollment__c> lstEnroll){
        
        system.debug('>>>>> lstEnroll >>>' + lstEnroll);
        
        Map < Id, Contact > mapCon = new Map < Id, Contact > ();
        Map < Id, Lead > mapLead = new Map < Id, Lead > ();

        for (Enrollment__c en: lstEnroll) {
            
            if(en.Contact_Name__c != null){
            
                system.debug('date------'+en.Contact_Name__r.lastmodifieddate);
            
                if(en.Product_Technology__c != en.Contact_Technology__c) {
                    
                    system.debug(' Prod tech ' + en.Product_Technology__c);
                    system.debug(' Lead tech ' + en.Id + '-- ' + en.Lead_Technology__c);
                    
                    List <string> lstStr = (String.valueOf(en.Product_Technology__c)).Split(';');
            
                    system.debug('list of tech' + lstStr);
            
                    for (String strTech: lstStr) {
            
                         system.debug('strTech ' + strTech);
            
                        if (en.Contact_Technology__c == null || !en.Contact_Technology__c.contains(strTech)) {
            
                            if (mapCon.containsKey(en.Contact_Name__c)) {
                               
                                String tech = mapCon.get(en.Contact_Name__c).Technology__c  + ';' + strTech;
                                system.debug('en.Contact_Name__c---'+en.Contact_Name__c + '---' + tech);
                               
                                mapCon.put(en.Contact_Name__c, new contact(Id = en.Contact_Name__c,
                                    Technology__c = tech
                                    ));
                            } else {
                                String tech = (en.Contact_Name__r.Technology__c != null
                                                                ? en.Contact_Name__r.Technology__c  + ';' + strTech
                                                                : strTech );
                                
                                mapCon.put(en.Contact_Name__c,
                                            new contact(Id = en.Contact_Name__c,                        
                                                        Technology__c = tech
                                                      ));
                            }
                        }
                    }
                }
            }
            if(en.Lead_Name__c != null){
                
                if(en.Product_Technology__c != en.Lead_Technology__c) {
                    
                    system.debug(' Prod tech ' + en.Product_Technology__c);
                    system.debug(' Lead tech ' + en.Id + '-- ' + en.Lead_Technology__c);
                    
                    List <string> lstStr = (String.valueOf(en.Product_Technology__c)).Split(';');
            
                    system.debug('list of tech' + lstStr);
            
                    for (String strTech: lstStr) {
            
                         system.debug('strTech ' + strTech);
            
                        if (en.Lead_Technology__c == null || !en.Lead_Technology__c.contains(strTech)) {
            
                            if (mapLead.containsKey(en.Lead_Name__c)) {
                               
                                String tech = mapLead.get(en.Lead_Name__c).Technology__c  + ';' + strTech;
                                system.debug('en.Lead_Name__c---'+en.Lead_Name__c + '---' + tech);
                               
                                mapLead.put(en.Lead_Name__c, new Lead(Id = en.Lead_Name__c,
                                                                        Technology__c = tech
                                                                        ));
                            } else {
                                String tech = (en.Lead_Name__r.Technology__c != null
                                                                ? en.Lead_Name__r.Technology__c  + ';' + strTech
                                                                : strTech );
                                
                                mapLead.put(en.Lead_Name__c,
                                            new Lead(Id = en.Lead_Name__c,                        
                                                        Technology__c = tech
                                                      ));
                            }
                        }
                    }
                }
            }
        }
            
        system.debug('Updated records >>> ' + mapCon.values().size());
        update mapCon.values();
        system.debug('Updated records >>> ' + mapLead.values().size());
        update mapLead.values();
    }    
    global void finish(Database.BatchableContext bc){
        
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        //EmailUtils.sendMessage(job, recordsProcessed);
    }    
}