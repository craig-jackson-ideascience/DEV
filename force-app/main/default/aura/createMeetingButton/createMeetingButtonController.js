({
	createMeeting : function(component, event, helper) {
        console.log('Create meeting');
    	var appEvent = $A.get("e.c:createMeetingEvent");
		appEvent.fire();
    },
    cancel : function(component, event, helper) {
        console.log('Close the modal');
        component.find("overlayLib").notifyClose();
    }
})