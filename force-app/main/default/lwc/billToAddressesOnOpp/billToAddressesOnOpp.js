import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import getBillToAddress from '@salesforce/apex/BillToAddressesOnOppController.getBillToAddress';
import getBillToAddresses from '@salesforce/apex/BillToAddressesOnOppController.getBillToAddresses';
import saveSelectedAddress from '@salesforce/apex/BillToAddressesOnOppController.saveSelectedAddress';
import clearBillToAddress from '@salesforce/apex/BillToAddressesOnOppController.clearBillToAddress';
import ADDRESS_OBJECT from '@salesforce/schema/Address__c';
import NAME_FIELD from '@salesforce/schema/Address__c.Name';
import STREET_FIELD from '@salesforce/schema/Address__c.Street__c';
import CITY_FIELD from '@salesforce/schema/Address__c.City__c';
import STATE_FIELD from '@salesforce/schema/Address__c.State__c';
import ZIP_FIELD from '@salesforce/schema/Address__c.Zip_Postal_Code__c';
import COUNTRY_FIELD from '@salesforce/schema/Address__c.Country__c';
import ACCOUNT_FIELD from '@salesforce/schema/Address__c.Account__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Address__c.Description__c';

const FIELDS = [
    'Opportunity.AccountId',
];

export default class BillToAddressesOnOpp extends LightningElement {

    @api recordId;
    @api addresses = [];
    @api selectedAddress;
    @api addressesExist = false;
    @api showMessage = false;
    @api message = '';
    @api modalOpen = false;
    @api wiredAddressesResult;

    addressObject = ADDRESS_OBJECT;
    accountField = ACCOUNT_FIELD;
    nameField = NAME_FIELD;
    streetField = STREET_FIELD;
    cityField = CITY_FIELD;
    stateField = STATE_FIELD;
    zipField = ZIP_FIELD;
    countryField = COUNTRY_FIELD;
    descriptionField = DESCRIPTION_FIELD;

    @wire(getBillToAddress, {oppID: '$recordId'})
    wiredAddress(result){
        if(result.data){
            this.selectedAddress = result.data;
        } else if(result.error) {
            this.selectedAddress = undefined;
            console.log(result.error);
        }
    }

    @wire(getBillToAddresses, {oppID: '$recordId'})
    wiredAddresses(result){
        this.wiredAddressesResult = result;
        if(result.data){
            if(result.data.length > 0){
                this.addressesExist = true;
            }
            let addressArray = [];
            for(let i=0; i<result.data.length; i++){
                const address = {};
                address.value = result.data[i].Id;
                address.label = result.data[i].Name + ' || ';
                let formattedAddress = this.formatAddress(result.data[i].Street__c, result.data[i].City__c, 
                    result.data[i].State__c, result.data[i].Zip_Postal_Code__c, result.data[i].Country__c);
                address.label += formattedAddress;
                addressArray.push(address);
            }
            this.addresses = addressArray;
        } else if(result.error) {
            this.addresses = undefined;
            console.log(result.error);
        }
    }

    //only need this to get Account ID to pre-populate it in new Address record
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    oppt;

    get accountID() {
        return this.oppt.data.fields.AccountId.value;
    }

    formatAddress(street, city, state, zip, country){
        let formattedAddress = '';
        
        if(street){
            formattedAddress += street.replace('\n', ' ') + ', ';
        }
        if(city){
            if(state){
                formattedAddress += city + ', ';
            }else{
                formattedAddress += city + ' ';
            }
        }
        if(state){
            formattedAddress += state + ' ';
        }
        if(zip){
            formattedAddress += zip;
        }
        if(country){
            if(zip){
                formattedAddress += ', ' + country;
            }else{
                formattedAddress += ' ' + country;
            }
        }
        formattedAddress = formattedAddress.replace(',,', ',');
        formattedAddress = formattedAddress.replace(' ,', ',');
        
        return formattedAddress;
    }

    handleAddressChange(event){
        this.selectedAddress = event.detail.value;
    }

    saveBillToAddress(){
        saveSelectedAddress({oppID: this.recordId, addrID: this.selectedAddress})
            .then((result) => {
                this.message = 'Success!  Refresh the page to update the Billing To field, above.';
                this.showMessage = true;
            })
            .catch((error) => {
                console.log('error');
            });
    }

    useAccountAddress(){
        clearBillToAddress({oppID: this.recordId})
            .then((result) => {
                this.message = 'Success!  Refresh the page to update the Billing To field, above.';
                this.showMessage = true;
            })
            .catch((error) => {
                console.log('error');
            });
    }

    handleOpenModal(){
        this.modalOpen = true;
    }

    handleCloseModal(){
        this.modalOpen = false;
    }

    handleAddressCreated(event){
        let addrID = event.detail.id;
        this.modalOpen = false;
        refreshApex(this.wiredAddressesResult);
        this.selectedAddress = addrID;
        this.saveBillToAddress();
    }

}