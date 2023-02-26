/**
 * Created by cloudroutesolutions on 24/03/21.
 */

public without sharing class EventDashboard_RegistrationController {
    public static final String LABEL = 'label';
    public static final String VALUE = 'value';
    public static List<String> statusList = new List<String>{'Accepted', 'Approved', 'Attended', 'Confirmed', 'Declined', 'Follow-up', 'No-show', 'Pending', 'Standby'};

    @AuraEnabled
    public static Map<String, Object> getAllEvents(String defaultValue) {
        Map<String,Object> responseMap = new Map<String,Object>();
        //Initialize Variable
        List<Map<String, String>> eventNames = new List<Map<String, String>>();
        //Loop on all events to create eventNames List.
        for (Event__c event : [
                Select id, name
                from Event__c
                where Start_Date__c >= Last_N_Days:15 AND Event_Registrations__c != 0
                ORDER BY Name
        ]) {
            System.debug('eventNames :' + event.name);
            String key = event.Name;
            eventNames.add(new Map<String, String>{
                    LABEL => key,VALUE => event.Id
            });
        }
        responseMap.put('Events',eventNames);
        return responseMap;
    }

    @AuraEnabled
    public static Map<String,Object> getRegistrationDetails(String eventIds) {
        Map<String,Object> responseMap = new Map<String,Object>();
        System.debug('#--eventIds--#' + eventIds);
        if(String.isNotEmpty(eventIds)) {
            List<Id> eventIdList = (List<Id>) JSON.deserialize(eventIds, List<Id>.class);
        }
           /* List<Event_Registrations__c> evtRegistrationList = [
                    SELECT Id, Name, Cvent_Registration_RegistrationDate__c,Cvent_Registration_Status__c, Event__c, Event__r.name,
                            Cvent_Registration_AmountPaid__c,Cvent_Registration_AmountPaid_Formula__c, CreatedDate
                    FROM Event_Registrations__c
                    WHERE Event__c != null  AND Cvent_Registration_Status__c IN: statusList And Day_Only(CreatedDate) = Last_N_Weeks:2
                    ORDER BY CreatedDate desc ]; //Event__c IN:eventIdList*/

        Date endDateOfPreviousWeek = System.today().toStartOfWeek().addDays(-2);
        System.debug('endDateOfPreviousWeek: ' + endDateOfPreviousWeek);

        List<Event_Registrations__c> evtRegistrationList = [
                    SELECT Id, Name, Cvent_Registration_RegistrationDate__c, Event__c, Event__r.name, Event__r.Revenue_Goal__c, Cvent_Registration_AmountPaid_Formula__c, CreatedDate
                    FROM Event_Registrations__c
                    WHERE Event__c != null AND Event__c IN: [ Select Id
                    from Event__c
                    where Start_Date__c >=: (endDateOfPreviousWeek.addDays(-7))  AND Event_Registrations__c != 0
                    ORDER BY Name]
                    AND Cvent_Registration_Status__c IN: statusList And  Cvent_Registration_RegistrationDate__c <= TODAY
                    ORDER BY Cvent_Registration_RegistrationDate__c ASC ]; //Event__c IN:eventIdList
/* Event__c IN: [ Select Id
from Event__c
where Start_Date__c >= Last_N_Days:15 AND Event_Registrations__c != 0
ORDER BY Name]*/
            System.debug('Event_Registrations__c '+evtRegistrationList);
            if(!evtRegistrationList.isempty()){

                system.debug('Registration '+evtRegistrationList[0].Cvent_Registration_RegistrationDate__c);
                Map<Id, String> eventIdVsName = new Map<Id, String>();
                Map<Id, Map<Integer, Decimal>> EventIdVsWeekNumberVsAmountPaid = new Map<Id, Map<Integer, Decimal>>();

                integer currentWeekNumber = integer.valueOf(system.now().Format('w'));
                System.debug('currentWeekNumber: ' + currentWeekNumber);

                integer previousWeekNumber = integer.valueOf(((Datetime)endDateOfPreviousWeek).Format('w'));
                System.debug('previousWeekNumber: ' + previousWeekNumber);

                Map<String,String> yearWeek = new Map<String,String>{
                        system.now().year() +''+ currentWeekNumber => String.valueOf(system.today())
                        , endDateOfPreviousWeek.year() +''+ previousWeekNumber => String.valueOf(endDateOfPreviousWeek)
                };
                System.debug('yearWeek: ' + yearWeek);

                Map<Id, Decimal> eventIdVsRevenueGoal = new Map<Id, Decimal>();

                for (Event_Registrations__c evtReg : evtRegistrationList) {
                    System.debug('evtReg.Id: ' + evtReg.Id);
                    integer registrationWeekNumber = integer.valueOf(evtReg.Cvent_Registration_RegistrationDate__c.Format('w'));
                    System.debug('registrationWeekNumber: ' + registrationWeekNumber);
                    System.debug('evtReg.Cvent_Registration_RegistrationDate__c: ' + evtReg.Cvent_Registration_RegistrationDate__c.dateGmt());
                    integer weekNumber = (evtReg.Cvent_Registration_RegistrationDate__c).dateGmt() <= endDateOfPreviousWeek ? previousWeekNumber : currentWeekNumber;
                    System.debug('weekNumber: ' + weekNumber);

                    if(!EventIdVsWeekNumberVsAmountPaid.containsKey(evtReg.Event__c)){
                        Decimal totalAmount = evtReg.Cvent_Registration_AmountPaid_Formula__c != null ?
                                evtReg.Cvent_Registration_AmountPaid_Formula__c : 0.0;
                        EventIdVsWeekNumberVsAmountPaid.put(evtReg.Event__c, new Map<Integer, Decimal>{weekNumber => totalAmount});
                    }else{
                        Map<Integer, Decimal> WeekNumberVsAmountPaid = EventIdVsWeekNumberVsAmountPaid.get(evtReg.Event__c);
                        if(!WeekNumberVsAmountPaid.containsKey(weekNumber)){
                            Decimal totalAmount = evtReg.Cvent_Registration_AmountPaid_Formula__c != null ?
                                    evtReg.Cvent_Registration_AmountPaid_Formula__c : 0.0;

                            totalAmount = (evtReg.Cvent_Registration_RegistrationDate__c).dateGmt() > endDateOfPreviousWeek &&  WeekNumberVsAmountPaid.containsKey(currentWeekNumber - 1) ? WeekNumberVsAmountPaid.get(currentWeekNumber - 1) + totalAmount : totalAmount;

                            WeekNumberVsAmountPaid.put(weekNumber, totalAmount);
                            EventIdVsWeekNumberVsAmountPaid.put(evtReg.Event__c, WeekNumberVsAmountPaid);
                        }else{
                            Decimal totalAmount = WeekNumberVsAmountPaid.get(weekNumber) + (evtReg.Cvent_Registration_AmountPaid_Formula__c != null ?
                                    evtReg.Cvent_Registration_AmountPaid_Formula__c : 0.0);
                            System.debug('totalAmount: ' + totalAmount);
                            WeekNumberVsAmountPaid.put(weekNumber, totalAmount);
                            EventIdVsWeekNumberVsAmountPaid.put(evtReg.Event__c, WeekNumberVsAmountPaid);
                        }
                    }
                    System.debug('EventIdVsWeekNumberVsAmountPaid: ' + EventIdVsWeekNumberVsAmountPaid);

                    if(!eventIdVsName.containsKey(evtReg.Event__c)){
                        eventIdVsName.put(evtReg.Event__c, evtReg.Event__r.Name);
                    }

                    if(!eventIdVsRevenueGoal.containsKey(evtReg.Event__c)){
                        eventIdVsRevenueGoal.put(evtReg.Event__c, evtReg.Event__r.Revenue_Goal__c == null ? 0.0 : evtReg.Event__r.Revenue_Goal__c);
                    }
                }

                for(Id eventId :EventIdVsWeekNumberVsAmountPaid.keySet()){
                    for(Integer week :EventIdVsWeekNumberVsAmountPaid.get(eventId).keySet()){
                        Decimal finalRevenue = eventIdVsRevenueGoal.get(eventId) - EventIdVsWeekNumberVsAmountPaid.get(eventId).get(week);
                        EventIdVsWeekNumberVsAmountPaid.get(eventId).put(week, finalRevenue);
                    }
                }
               responseMap.put('EventVsWeekVsRevenue',EventIdVsWeekNumberVsAmountPaid);
               responseMap.put('YearWeeks',yearWeek);
               responseMap.put('EventIdVsName',eventIdVsName);
            }
        return responseMap;
    }
}