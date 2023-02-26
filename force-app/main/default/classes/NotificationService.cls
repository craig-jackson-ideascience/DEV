global class NotificationService {
    
    private static String kHexChars = '0123456789abcdef';
    
    @future (callout=true)
    public static void getAccessToken(Id purchaseHistoryId) {
        
        system.debug('purchaseHistoryId :::: ' + purchaseHistoryId);
        system.debug('ARN :::: ' + System.Label.AWS_SNS_ARN + ',  ' + System.Label.Dev_AWS_SNS_ARN);
        system.debug('audience :::: ' + System.Label.AWS_SNS_audience + ',  ' + System.Label.Dev_AWS_SNS_audience);
        system.debug('client_id :::: ' + System.Label.AWS_SNS_client_id + ',  ' + System.Label.Dev_AWS_SNS_client_id);
        system.debug('client_secret :::: ' + System.Label.AWS_SNS_client_secret + ',  ' + System.Label.Dev_AWS_SNS_client_secret);
        system.debug('ouath_token_endpoint :::: ' + System.Label.AWS_SNS_ouath_token_endpoint + ',  ' + System.Label.Dev_AWS_SNS_ouath_token_endpoint);
        system.debug('notifications_endpoint :::: ' + System.Label.AWS_SNS_notifications_endpoint + ',  ' + System.Label.Dev_AWS_SNS_notifications_endpoint);
        
        try {
            list<Project_Role__c> projectRoleList = [SELECT Id, Contact__r.Name, Asset__c, Notification_Status__c, Asset__r.Projects__c, Send_to_Groups_io__c, ProjectName__c, ContactEmail__c, toLabel(Role__c)
                                                     FROM Project_Role__c 
                                                     WHERE Asset__c =: purchaseHistoryId];
            
            system.debug('projectRoleList :::: ' + projectRoleList);
            
            //if(projectRoleRecord.Notification_Status__c == false) {
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(System.Label.AWS_SNS_ouath_token_endpoint);    
            //request.setEndpoint(System.Label.Dev_AWS_SNS_ouath_token_endpoint); 
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('cache-control', 'no-cache');
            request.setBody('{"audience":"' + System.Label.AWS_SNS_audience + '","grant_type": "client_credentials","client_id": "' + System.Label.AWS_SNS_client_id + '","client_secret": "' + System.Label.AWS_SNS_client_secret + '"}');
            //request.setBody('{"audience":"' + System.Label.Dev_AWS_SNS_audience + '","grant_type": "client_credentials","client_id": "' + System.Label.Dev_AWS_SNS_client_id + '","client_secret": "' + System.Label.Dev_AWS_SNS_client_secret + '"}');
            
            Http http = new Http();
            HTTPResponse response = http.send(request);
            
            system.debug('response::: '+response);
            System.debug('response.getBody:::: ' + response.getBody());
            System.debug('response.getStatus:::: ' + response.getStatus());
            System.debug('response.getStatusCode:::: ' + response.getStatusCode());
            
            JSONParser parser = JSON.createParser(response.getBody());
            parser.nextToken();
            parser.nextValue();
            String fieldName = parser.getCurrentName();
            String fieldValue = parser.getText();
            System.debug('fieldName:::: ' + fieldName);
            System.debug('fieldValue:::: ' + fieldValue);
            
            String access_token = fieldValue;
            system.debug('access_token::: ' + access_token);
            
            if(access_token != null) {
                String result = sendNotificationRequest(access_token, projectRoleList);
            }
            // }    
        } catch (Exception e) {
            system.debug('!!ERROR:::: ' + e.getLineNumber() + ' !!LINE NUMBER:::: ' + e.getMessage());
        }
    }
    
    public static String sendNotificationRequest(String access_token, list<Project_Role__c> projectRoleList) {
        
        system.debug('\n access_token:::: ' + access_token);
        system.debug('projectRoleList :::: ' + projectRoleList);
        
         try {
            
            String UUID = newUUID();
            system.debug('UUID :::: ' + UUID);
            
            String reqbody;
            String requestBody;
            
            map<String, List<string>> emailWithProjectRoleMap = new map<String, list<string>>();
            map<String, boolean> emailWithRoleMap = new map<String, boolean>();
            
            for(Project_Role__c prjctRL: projectRoleList) {
                String contactEmailKey = prjctRL.ContactEmail__c;
                if(emailWithProjectRoleMap.get(contactEmailKey) == null) {
                    system.debug('if => ' + contactEmailKey + '-----' + prjctRL);
                    List<string> roles = new List<string>();
                    roles.add(prjctRL.Role__c);//Representative/Voting Contact
                    emailWithProjectRoleMap.put(contactEmailKey, roles);
                } else {
                    system.debug('else => ' + contactEmailKey + '-----' + prjctRL);
                    List<string> roles = emailWithProjectRoleMap.get(contactEmailKey); 
                    roles.add(prjctRL.Role__c);
                    emailWithProjectRoleMap.put(contactEmailKey, roles);
                }
            }
            System.debug('11=' + emailWithProjectRoleMap);
            system.debug('emailWithProjectRoleMap.size :::  ' + emailWithProjectRoleMap.size() + ' emailWithProjectRoleMap ::: ' + emailWithProjectRoleMap);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(System.Label.AWS_SNS_notifications_endpoint);
            //request.setEndpoint(System.Label.Dev_AWS_SNS_notifications_endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer '+access_token);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('cache-control', 'no-cache');
            
            JSONGenerator jsGen = JSON.createGenerator(true);
            JSONGenerator jsonGen = JSON.createGenerator(true);
            
            jsGen.writeStartArray();
            for(Project_Role__c prjctRL: projectRoleList) {
                if(prjctRL.Send_to_Groups_io__c) {
                    if(emailWithRoleMap.get(prjctRL.ContactEmail__c) == null) {
                        jsGen.writeStartObject();
                        // system.debug();
                        jsGen.writeStringField('projectId', prjctRL.Asset__r.Projects__c);
                        jsGen.writeStringField('projectName', prjctRL.ProjectName__c);
                        jsGen.writeStringField('email', prjctRL.ContactEmail__c);
                        jsGen.writeFieldName('ProjectRoles');
                        jsGen.writeStartArray();
                        for(string role :emailWithProjectRoleMap.get(prjctRL.ContactEmail__c)) {
                           // string prRole = role.replace(' Contact','');
                            //system.debug('prRole :: ' + prRole);
                            jsGen.writeString(role);  
                        }
                        jsGen.writeEndArray();
                        jsGen.writeEndObject();
                        emailWithRoleMap.put(prjctRL.ContactEmail__c,true) ;
                    }
                }
            }
            jsGen.writeEndArray();
            
            reqbody = jsGen.getAsString();
            system.debug('reqbody :::: ' + reqbody);
            jsonGen.writeStartObject();
            jsonGen.writeStringField('ARN', System.Label.AWS_SNS_ARN);
            //jsonGen.writeStringField('ARN', System.Label.Dev_AWS_SNS_ARN);
            jsonGen.writeStringField('Data', reqbody);
            jsonGen.writeStringField('Id', UUID);
            jsonGen.writeFieldName('Source');
            jsonGen.writeStartObject();
            jsonGen.writeStringField('ClientID', System.Label.AWS_SNS_client_id);
            //jsonGen.writeStringField('ClientID', System.Label.Dev_AWS_SNS_client_id);
            jsonGen.writeStringField('Name', 'sfdc-groups-io-integrations');
            jsonGen.writeEndObject();
            jsonGen.writeEndObject();
            requestBody = jsonGen.getAsString();
            system.debug('requestBody :::: ' + requestBody);
            
            request.setBody(requestBody);
            //request.setBody('{"Arn": "arn:aws:sns:us-east-2:395594542180:collaboration-triggers-dev-collaboration-sns-topic", "Data":"{\"projectId\":\"a0941000002wBygAAE\",\"projectName\":prjctList.ProjectName__c,\"email\":\"krishnab@proximabiz.com\",\"ProjectRoles\":{\"PR\":\"\",\"Billing\":\"\"}}", "Id": "65044bf3-f864-418a-a463-874f90bff992", "Source": {"ClientID": "a092h000000UReOAAW", "Name": "SFDC-Integration"} }');
            
            Http http = new Http();
            HTTPResponse response = http.send(request);
            
            system.debug('response:::: ' + response);
            System.debug('response.getBody:::: ' + response.getBody());
            System.debug('response.getStatus:::: ' + response.getStatus());
            System.debug('response.getStatusCode:::: ' + response.getStatusCode());
            
            //IF status code not equals 200 or 201 send emails all admins.
            
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                
                system.debug('Ok!! Code is running successfully. Status Code is: ' + response.getStatusCode());  
                //projectRoleRecord.Notification_Status__c = true;
                //System.debug('projectRoleRecord.Notification_Status__c ' + projectRoleRecord);
                //update projectRoleRecord;
                
            } else {
                
                Profile p = [SELECT Id, Name FROM Profile WHERE name = 'System Administrator'];
                system.debug('Profile:::: ' + p);
                
                list<User> userList = [SELECT Id, Name, Email FROM User WHERE ProfileId =: p.Id];
                system.debug('userList Count:::: ' + userList.size() + ', userList:::: ' + userList);
                
                list<String> sendTo = new list<String>();
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();

                for(User u: userList) {
                    if(u.Email != null) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        sendTo.add(u.Email);
                        mail.setToAddresses(sendTo);
                        mail.setOrgWideEmailAddressId(orgWideEmailAddress);
                        mail.setSubject('Notification Service Error!!');
                        String body = 'Hi ' + u.Name + ', <br /><br />';
                        body += '<b>Here is the response of the request: </b><br />';
                        body += response.getBody() + '<br /><br />';
                        body += '<b>Here is the request data which is sent: </b><br />';
                        body += requestBody + '<br /><br />';
                        body += 'Regards-<br />';
                        //body += usr.Name;
                        system.debug('body :: ' + body);
                        mail.setHtmlBody(body);
                        mails.add(mail);
                    }
                }
                
                Messaging.sendEmail(mails);
            }            
         } catch (Exception e) {
            system.debug('!!ERROR:::: ' + e.getLineNumber() + ' !!LINE NUMBER:::: ' + e.getMessage());
         }
        return null;
    }
    
    global static String newUUID() {
        
        String returnValue = '';
        Integer nextByte = 0;
        
        for (Integer i=0; i<16; i++) {
            if (i==4 || i==6 || i==8 || i==10)  {
                returnValue += '-';
            }
            nextByte = (Math.round(Math.random() * 255)-128) & 255;
            
            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            
            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }
            
            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }
        
        return returnValue;
    }
    
    global static String getCharAtIndex(String str, Integer index) {
        
        if (str == null) {
            return null;
        }
        if (str.length() <= 0) {
            return str;  
        }  
        if (index == str.length()) {
            return null;    
        }
        return str.substring(index, index+1);
    }
}