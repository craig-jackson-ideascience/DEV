@RestResource(urlMapping='/GetEvents/*')
global class GetEventsDropdown {

    /**
     * POST request with body containing 'eventId' with EventId or a Query for Event with Fields Id and Name.
     * if event is present then return Input Field not Editable.
     * if event is is not present or is blank then a dropdown is sent.
     *
     * @return DOM as String
     */
    @HttpPost
    global static String getDOMString() {

        String responseBody = '';

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Blob requestBodyBlob = req.requestBody;
        String requestBody = requestBodyBlob.toString();
        System.debug('Request Body: ' + requestBody);

        Map<String, Object> queryMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        System.debug('queryMap: ' + queryMap);
        if (queryMap.containsKey('eventId') && queryMap.get('eventId') != null && String.isNotBlank(queryMap.get('eventId').toString())) {
            String eventId = (String) queryMap.get('eventId');
            System.debug(eventId + '====> eventId');

            List<Event__c> events = [SELECT Id, Name FROM Event__c WHERE Id = :eventId];
            if (events.size() > 0) {
                System.debug(events[0].Name + '====> events[0].Name');
                responseBody = '<input type="text" name="event" id="event" disabled=true value=\'' + events[0].Name + '\'>' ;
            }
        } else {
            String queryString = (String) queryMap.get('query');
            System.debug('queryString: ' + queryString);
            List<Event__c> events = Database.query(queryString);

            if (events.size() > 0) {
                responseBody = '<select name="event" id="event">';
                for (Event__c evt : events) {
                    responseBody = responseBody + '<option value="' + evt.Id + '">' + evt.Name + '</option>';
                }
            }
            responseBody += '</select>';
        }


        System.debug('responseBody: ' + responseBody);

        return responseBody;
    }

}