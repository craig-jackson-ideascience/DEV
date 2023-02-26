import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LOGO_URL_FIELD from '@salesforce/schema/Account.Logo_URL__c';

const fields = [LOGO_URL_FIELD];

export default class AccountLogo extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    acc;

    get logoURL(){
        return getFieldValue(this.acc.data, LOGO_URL_FIELD);
    }
}