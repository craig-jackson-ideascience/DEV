global class CaseBatchApex implements Database.Batchable<sObject>, Database.AllowsCallouts{
     
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'SELECT Status,Jira_Key__c,Jira_Assignee__c,Component__c From Case WHERE Jira_Key__c != null AND (status != \'Resolved\' AND status != \'Closed\') ';
        return Database.getQueryLocator(soqlQuery);
    }
     
    global void execute(Database.BatchableContext bc, List<Case> scope){
        
        Map<String,JIRA_Authentication__c> mapJiraAuth = JIRA_Authentication__c.getAll();
        List<JIRA_Authentication__c> lstJiraAuth =mapJiraAuth.values();
        List<String> sList = new List<String>();
        
        List<case> lstCase = new List<case>();
        Map<string,case> mapCaseKey_CaseId = new Map<string,case>();
        Map<string,string> mapJiraKeyCompnemt = new Map<string,string>();

        for (Case objCase : scope){
        	mapCaseKey_CaseId.put(objCase.JIRA_Key__c, objCase);
            sList.add(objCase.JIRA_Key__c);
        }
        
        string allstring = 'key='+string.join(sList,'||key=');
        //system.debug('allstring--->'+allstring);
                try{
                    
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                    
                    String username =lstJiraAuth[0].Username__c;
                    String password = lstJiraAuth[0].Password__c;
                    Blob headerValue = Blob.valueOf(username + ':' + password);
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    string endPO = 'https://jira.linuxfoundation.org/rest/api/2/search?jql='+allstring+'&fieldsByKeys=true'
                        //+'&created<"2020/25/10"'			
                        +'&fields=status&fields=assignee&fields=components&maxResults=100';
                    //system.debug('endPO--->'+endPO);
                    request.setHeader('Authorization', authorizationHeader);
                    request.setHeader('Content-Type', 'application/json');
                    request.setEndpoint(endPO);
                    
                    //system.debug('endPO-->'+endPO);
                    request.setMethod('GET');
                    //request.setBody('Information to Send');
                    response = http.send(request);
                    
                    //system.debug('response.getBody()-->'+response.getBody());                    
                    //system.debug('response-->'+response);
                    if (response.getStatusCode() == 200) {
                        JIRAResponseWrapper responseWrapped = JIRAResponseWrapper.parse(response.getBody());
                        for(JIRAResponseWrapper.Issues issue : responseWrapped.Issues){
                            
                            List<String> comList = new List<String>();
                            if(issue.Fields.components != null){
                                for(JIRAResponseWrapper.Components obj :issue.Fields.components){
                                    comList.add(obj.name);
                                }
                                mapJiraKeyCompnemt.put(issue.key,string.join(comList,','));  
                            }
                            Case objCase = mapCaseKey_CaseId.get(issue.key);
                            Case caseDetail = new Case();
                            caseDetail.Id=objCase.ID;
                            if(mapJiraKeyCompnemt!=null){
                                
                                if( objCase.Component__c != mapJiraKeyCompnemt.get(issue.key)){
                                	caseDetail.Component__c  = mapJiraKeyCompnemt.get(issue.key);
                            	}
                                
                            }
                            
                            if(objCase.Status != issue.Fields.Status.Name){
                              caseDetail.Status = issue.Fields.Status.Name;       
                            }
                            if(issue.Fields.assignee != null){
                                if(objCase.Jira_Assignee__c != issue.Fields.assignee.name)
                                    caseDetail.Jira_Assignee__c =issue.Fields.assignee.name;
                            } 
                            lstCase.add(caseDetail);
                        }
                        if(lstCase.size()>0){
                        update lstCase;
                        }
                    }
                }
        catch(Exception e){
            //system.debug('Exception');
            String message = e.getMessage();
            String stacktrace = e.getStackTraceString();
            String exType = '' + e.getTypeName();
            String line = '' + e.getLineNumber();
            String theTime = '' + System.now();
            
            String body = String.format('Time: {0}\nMessage: {1}\nStacktrace: {2}\nLine: {3}', new List<String>{ theTime, message, stacktrace, line });
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors occurred during update jira status and assignee Case batch process.');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.Email[] { mail });   
        }
    }
    global void finish(Database.BatchableContext bc){
         
    }
}