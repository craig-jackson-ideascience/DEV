/**
 * Created by CR on 13-07-2020.
 */
({
        doInitHelper : function(component,event,helper){
            component.set('v.showSpinner',true);
            component.find("service").callApex(component, helper, "c.getAllEvents", {}, this.getAllEventsSuccess);
        },

        getAllEventsSuccess : function(component,returnValue,helper){
            component.set('v.eventNames', returnValue);
            component.set('v.showSpinner',false);
        },

        handleRunReportHelper : function(component,event,helper){
            console.log('IN handleRunReportHelper');
            component.set('v.showSpinner',true);
            let selectedEventId = component.find('events').get('v.value');
            console.log('selectedEventId :',selectedEventId);
            component.find("service").callApex(component, helper, "c.getRegistrationDetails",
            {"eventId" : selectedEventId}, this.getRegistrationDetailsSuccess);
        },

        getRegistrationDetailsSuccess : function(component,returnValue,helper){
            console.log(returnValue);
            var responseData = returnValue;
            var eventRegistrations  = responseData['EventRegistrations'];
            component.set("v.totalWrapper",responseData['Summary']);
            console.log('IN getRegistrationDetailsSuccess');
            if(Array.isArray(eventRegistrations) && eventRegistrations.length){
                var columns = [
                                {label: 'Event Name', fieldName: 'eventLink', type: 'url',
                                typeAttributes: {label: { fieldName: 'eventName' }, target: '_blank'}},
                                {label: 'Contact Name', fieldName: 'contactLink', type: 'url',
                                typeAttributes: {label: { fieldName: 'contactName' }, target: '_blank'}},
                                {label: 'Contact Email', fieldName: 'contactEmail', type: 'text'},
                                {label: 'Total Previous Events Attended', fieldName: 'totalPreviousEventsAttended', type: 'number'},
                                {label: 'Total Events Attended', fieldName: 'totalEventsAttended', type: 'number'},
                                {label: 'New Contact', fieldName: 'newContact', type: 'boolean'}
                                ];
                component.set('v.columns',columns);
                helper.paginateRegistrations(component,eventRegistrations,helper);
            }else{
               component.set("v.eventRegistrations", eventRegistrations);
               component.set('v.showSpinner',false);
               helper.showToast('Info!','info','There are no Event Registrations for this Event.');
            }
        },

        paginateRegistrations : function(component,records,helper){
            //reset defaults.
            component.set('v.pageSize',30);
            component.set('v.pageNumber',1);
            component.set('v.maxPage',1);

            var pageSize = component.get("v.pageSize");
            console.log('records.length :',records.length);
            component.set("v.eventRegistrations", records);
            component.set("v.totalRecords", records.length);
            component.set("v.maxPage", Math.ceil((records.length) / pageSize));
            this.renderPage(component);
            component.set('v.showSpinner',false);
        },

        renderPage: function(component) {
            var pageSize = component.get("v.pageSize");
            var records = component.get("v.eventRegistrations"),
                pageNumber = component.get("v.pageNumber"),
                pageRecords = records.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
            component.set("v.PaginationList", pageRecords);
        },

        handleExportHelper : function(component,event,helper){
            component.set('v.showSpinner',true);
            console.log('IN handleExportHelper');
            let selectedEventId = component.find('events').get('v.value');
            console.log('selectedEventId :',selectedEventId);
            component.find("service").callApex(component, helper, "c.getRegistrationDetails",
            {"eventId" : selectedEventId}, this.handleExportHelperSuccess);

            },

        handleExportHelperSuccess : function(component,returnValue,helper){
            var responseData = returnValue;
            var eventRegistrations  = responseData['EventRegistrations'];
            //component.set("v.totalWrapper",responseData['Summary']);
            if(Array.isArray(eventRegistrations) && eventRegistrations.length){
              var selectedEventName = component.get('v.eventNames').find(
                  opt => opt.value === component.find('events').get('v.value')).label;
              console.log('selectedEventName :'+selectedEventName)
              var header = 'Event Name,Contact Name,Contact Email,Total Previous Events Attended,Total Events Attended,New Contact\n';
              var body = helper.getContent(component,eventRegistrations);
              var responseData = ((header.concat(body)).concat('\n'));

              var hiddenElement = document.createElement('a');
              hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(responseData);
              hiddenElement.target = '_blank';
              hiddenElement.download = selectedEventName+'.csv';
              hiddenElement.click();
              component.set('v.showSpinner',false);
              helper.showToast('Success!','success','The file has been successfully downloaded.');
            }else{
                component.set('v.showSpinner',false);
                helper.showToast('Info!','info','There are no Event Registrations for this Event.');
            }

        },

        getContent : function(component,eventRegistrations){
            var reconRecordsList = new Array();
            var item = eventRegistrations;
            console.log('item '+item.length);
            item.forEach(function(content, index) {
                var reconRecords = new Array();
                var eventName = ('"').concat(content.eventName).concat('"');
                reconRecords.push(eventName.replace(',',''));
                reconRecords.push(content.contactName.replace(',',''));
                reconRecords.push(!$A.util.isUndefinedOrNull(content.contactEmail) ? content.contactEmail.replace(',','') : '');
                reconRecords.push(content.totalPreviousEventsAttended);
                reconRecords.push(content.totalEventsAttended);
                reconRecords.push(content.newContact ? 'TRUE' : 'FALSE');
                if(Array.isArray(reconRecords) && reconRecords.length){
                    reconRecordsList.push(reconRecords.join());
                }
            });
            if(Array.isArray(reconRecordsList) && reconRecordsList.length){
                return reconRecordsList.join('\n');
            }
        },

        showToast : function(title, type, message) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": title,
                    "type": type,
                    "message": message
                });
                toastEvent.fire();
            },
})