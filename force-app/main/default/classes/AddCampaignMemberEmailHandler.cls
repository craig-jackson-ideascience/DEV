global class AddCampaignMemberEmailHandler implements Messaging.InboundEmailHandler {
    Map < String ,Integer> headersMap = new Map < String ,Integer>();
    //integer abc = 1/0;
    Set<String> emailset =  new Set<String>();
    List<CampaignMember> cm = new List<CampaignMember>(); 
    Map<String,Id> campNameVsId = new  Map<String,Id>();
    public Map<string,integer> fieldNumberMap  = new Map<string,integer> ();
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        system.debug('Inbound Email class invoked'); //Added
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        Messaging.InboundEmail.BinaryAttachment[] tAttachments = email.binaryAttachments;
        String csvAsString = '';
        string strUserName = email.plainTextBody.substringBefore('\n');
        List<User> lstUser = new List<User>();
        string strEmail='';
        string UserName ='';
        lstUser= [SELECT Id,Email,name
                            FROM User 
                            WHERE Name = : strUserName 
                            LIMIT 1];
        system.debug('Name'+lstUser);
        if(lstUser.size()>0){
           strEmail = lstUser[0].Email; 
           UserName = lstUser[0].name;
         }
        if(string.IsBlank(strEmail)){
            strEmail = email.fromAddress;
        }
        for(Messaging.InboundEmail.BinaryAttachment btt: tAttachments){
            if (btt.filename.endsWithIgnoreCase('.csv')) {
                //system.debug('before ' +btt.body.toString() );
               // csvAsString =btt.body.toString() ;
                csvAsString =blobToString(btt.body,'UTF-8');//btt.body.toString();
                System.debug('csvAsString' +csvAsString);
                String row = csvAsString.subString(0, csvAsString.indexOf('\n'));
                csvAsString = csvAsString.subString(csvAsString.indexOf('\n') + '\n'.length(),csvAsString.length());
                System.debug('row :' +row);
                getHeader(row);   
                System.debug('fieldNumberMap>>>>>>' +fieldNumberMap);
                  AddCampaignMemberBatch addcamp= new AddCampaignMemberBatch(csvAsString,fieldNumberMap,tAttachments[0].body,strEmail,btt.fileName,UserName); //Updated by pratik With User Mail id
				Database.executeBatch(addcamp,50); 
            }
        }
        return result;
    }
    
    private void getHeader(string row){
        string[] csvFieldNames = row.split(',');
        System.debug('csvFieldNames' +csvFieldNames);
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            csvFieldNames[i] = csvFieldNames[i].remove('"');
            fieldNumberMap.put(csvFieldNames[i].trim(), i);
            System.debug('fieldNumberMap' +fieldNumberMap);
        }
    }
    
    public static String blobToString(Blob input, String charset){
        final String hex = EncodingUtil.convertToHex(input);
        final Integer size = hex.length() >> 1;
        final List<String> bytes = new String[size];
        
        for (Integer i = 0; i < size; ++i) {
            bytes.set(i, hex.mid(i << 1, 2));
        }
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), charset);
    }
}