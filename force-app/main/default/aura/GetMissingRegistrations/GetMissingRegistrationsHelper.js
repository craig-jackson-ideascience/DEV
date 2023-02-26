/**
 * Created by cloudroute on 22/09/20.
 */
({
    fetchFileName : function (cmp, event, helper) {
        var action = cmp.get("c.getFileName");
        action.setParams({
            eventID : cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var syncStatus = response.getReturnValue();
                if (syncStatus.startsWith('Error')) {
                    helper.showToast("Error", syncStatus);
                }else if (syncStatus.startsWith('Info')) {
                    helper.showToast("Info", syncStatus);
                }else{//Success
                    console.log('##syncStatus :',syncStatus);
                    cmp.set('v.fileName',syncStatus);
                }
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                helper.showToast("Error", "Something went wrong while getting event details. Please contact System Administrator.");
                $A.get("e.force:closeQuickAction").fire();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    doInitHelper: function (cmp, event, helper) {
        var action = cmp.get("c.getCventData");
        action.setParams({
            eventID : cmp.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var syncStatus = response.getReturnValue();
                if (syncStatus.startsWith('Error')) {
                    helper.showToast("Error", syncStatus);
                }else if (syncStatus.startsWith('Info')) {
                    helper.showToast("Info", syncStatus);
                }else{//Success
                    /*var blob = helper.convertBase64toBlob(syncStatus);
                    var fileName = cmp.get('v.fileName'); //'Missing File Registrations';
                    saveAs(blob, fileName);
                    helper.showToast("Success", "Missing event registrations file downloaded successfully.");
                */
                helper.showToast("Success", "Missing Event Registrations have been Retrieved successfully");    
               }
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get("e.force:refreshView").fire();
                    }), 2000
                );
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                helper.showToast("Error", "Something went wrong while getting missing event registrations. Please contact System Administrator.");
                $A.get("e.force:closeQuickAction").fire();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    convertBase64toBlob: function(content) {
        var sliceSize = 512;
        var byteCharacters = window.atob(content); //method which converts base64 to binary
        var byteArrays = [];
        for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
            var slice = byteCharacters.slice(offset, offset + sliceSize);
            var byteNumbers = new Array(slice.length);
            for (var i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }
            var byteArray = new Uint8Array(byteNumbers);
            byteArrays.push(byteArray);
        }
        var blob = new Blob(byteArrays); //statement which creates the blob
        return blob;
    },

    showToast: function (type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": type,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})