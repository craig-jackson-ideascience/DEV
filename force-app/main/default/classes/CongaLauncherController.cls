public class CongaLauncherController {
    @AuraEnabled 
    public static Map<String,String> getSessionIdAndServerUrl()
    {
        Map<String,String> responseMap = new Map<String,String>();
        String content;
        if(Test.isRunningTest()){
            content = '{"sessionId": "12345","serverUrl":"test.com"}';
        }else{
            content = Page.GetSessionIdAndServerUrl.getContent().toString();
        }
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(content);
        System.debug('session id :'+(String)m.get('sessionId'));
        responseMap.put('sessionId', (String)m.get('sessionId'));
        System.debug('serverUrl :'+(String)m.get('serverUrl'));
        responseMap.put('serverUrl', (String)m.get('serverUrl'));
        System.debug('responseMap :'+responseMap);
        return responseMap;
    }
}