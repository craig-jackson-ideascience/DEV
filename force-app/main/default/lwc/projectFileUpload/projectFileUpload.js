import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ENTITY_TYPE_FIELD from '@salesforce/schema/Project__c.Category__c';
import FORMATION_DATE_FIELD from '@salesforce/schema/Project__c.Start_Date__c';
import SERIES_AGREEMENT_FIELD from '@salesforce/schema/Project__c.Series_Agreement_URL__c';
import MSA_FIELD from '@salesforce/schema/Project__c.MasterServiceAgreementURL__c';
import INCORPORATION_DOC_FIELD from '@salesforce/schema/Project__c.Project_Entity_Formation_Document__c';
import GOVERNANCE_DOC_FIELD from '@salesforce/schema/Project__c.Governance_Document_URL__c';
import ASSIGNMENT_AGREEMENT_FIELD from '@salesforce/schema/Project__c.Assignment_Agreement_URL__c';
import DISSOLUTION_DOC_FIELD from '@salesforce/schema/Project__c.Dissolution_Document_URL__c';
import getUserEditAccess from '@salesforce/apex/ProjectFileUploadController.getUserEditAccess';
import updateProjectAndFile from '@salesforce/apex/ProjectFileUploadController.updateProjectAndFile';

const fields = [ENTITY_TYPE_FIELD, FORMATION_DATE_FIELD, SERIES_AGREEMENT_FIELD, MSA_FIELD,
    INCORPORATION_DOC_FIELD, GOVERNANCE_DOC_FIELD, ASSIGNMENT_AGREEMENT_FIELD, DISSOLUTION_DOC_FIELD];

export default class ProjectFileUpload extends LightningElement {
    @api recordId;
    @api docTypes;
    @track currentUserHasEditAccess = false;
    @track allFilesUploaded = false;
    @track unsupportedEntityType = false;
    @track noEntityType = false;
    @track requireEffectiveDate = false;
    @track infoMessage = '';
    @track showInfoMessage = false;
    @track disableUpload = true;
    @track successMessage = '';
    @track showSuccessMessage = false;
    docType = 'none';
    effectiveDate = null;
    projData;

    //set the file types allowed to be uploaded
    get acceptedFormats() {
        return ['.pdf', '.zip'];
    }

    //determine if user has edit access to this record
    @wire(getUserEditAccess, {projectID: '$recordId'})
    wiredAddress(result){
        if(result.data){
            this.currentUserHasEditAccess = result.data;
        } else if(result.error) {
            console.log('Error determining if user has edit access to this Project');
            console.log(result.error);
        }
    }

    //get data for the current Project record, then populate the document types picklist
    @wire(getRecord, { recordId: '$recordId', fields })
    proj({data}) {
        if(data){
            this.projData = data;
            this.setDocumentTypes();
        }
    }

    //populate the document types picklist
    setDocumentTypes(){
        //create a temporary array for the relevant document types
        let typeArray = [];

        //add "None" as the first value to the array
        typeArray.push({ label: '--None--', value: 'none' });

        //add the document types relevant to this Project's Entity Type, as long as that document type
        //hasn't already been uploaded to this project
        let entityType = getFieldValue(this.projData, ENTITY_TYPE_FIELD);
        if(entityType == 'Incorporated Entity'){
            this.addType(typeArray, INCORPORATION_DOC_FIELD, 'Incorporation Document', 'incorporation');
            this.addType(typeArray, ASSIGNMENT_AGREEMENT_FIELD, 'Assignment Agreement', 'assignment');
            this.addType(typeArray, GOVERNANCE_DOC_FIELD, 'Governance Document', 'governance');
            this.addType(typeArray, DISSOLUTION_DOC_FIELD, 'Dissolution Document', 'dissolution');
            this.addType(typeArray, MSA_FIELD, 'Management Services Agreement', 'msa');
        }else if(entityType == 'Series LLC'){
            this.addType(typeArray, SERIES_AGREEMENT_FIELD, 'Series Agreement', 'series');
            this.addType(typeArray, ASSIGNMENT_AGREEMENT_FIELD, 'Assignment Agreement', 'assignment');
            this.addType(typeArray, DISSOLUTION_DOC_FIELD, 'Dissolution Document', 'dissolution');
        }else if(entityType == 'Subproject'){
            this.addType(typeArray, ASSIGNMENT_AGREEMENT_FIELD, 'Assignment Agreement', 'assignment');
        }else if(entityType == null){
            //users should be able to upload an Assignment Agreement for projects that don't have an
            //Entity Type chosen yet
            this.addType(typeArray, ASSIGNMENT_AGREEMENT_FIELD, 'Assignment Agreement', 'assignment');
            this.noEntityType = true;
        }else{
            this.unsupportedEntityType = true;
        }
        
        //if "None" was the only value added to the temp array, then all file types for this Entity Type
        //have already been uploaded
        if(typeArray.length == 1){
            this.allFilesUploaded = true;
        //if at least one actual docType was added to the temp array, set the types array to temp array
        }else{
            this.docTypes = typeArray;
        }
    }

    addType(array, fieldName, typeLabel, typeValue){
        //get the value of the field passed into this method
        let field = getFieldValue(this.projData, fieldName);

        //add this type to the array only if the value of that field is blank
        if(field == null){
            let newType = { label: typeLabel, value: typeValue };
            array.push(newType);
        }
    }

    //handle the user selecting a document type
    selectType(event) {
        this.docType = event.detail.value;
        if(this.docType == 'msa'){
            this.infoMessage = 'If this agreement contains an expiration date, please enter it into the Management Services Expiration Date field once you\'ve finished uploading this document.'
            this.infoMessage += ' (The Management Services Effective Date field will be automatically set for you with the effective date you enter above.)';
            this.showInfoMessage = true;
            this.requireEffectiveDate = true;
        }else if(this.docType == 'incorporation'){
            this.infoMessage = 'The Formation Date of this project will automatically be set to the effective date of this document once the file upload is complete.';
            this.showInfoMessage = true;
            this.requireEffectiveDate = true;
        }else if(this.docType == 'series'){
            this.infoMessage = 'The Formation Date of this project will automatically be set to the effective date of this document once the file upload is complete.';
            this.showInfoMessage = true;
            this.requireEffectiveDate = true;
        }else if(this.docType == 'dissolution'){
            this.infoMessage = 'The Dissolution/End Date of this project will automatically be set to the effective date of this document once the file upload is complete.';
            this.showInfoMessage = true;
            this.requireEffectiveDate = true;
        }else{
            this.infoMessage = '';
            this.showInfoMessage = false;
            this.requireEffectiveDate = false;
        }
        this.toggleUploadEnable();
    }

    //handle the user updating the effective date
    handleEffectiveDateChange(event){
        this.effectiveDate = event.target.value;
        this.toggleUploadEnable();
    }

    //toggle the disable attribute of the file uploader
    toggleUploadEnable() {
        if(this.docType == 'none' || (this.requireEffectiveDate && this.effectiveDate == null)){
            this.disableUpload = true;
        }else{
            this.disableUpload = false;
        }
    }

    //after a file has been uploaded, run Apex method to update fields on the Project and File records
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const fileID = uploadedFiles[0].documentId;

        updateProjectAndFile({projectID: this.recordId, fileID: fileID, docType: this.docType, effectiveDate: this.effectiveDate})
        .then(result => {
            this.successMessage = 'Your file was uploaded successfully! Refresh the page to confirm.'
            this.showSuccessMessage = true;
        })
        .catch(error => {
            console.log('Error adding file URL to Project record');
            console.log(error);
        });
    }
}