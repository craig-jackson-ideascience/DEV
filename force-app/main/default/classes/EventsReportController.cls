public class EventsReportController {

    //Static Variables
    public static final String LABEL = 'label';
    public static final String VALUE = 'value';
    private static Pattern eventPattern =Pattern.compile('\\d+');

    //This method returns all the Events present in the System.
    @AuraEnabled
    public static List<Map<String, String>> getAllEvents() {
        //Debug
        System.debug('IN getAllEvents');

        //Initialize Variable
        List<Map<String, String>> eventNames = new List<Map<String, String>>();

        //Add None first.
        eventNames.add(new Map<String, String>{
                LABEL => '--None--', VALUE => ''
        });

        //Loop on all events to create eventNames List.
        for (Event__c event : [SELECT Id,Name,Event_Registrations__c FROM Event__c ORDER BY Name]) {
            if(event.Event_Registrations__c > 0){
                eventNames.add(new Map<String, String>{
                        LABEL => event.Name, VALUE => event.Id
                });
            }
        }

        //Debug
        System.debug('eventNames :' + eventNames);

        //retun the created list
        return eventNames;
    }

    //This Method returns data that needs to be displayed on the Event Report.
    @AuraEnabled
    public static Map<String, Object> getRegistrationDetails(String eventId) {
        //Debug
        System.debug('eventId :' + eventId);
        
        //Initialize Variable
        Map<String, Object> mapOfData = new Map<String, Object>();
        Set<Id> contactIds = new Set<Id>();
        TotalWrapper totalWrap = new TotalWrapper();
        List<EventRegistrationWrapper> eventRegistrationWrapper = new List<EventRegistrationWrapper>();
        Map<Id, EventRegistrationWrapper> eventWrapperByContactId = new Map<Id, EventRegistrationWrapper>();
        String eventName = '';
        String eventYear = '';
        
        //Loop on Event registrations to create eventWrapperByContactId Map.
        Integer count = 0;
        for (Event_Registrations__c registration : [SELECT Id,Event__c,Createddate,Event__r.Name,Contact__c,
                                                    Contact__r.Name,Cvent_Registration_EmailAddress__c
                                                    FROM Event_Registrations__c
                                                    WHERE Event__c = :eventId]
            ){
                if(count == 0){                       
                    eventName = getEventName(registration.Event__r.Name);
                    eventYear = getEventYear(registration.Event__r.Name);
                    //Debug
                    System.debug('eventName :' + eventName);
                    System.debug('eventYear :' + eventYear);                        
                }
                count++;
                contactIds.add(registration.Contact__c);
                eventWrapperByContactId.put(registration.Contact__c, new EventRegistrationWrapper(registration));
            }
        
        if (!contactIds.isEmpty()) {
            for (Contact contact : [
                SELECT Id,Name,CreatedDate, (SELECT Id,Event__r.Name FROM Event_Registrations__r WHERE Event__c != :eventId)
                FROM Contact
                WHERE Id IN:contactIds
                ORDER BY Name
            ]) {
                EventRegistrationWrapper wrapper = eventWrapperByContactId.get(contact.Id);
                wrapper.newContact = false;
                
                //logic to check newContact checkbox if contact is created from eventregistration
                DateTime priorcreationDate = wrapper.createddate.addMinutes(-2);
                DateTime varianceDateTime = wrapper.createddate.addMinutes(2);
                
                if(priorcreationDate <= contact.createddate && 
                   contact.createddate <= varianceDateTime ){
                       wrapper.newContact = true;
                   }else{
                       wrapper.newContact = false;
                   }
                
                if (!contact.Event_Registrations__r.isEmpty()) {
                    wrapper.neverAttendedEvents = false;
                    wrapper.attendedPreviousEvents = false;
                    wrapper.totalEventsAttended = contact.Event_Registrations__r.size();
                    
                    //Loop on the Event Registrations to check if attended previous events.
                    for (Event_Registrations__c eventRegistration : contact.Event_Registrations__r) {
                        if (eventName == getEventName(eventRegistration.Event__r.Name) && !String.isEmpty(eventYear))
                        {
                            String oldEventYear = getEventYear(eventRegistration.Event__r.Name);
                            if(!String.isEmpty(oldEventYear) && Integer.valueOf(eventYear) > Integer.valueOf(oldEventYear))
                            {
                                wrapper.attendedPreviousEvents = true;
                                wrapper.totalPreviousEventsAttended += 1;
                            }
                        }
                        
                    }
                    
                } else {
                    wrapper.attendedPreviousEvents = false;
                    wrapper.neverAttendedEvents = true;
                }
                
                
                if (wrapper.neverAttendedEvents) totalWrap.totalNeverAttendedEvents += 1;
                if (wrapper.newContact) totalWrap.totalNewContacts += 1;
                if (wrapper.attendedPreviousEvents) totalWrap.totalContactsThatAttendedThisEvent += 1;
                
                eventRegistrationWrapper.add(wrapper);
            }
        }
        System.debug('wrapperMap =>' + eventWrapperByContactId.size());
        System.debug('eventRegistrationWrapper =>' + eventRegistrationWrapper.size());
        
        totalWrap.totalRegistrations = count;
        
        
        //Put data into data map
        mapOfData.put('EventRegistrations', eventRegistrationWrapper);
        mapOfData.put('Summary', totalWrap);
        contactIds.clear();
        eventWrapperByContactId.clear();
        
        //Return map of data
        return mapOfData;
    }
    
    

    //This method returns the Event Name from the Event.
    public static String getEventName(String event) {
        String eventName = '';
        //String regex = '\\d+';
        //Pattern eventPattern = Pattern.compile(regex);
        Matcher eventMatcher = eventPattern.matcher(event);
        String firstNumber = '';
        while (eventMatcher.find()) {
            if (eventMatcher.group().length() == 4) {
                firstNumber = eventMatcher.group();
                break;
            }
        }
        if (firstNumber != '') {
            Integer result = event.indexOf(firstNumber);
            eventName = result != 0 ? (event.substring(0, result - 1)).trim() : (event.substring(0, 0)).trim();
        }
        return eventName;
    }


    //This method returns the Event Year From the Event.
    public static String getEventYear(String event) {
        String eventYear = '';
        //String regex = '\\d+';
        //Pattern eventPattern = Pattern.compile(regex);
        Matcher eventMatcher = eventPattern.matcher(event);
        while (eventMatcher.find()) {
            if (eventMatcher.group().length() == 4) {
                eventYear = eventMatcher.group();
                break;
            }
        }
        return eventYear.trim();
    }

    class EventRegistrationWrapper implements Comparable {
        @AuraEnabled public String eventName { get; set; }
        @AuraEnabled public String eventId { get; set; }
        @AuraEnabled public String contactId { get; set; }
        @AuraEnabled public String contactName { get; set; }
        @AuraEnabled public String contactEmail { get; set; }
        @AuraEnabled public String eventLink { get; set; }
        @AuraEnabled public String contactLink { get; set; }
        @AuraEnabled public Boolean attendedPreviousEvents { get; set; }
        @AuraEnabled public Decimal totalPreviousEventsAttended { get; set; }
        @AuraEnabled public Boolean neverAttendedEvents { get; set; }
        @AuraEnabled public Decimal totalEventsAttended { get; set; }
        @AuraEnabled public Boolean newContact { get; set; }
@AuraEnabled public DateTime createdDate { get; set; }
        
        public EventRegistrationWrapper(Event_Registrations__c registration) {
            this.eventName = registration.Event__r.Name;
            this.eventId = registration.Event__c;
            this.contactName = registration.Contact__r.Name;
            this.contactId = registration.Contact__c;
            this.contactEmail = registration.Cvent_Registration_EmailAddress__c;
            this.eventLink = '/' + this.eventId;
            this.contactLink = '/' + this.contactId;
            this.totalPreviousEventsAttended = 0;
            this.totalEventsAttended = 0;
            this.createdDate = registration.createddate;
        }

        public Integer compareTo(Object ObjToCompare) {
            EventRegistrationWrapper compareToRec = (EventRegistrationWrapper) ObjToCompare;

            // Sort using Contact Name
            if (contactName > compareToRec.contactName) {
                return 1;
            } else if (contactName < compareToRec.contactName) {
                return -1;
            } else {
                return 0;
            }
        }
    }

    public class TotalWrapper {
        @auraEnabled public Decimal totalNewContacts { get; set; }
        @auraEnabled public Decimal totalRegistrations { get; set; }
        @auraEnabled public Decimal totalNeverAttendedEvents { get; set; }
        @auraEnabled public Decimal totalContactsThatAttendedThisEvent { get; set; }

        public TotalWrapper() {
            this.totalNewContacts = 0;
            this.totalRegistrations = 0;
            this.totalNeverAttendedEvents = 0;
            this.totalContactsThatAttendedThisEvent = 0;
        }
    }

}