import { LightningElement, api, wire } from 'lwc';
import checkForStatuses from '@salesforce/apex/CampaignDispositionController.checkForStatuses';
import getPriorAutoDispositionedData from '@salesforce/apex/CampaignDispositionController.getPriorAutoDispositionedData';
import addStatuses from '@salesforce/apex/CampaignDispositionController.addStatuses';
import updateStatuses from '@salesforce/apex/CampaignDispositionController.updateStatuses';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PROJECT_FIELD from '@salesforce/schema/Campaign.Project__c';

const fields = [PROJECT_FIELD];

export default class CampaignDisposition extends LightningElement {

    @api recordId;
    @api hasStatuses = false;
    @api message = '';
    @api showPriorData = false;
    @api priorData = [];

    @wire(getRecord, { recordId: '$recordId', fields })
    campn;

    get project(){
        return getFieldValue(this.campn.data, PROJECT_FIELD);
    }

    connectedCallback(){
        checkForStatuses({campaignID: this.recordId})
        .then(result => {
            if(result == true){
                this.hasStatuses = true;
            }
        })
        .catch(error => {
            this.message = 'An error has occurred. Please log a ticket with Sales Ops.';
            console.log('Error checking for statuses');
            console.log(error);
        });
    }

    addStatuses(){
        addStatuses({campaignID: this.recordId})
        .then(result => {
            this.message = 'Success! Refresh the page to see the new Campaign Member Statuses.';
        })
        .catch(error => {
            this.message = 'An error has occurred. Please log a ticket with Sales Ops.';
            console.log('Error adding new statuses');
            console.log(error);
        });
    }

    updateStatuses(){
        this.showPriorData = false;

        updateStatuses({campaignID: this.recordId, projectID: this.project})
        .then(result => {
            if(result == -1){
                this.message = 'Auto-dispositioning has been queued to handle the large number of Campaign Members on this Campaign. You will receive an email when auto-dispositoning is complete.';
            }else if(result == 0){
                this.message = 'Auto-dispositioning ran successfully, but no Campaign Member statuses were updated as a result.';
            }else if(result > 0){
                this.message = 'Success! Refresh the page to see updated statuses in the Campaign Members related list, below.';
            }
        })
        .catch(error => {
            this.message = 'An error has occurred. Please log a ticket with Sales Ops.';
            console.log('Error updating statuses of Campaign Members');
            console.log(error);
        });
    }

    showLastUpdates(){
        getPriorAutoDispositionedData({campaignID: this.recordId})
        .then(result => {
            if(result && result.length > 0){
                this.priorData = result;
                this.showPriorData = true;
            }else if(result && result.length == 0){
                this.message = 'No prior auto-disposition updates were found for this Campaign.'
            }
        })
        .catch(error => {
            this.message = 'An error fetching previously auto-dispositioned data has occurred. Please log a ticket with Sales Ops.';
            console.log('Error fetching previously auto-dispositioned Campaign Members');
            console.log(error);
        });
    }

    hideLastUpdates(){
        this.priorData = [];
        this.showPriorData = false;
    }
}