@isTest
public class JIRAResponseWrapperTest {

    static testMethod void testParse() {
		String json = '{'+
		'	\"expand\": \"renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations\",'+
		'	\"id\": \"97833\",'+
		'	\"self\": \"https://jira.linuxfoundation.org/rest/api/2/issue/97833\",'+
		'	\"key\": \"ST-68\",'+
		'	\"fields\": {        \"status\": {'+
		'            \"self\": \"https://jira.linuxfoundation.org/rest/api/2/status/11015\",'+
		'            \"description\": \"This was auto-generated by Jira Service Desk during workflow import\",'+
		'            \"iconUrl\": \"https://jira.linuxfoundation.org/images/icons/status_generic.gif\",'+
		'            \"name\": \"Waiting for support\",'+
		'            \"id\": \"11015\",'+
		'            \"statusCategory\": {'+
		'                \"self\": \"https://jira.linuxfoundation.org/rest/api/2/statuscategory/2\",'+
		'                \"id\": 2,'+
		'                \"key\": \"new\",'+
		'                \"colorName\": \"blue-gray\",'+
		'                \"name\": \"To Do\"'+
		'            }'+
		'        },'+
		'       \"assignee\": {'+
		'            \"self\": \"https://jira.linuxfoundation.org/rest/api/2/user?username=harshadk\",'+
		'            \"name\": \"harshadk\",'+
		'            \"key\": \"JIRAUSER17555\",'+
		'            \"avatarUrls\": {'+
		'                \"fortyEight\": \"https://jira.linuxfoundation.org/secure/useravatar?avatarId=11925\",'+
		'                \"twentyFour\": \"https://jira.linuxfoundation.org/secure/useravatar?size=small&avatarId=11925\",'+
		'                \"sixteen\": \"https://jira.linuxfoundation.org/secure/useravatar?size=xsmall&avatarId=11925\",'+
		'                \"thirtyTwo\": \"https://jira.linuxfoundation.org/secure/useravatar?size=medium&avatarId=11925\"'+
		'            },'+
		'            \"displayName\": \"Harshad Kuhite\",'+
		'            \"active\": true,'+
		'            \"timeZone\": \"America/Los_Angeles\"'+
		'        }'+
		'}'+
		'}';
		JIRAResponseWrapper obj = JIRAResponseWrapper.parse(json);
        JIRAResponseWrapper.AvatarUrls objAvat = new JIRAResponseWrapper.AvatarUrls();
        objAvat.fortyEight ='fortyEight';
        objAvat.sixteen ='sixteen';
        objAvat.thirtyTwo ='fortyEight';
        objAvat.twentyFour ='fortyEight';
        JIRAResponseWrapper.Assignee objass= new JIRAResponseWrapper.Assignee();
        objass.active= true;
        objass.displayName='Test';
        objass.key= 'ST-52';
        objass.name ='Test';
        objass.self ='T';
        objass.timeZone='India';
        //objass.avatarUrls =;
		System.assert(obj != null);
	}
}