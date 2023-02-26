/********************************************************
 * Created by: Kalyani Chiluveri
 * Created Date: 05/05/20.
 * Description: JoinNowFormSubmissionHelper
 ********************************************************/
public with sharing class JoinNowFormSubissionHelper {
    
    public static Map<String, String> labelVsValues = new Map<String, String>();
    public static List<String> contactLeadSource = new List<String>();
    public static Map<String, List<String>> leadSourceVsDetail = new Map<String,List<String>>(); 

       
    static {
        getConfigValues();
        populateLeadvsLeadDetails();
    }
    public static Map<String,String> getConfigValues() {
        List<Linux_Config__mdt> configList = [Select Label,Value__c from Linux_Config__mdt];
        for(Linux_Config__mdt obj : configList){
            labelVsValues.put(obj.Label, obj.Value__c);
        }
        return labelVsValues;
    }

    public static List<String> splitValue(String splitString, String delimeter) {
        List<String> splitStringValues = new List<String>();
        if(splitString != NULL && splitString != '') {
            splitStringValues = splitString.split(delimeter);
        }
        return splitStringValues;
    }

    public static void populateLeadvsLeadDetails() {
        List<String> contactLeadSourceDetail = JoinNowFormSubissionHelper.splitValue(labelVsValues.get('ContactLeadSourceDetail'),';');
        contactLeadSource = JoinNowFormSubissionHelper.splitValue(labelVsValues.get('ContactLeadSource'),';');
        for(String conLeadDt: contactLeadSourceDetail) {    
            List<String> newList = JoinNowFormSubissionHelper.splitValue(conLeadDt,'=>');
            leadSourceVsDetail.put(newList[0].trim(),JoinNowFormSubissionHelper.splitValue(newList[1],','));
        }
    }

    public static Map<String,ContactLeadAndLeadDetailsWrapper> checkForLeadSouceAndDetails(Map<String, String> emailVsLeadId,Map<String, Alternate_Email__c> emailVsAltEmail) {
        Map<String,ContactLeadAndLeadDetailsWrapper> leadIdVsLeadDetails = new Map<String,ContactLeadAndLeadDetailsWrapper>();
        for(String leadEmail : emailVsLeadId.keySet()) {
            Alternate_Email__c altEmail = emailVsAltEmail.get(leadEmail);
            if(altEmail.Lead_Name__r.LeadSource != NULL && altEmail.Lead_Name__r.Lead_Source_Detail_p__c != NULL ) {
                if((!(contactLeadSource.contains(altEmail.Lead_Name__r.LeadSource.trim()))) || (!((leadSourceVsDetail.get(altEmail.Lead_Name__r.LeadSource.trim()).contains(altEmail.Lead_Name__r.Lead_Source_Detail_p__c.trim()))))){
                    leadIdVsLeadDetails.put(emailVsLeadId.get(leadEmail),new ContactLeadAndLeadDetailsWrapper(leadEmail,altEmail.Lead_Name__r.LeadSource,altEmail.Lead_Name__r.Lead_Source_Detail_p__c));
                }
            }else {
                leadIdVsLeadDetails.put(emailVsLeadId.get(leadEmail),new ContactLeadAndLeadDetailsWrapper(leadEmail,altEmail.Lead_Name__r.LeadSource,altEmail.Lead_Name__r.Lead_Source_Detail_p__c));
            }
        }  
        if(!leadIdVsLeadDetails.isEmpty())
            JoinNowFormSubissionHelper.updateLeadDetails(leadIdVsLeadDetails);
        return leadIdVsLeadDetails;
    }

    public static void updateLeadDetails(Map<String,ContactLeadAndLeadDetailsWrapper> leadIdVsLeadDetails) {
        List<lead> updateLeadList = new List<Lead>();
        for(String leadID: leadIdVsLeadDetails.keySet()) {
            Lead leadObj = new Lead();
            leadObj.Id = leadID;
            leadObj.LeadSource = '';
            leadObj.Lead_Source_Detail_p__c = '';
            updateLeadList.add(leadObj);
        }

        if(!updateLeadList.isEmpty()){
            update updateLeadList;
        }
    }

    public static void populateContactDetails(Map<String,ContactLeadAndLeadDetailsWrapper> leadIdVsLeadDetails, Map<String,String> emailVsContactId, Map<String,Contact> emailVsContact) {
    
        for(String leadID : leadIdVsLeadDetails.keySet()) {
            Contact conObj = new Contact();
            conObj.Id = emailVsContactId.get(leadIdVsLeadDetails.get(leadID).emailAddress);
            conObj.LeadSource = 'Join Us Form';
            conObj.Lead_Source_Detail1__c = 'Other';
            conObj.Lead_Source_Detail__c = leadIdVsLeadDetails.get(leadID).leadSource+','+leadIdVsLeadDetails.get(leadID).leadSourceDetail;
            emailVsContact.put(leadIdVsLeadDetails.get(leadID).emailAddress, conObj);
        }
    }

    public class ContactLeadAndLeadDetailsWrapper {
        public String emailAddress;
        public String leadSource;
        public String leadSourceDetail;

        public ContactLeadAndLeadDetailsWrapper(String emailAddress, String leadSource, String leadSourceDetail) {
            this.emailAddress = emailAddress;
            this.leadSource = leadSource;
            this.leadSourceDetail = leadSourceDetail;
        }
    }
    

    

}