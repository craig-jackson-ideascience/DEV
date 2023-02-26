public with sharing class AddCampaignMemberBatch implements Database.Batchable<String>,Database.Stateful {
    public final string fileString;    
    public ID jobID;    
    public Map<string,integer> fieldNumberMap = new  Map<string,integer>();
    blob emailcsv;
    string emailAdd;
    string errorFileName;
    string username;
    List<Errors__c> logs = new List<Errors__c>();
    
    public AddCampaignMemberBatch(string fileString, Map<string,integer> NumberMap, blob emailAttachment,String emailaddress, String fileName ,string strUsername){
        //pass overwrite value as well as
        this.fileString = fileString;
        fieldNumberMap = NumberMap;
        emailcsv = emailAttachment;
        emailAdd = emailaddress;
        errorFileName = fileName;
        userName = strUsername;
    }
    
    public Iterable<string> start(Database.BatchableContext bc){
        try{
            CSVIterator iterator = new CSVIterator(fileString,'\n'); 
            System.debug('iterator'+iterator);
            return iterator;
        }catch(Exception e){
            system.debug('Exception occured while processing row ' + e.getMessage());
            system.debug('Line Number'+e.getLineNumber());
            logs.add(new Errors__c(Error_Message__c = e.getMessage(),
                                   Line_Number__c = e.getLineNumber(),
                                   RAW_Error_Exception__c = string.valueOf(e)
                                  ));
            return null;
        }
        
    }
    
    public void execute(Database.BatchableContext bc,List<string> scope){
         jobID = [SELECT Id
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()].id;
        list < String > lines = new list < String > ();
        String csvbody = '';
        string newCsvbody = '';
        
        for(string doubleQuote: scope){
            System.debug('doubleQuote '+doubleQuote);
            if(doublequote.contains('"')){
                String rePattern = '("[^",]++),([^"]++")';  // first replace 
                String oldString = doublequote; 
                String resultString = doublequote.replaceAll(rePattern, '$1TQLD$2')+'\n';  // additional repalces until until no more changes 
                System.debug('resultString '+resultString);
                while (!resultString.equalsIgnoreCase(oldString)){  
                    oldString = resultString;  
                    resultString = resultString.replaceAll(rePattern, '$1TQLD$2');  
                }
                System.debug('oldString '+oldString);
                System.debug('resultString '+resultString);
                newCsvbody = newCsvbody + resultString;
            }else {
                newCsvbody = newCsvbody + doublequote +'\n';
            }
            System.debug('newCsvbody '+newCsvbody);
            
        }
        // Replace instances where a double quote begins a field containing a comma    
        // In this case you get a double quote followed by a doubled double quote    
        // Do this for beginning and end of a field
        System.debug('newCsvbody '+newCsvbody);
        csvbody = newCsvbody;
        csvbody = csvbody.replaceAll(',"""', ',"DBLQT').replaceall('""",', 'DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct    
        // fields with commas inside assuming they begin and end with a double quote 
        csvbody = csvbody.replaceAll('""', 'DBLQT');
        System.debug('csvbody '+csvbody);
        lines = csvbody.split('\n');
        system.debug('lines'+lines.size()+' '+lines);
        if(lines.size() > 0){
            parsingcsv(lines);
        }
    }
    
    
    public void finish(Database.BatchableContext bc){
        List<Campaign_Member_Record_Log__c> ErrorRecords = new List<Campaign_Member_Record_Log__c>();
        ErrorRecords =[Select ID From Campaign_Member_Record_Log__c Where Batch_Number__c=:jobID AND Status__c ='Error'];
        if(ErrorRecords.size()>0)
        {
        string emailbody = '' ;
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.saveAsActivity = false;
            System.debug('email Add=>' + emailAdd);
            List<String> senderList = Label.User_Email.split(';');
            senderList.add(emailAdd);
            mail.toAddresses = senderList;
            mail.setSenderDisplayName('Marketing Lead Error');
            mail.setSubject('Adding Campaign Memeber');
            emailbody = 'Hi '+userName +',<br/><br/> Error occured while adding Campaign Member. Please visit <a href="https://linuxfoundation.lightning.force.com/lightning/r/Report/00O2M0000099NMkUAM/view/?fv0=' +jobID+'">this link</a> for more information';
            System.debug('senderList=>' + senderList);
            mail.setHtmlBody(emailbody);
            mails.add(mail);
            Messaging.sendEmail(mails);
        }
        
        Error_Log__c err = new Error_Log__c();
        err.Status__c = 'Success';
        insert err;
        if(err.ID != null){
            Attachment att = new Attachment();
            att.Body  = emailcsv;
            att.ParentId = err.ID;
            att.Name = errorFileName; 
            insert att;
        }
        if(logs.size() > 0 && !logs.isEmpty()){
            err.status__c = 'Error';
            for(Errors__c elog : logs){
                elog.Error_Log__c = err.ID;
            }
            insert logs;
            Update err;
            
            /*string emailbody = '' ;
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.saveAsActivity = false;
            System.debug('email Add=>' + emailAdd);
            List<String> senderList = Label.User_Email.split(';');
            senderList.add(emailAdd);
            mail.toAddresses = senderList;
            mail.setSenderDisplayName('Marketing Lead Error');
            mail.setSubject('Adding Campaign Memeber');
            emailbody = 'Hi '+userName +',<br/><br/> Error occured while adding Campaign Member. Please visit <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + err.ID +'">this link</a> for more information';
            System.debug('senderList=>' + senderList);
            mail.setHtmlBody(emailbody);
            mails.add(mail);
            Messaging.sendEmail(mails);*/
            
        }
    }
    
    private void parsingcsv(list<String> Lines){
        try{
            System.debug('Lines '+Lines);
            List<Campaign_Member_Record_Log__c> records = new List<Campaign_Member_Record_Log__c>();
            for(String line: lines){
                if(line.replaceAll(',', '').trim().length() == 0) break;
                List<String> fields = new List<String>();
                fields = line.split(',', -1);
                fields = cleanFields(fields);
                records.add(getCampaignMemberLogs(fields));
            }
            if(!records.isEmpty()){
                Database.SaveResult[] srList = Database.insert(records, false);
                integer i=1;
                for(Database.SaveResult sr : srList){
                    if(!sr.isSuccess() && sr.getErrors() != null){
                        for( Database.Error err :  sr.getErrors()){                        
                            logs.add(new Errors__c(
                                Error_Message__c = string.valueOf(err.getMessage()),
                                Status_Code__c = string.valueOf(err.getStatusCode()),
                                Row_Number__c = i
                            )
                                    );     
                        }
                    }
                    i++;
                    
                }
            }
            
            
        }catch(Exception e){
            logs.add(new Errors__c(Error_Message__c = e.getMessage(),
                                   Line_Number__c = e.getLineNumber(),
                                   RAW_Error_Exception__c = string.valueOf(e)
                                  ));
        }
    }
    private List<String> cleanFields(List<String> fields){
        List<String> cleanFields = new List<String>();
        String compositeField;
        Boolean makeCompositeField = false;
        for(String field : fields) {
            field = field.removeStart('"').removeEnd('"');
            field = field.replaceAll('DBLQT','"').trim();
            system.debug('field '+field);
            cleanFields.add(field);
        }
        return cleanFields;
    }
    
    private Campaign_Member_Record_Log__c getCampaignMemberLogs(List<String> fields){
        
        Campaign_Member_Record_Log__c campaignMemberLog = new Campaign_Member_Record_Log__c();
        campaignMemberLog.First_Name__c = fieldNumberMap.containsKey('First Name') && string.isnotEmpty(fields[fieldNumberMap.get('First Name')]) ? fields[fieldNumberMap.get('First Name')] : '';
        campaignMemberLog.Last_Name__c =  string.isnotEmpty(fields[fieldNumberMap.get('Last Name')])? fields[fieldNumberMap.get('Last Name')] : '[[Unknown]]';
        campaignMemberLog.Email_Address__c = string.isnotEmpty(fields[fieldNumberMap.get('Email Address')]) ? fields[fieldNumberMap.get('Email Address')].tolowercase() : '';
        campaignMemberLog.Company__c = string.isnotEmpty(fields[fieldNumberMap.get('Company')]) ? fields[fieldNumberMap.get('Company')].replaceAll('"','').replaceAll('TQLD',',') : '';
        campaignMemberLog.Job_Title__c = fieldNumberMap.containsKey('Job Title') && string.isnotEmpty(fields[fieldNumberMap.get('Job Title')]) ? fields[fieldNumberMap.get('Job Title')].replaceAll('"','').replaceAll('TQLD',',') : '';
        campaignMemberLog.Street__c = fieldNumberMap.containsKey('Street') && string.isnotEmpty(fields[fieldNumberMap.get('Street')]) ? fields[fieldNumberMap.get('Street')].replaceAll('"','').replaceAll('TQLD',',') : '';
        campaignMemberLog.City__c =   fieldNumberMap.containskey('City') && string.isnotEmpty(fields[fieldNumberMap.get('City')]) ? fields[fieldNumberMap.get('City')] : '';
        campaignMemberLog.State__c =  fieldNumberMap.containskey('State') && string.isnotEmpty(fields[fieldNumberMap.get('State')]) ? fields[fieldNumberMap.get('State')] : '';
        campaignMemberLog.Zip__c = fieldNumberMap.containskey('Zip') && string.isnotEmpty(fields[fieldNumberMap.get('Zip')]) ? fields[fieldNumberMap.get('Zip')] : '';
        campaignMemberLog.Country__c = fieldNumberMap.containskey('Country') && string.isnotEmpty(fields[fieldNumberMap.get('Country')]) ? fields[fieldNumberMap.get('Country')] : '';
        campaignMemberLog.Linkedin_Id__c = fieldNumberMap.containskey('Linkedin Id') && string.isnotEmpty(fields[fieldNumberMap.get('Linkedin Id')]) ? fields[fieldNumberMap.get('Linkedin Id')] : '';
        campaignMemberLog.Github_Id__c = fieldNumberMap.containskey('Github Id') && string.isnotEmpty(fields[fieldNumberMap.get('Github Id')]) ? fields[fieldNumberMap.get('Github Id')] : '';
        campaignMemberLog.Phone__c =  fieldNumberMap.containskey('Phone') && string.isnotEmpty(fields[fieldNumberMap.get('Phone')]) ? fields[fieldNumberMap.get('Phone')] : '';
        campaignMemberLog.Industry__c = fieldNumberMap.containskey('Industry') && string.isnotEmpty(fields[fieldNumberMap.get('Industry')]) ? fields[fieldNumberMap.get('Industry')].replaceAll('"','').replaceAll('TQLD',',') : '';
        campaignMemberLog.Lead_Source__c  = fieldNumberMap.containskey('Lead Source') && string.isnotEmpty(fields[fieldNumberMap.get('Lead Source')]) ? fields[fieldNumberMap.get('Lead Source')] : '';
        campaignMemberLog.Lead_Source_Detail__c =  fieldNumberMap.containskey('Lead Source Detail') && string.isnotEmpty(fields[fieldNumberMap.get('Lead Source Detail')]) ? fields[fieldNumberMap.get('Lead Source Detail')] : '';
        campaignMemberLog.notes__c =  fieldNumberMap.containskey('Notes') && string.isnotEmpty(fields[fieldNumberMap.get('Notes')]) ? fields[fieldNumberMap.get('Notes')].replaceAll('"','').replaceAll('TQLD',',') : '';
        campaignMemberLog.newsletter__c =  fieldNumberMap.containskey('Newsletter') && string.isnotEmpty(fields[fieldNumberMap.get('Newsletter')]) ? fields[fieldNumberMap.get('Newsletter')].replaceAll('"','').replaceAll('TQLD',',') : '';
        campaignMemberLog.membership__c =  fieldNumberMap.containskey('Membership') && string.isnotEmpty(fields[fieldNumberMap.get('Membership')]) ? fields[fieldNumberMap.get('Membership')].replaceAll('"','').replaceAll('TQLD',',') : '';
        campaignMemberLog.Campaign_Name__c =  fieldNumberMap.containskey('Campaign Name') && string.isnotEmpty(fields[fieldNumberMap.get('Campaign Name')]) ? fields[fieldNumberMap.get('Campaign Name')].replaceAll('TQLD',',') : '';
        campaignMemberLog.Batch_Number__c = jobID;
        return campaignMemberLog;
    }
}