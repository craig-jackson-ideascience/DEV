public class MetadataUpdatePicklist {
    public static void updatePicklistField(Map<Id,String> projectIdVSName){
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.timeout_x = 120000;
        
        MetadataService.CustomField picklistField = (MetadataService.CustomField) service.readMetadata(
            'CustomField', new String[] {'Account.Project_Memberships__c'}
        ).getRecords()[0];
        System.debug('picklistField' +picklistField);
        for(string val:projectIdVSName.keySet()){
            Boolean canCreate = true;
            
            //Iterate through existing values of picklist and check whether it exist
            for(MetadataService.CustomValue objCustomValue : picklistField.valueSet.valueSetDefinition.value){
                if(objCustomValue.fullName == val){  
                    objCustomValue.label = projectIdVSName.get(val); // New Label value
                    canCreate=false;
                    break;
                }
            }
            if(canCreate){
                MetadataService.CustomValue newValue = new MetadataService.CustomValue();
                newValue.fullName =val;
                newValue.label =projectIdVSName.get(val);
                newValue.default_x = false;
                newValue.isActive = true;
                picklistField.valueSet.valueSetDefinition.value.add(newValue);
            }
        }
        List<MetadataService.SaveResult> saveResult =
            service.updateMetadata(
                new MetadataService.Metadata[] { picklistField });
        handleSaveResults(saveResult[0]);
        
        addPicklistValueToRecordType(service,projectIdVSName.keySet());
    }
    
    private static List<String> getRecordTypes(){
        List<String> recordTypes = new List<String>();
        String prefix ='Account';
        for(RecordType recordType : [SELECT Id,DeveloperName from RecordType where sObjectType='Account' AND IsPersonType=false]){
            recordTypes.add(prefix + '.' + recordType.DeveloperName);
        }
        return recordTypes;
    }
    
    private static void addPicklistValueToRecordType(MetadataService.MetadataPort service,Set<Id> picklist){
        List<MetadataService.PicklistValue> picklistValues = getPicklistValues(picklist);
        String[] recordTypeNames = getRecordTypes();
        // Get the record type from the API
        MetadataService.RecordType[] recordTypes = (MetadataService.RecordType[]) service.readMetadata(
            'RecordType', recordTypeNames
        ).getRecords();
        
        
        // loop through the record types and set the picklist values
        for(MetadataService.RecordType RT : recordTypes){            
            for(MetadataService.RecordTypePicklistValue picklistValue : RT.picklistValues){
                if(picklistValue.picklist == 'Project_Memberships__c'){
                    picklistValue.values.addAll(picklistValues);
                }
            }
        }
        
        // Update the record type
        service.updateMetadata(recordTypes);
        //service.updateMetadata(new MetadataService.Metadata[] { mdRecordTypes });        
    }
    
    private static List<MetadataService.PicklistValue> getPicklistValues(Set<Id> picklistvalues){
        List<MetadataService.PicklistValue> values = new List<MetadataService.PicklistValue>();
        for(string val:picklistvalues){
            MetadataService.PicklistValue newValue = new MetadataService.PicklistValue();
            newValue.fullName =val;            
            newValue.default_x = false;
            newValue.isActive = true;
            values.add(newValue);
        }
        return values;
    } 
    
    public class MetadataServiceExamplesException extends Exception { }
    
    /**
* Example helper method to interpret a SaveResult, throws an exception if errors are found
**/
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
}