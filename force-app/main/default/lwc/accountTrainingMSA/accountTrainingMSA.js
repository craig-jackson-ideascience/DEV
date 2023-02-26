import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TRAINING_MSA_FILE_ID_FIELD from '@salesforce/schema/Account.Training_MSA_File_ID__c';
import addFileIDToAccount from '@salesforce/apex/AccountTrainingMSAController.addFileIDToAccount';

const fields = [TRAINING_MSA_FILE_ID_FIELD];

export default class AccountTrainingMSA extends LightningElement {
    @api recordId;
    @api successMessage = '';
    @api showMsg = false;

    @wire(getRecord, { recordId: '$recordId', fields })
    acc;

    get msaURL(){
        let fileID = getFieldValue(this.acc.data, TRAINING_MSA_FILE_ID_FIELD);
        let url = '/lightning/r/ContentDocument/' + fileID + '/view';
        return url;
    }

    get hasMSA(){
        if(getFieldValue(this.acc.data, TRAINING_MSA_FILE_ID_FIELD) == null){
            return false;
        }else{
            return true;
        }
    }

    get acceptedFormats() {
        return ['.pdf'];
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const fileID = uploadedFiles[0].documentId;

        addFileIDToAccount({accountID: this.recordId, fileID: fileID})
        .then(result => {
            this.successMessage = 'The MSA was uploaded successfully! Refresh the page to confirm.'
            this.showMsg = true;
        })
        .catch(error => {
            console.log('Error adding MSA file ID to Account record');
            console.log(error);
        });
    }
}