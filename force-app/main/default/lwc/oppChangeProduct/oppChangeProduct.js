import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOptions from '@salesforce/apex/OppChangeProductController.getOptions';
import updateProducts from '@salesforce/apex/OppChangeProductController.updateProducts';

export default class OppChangeProduct extends LightningElement {

    @api recordId;
    @api message;
    @api hasProduct1 = false;
    @api hasProduct2 = false;
    @api options1 = [];
    @api options2 = [];
    @api optionsLabel1;
    @api optionsLabel2;
    @api value1 = null;
    @api value2 = null;
    @api isInitialized = false;
    @api hideSave = false;
    @api section = '';
    @api isLoaded = false;
    //apex call is intentionally not fired until the accordion toggle to prevent SOQL queries
    //in that class from running anytime anyone loads an Opp that has this LWC on the page
    handleAccordionToggle(){
        if(!this.isInitialized){
            this.section = 'accordionSection';            
            getOptions({oppID: this.recordId})
            .then(result => {
                if(result && result.length > 0){
                    //handle first product
                    if(result.length >= 1 && result[0].length > 0){
                        this.hasProduct1 = true;
                        this.optionsLabel1 = 'Change membership for ' + result[0][0].Project__r.Name + ' to:';
                        let options = this.prepOptions(result[0]);
                        this.options1 = options;
                    }
                    //handle second product
                    if(result.length > 1 && result[1].length > 0){
                        this.hasProduct2 = true;
                        this.optionsLabel2 = 'Change membership for ' + result[1][0].Project__r.Name + ' to:';
                        let options = this.prepOptions(result[1]);
                        this.options2 = options;
                    }
                }else{
                    this.message = "There's nothing to upgrade or downgrade at this time. Either no membership products have been selected, or the project for the membership product that is selected is the only option for that project.";
                    this.hideSave = true;
                }
                this.isInitialized = true;
            })
            .catch(error => {
                this.showToastMsg('error', '', 'An error has occurred. Please log a ticket with Sales Ops.', 0);
                console.log(error);
                this.hideSave = true;
            });
        }
    }

    prepOptions(prodDetailArray){
        let options = [];

        let defaultOption = {};
        defaultOption.label = "-- no change --";
        defaultOption.value = null;
        options.push(defaultOption);

        for(let i=0; i<prodDetailArray.length; i++){
            let pd = prodDetailArray[i];
            let label = pd.Products__r.Name;
            if(pd.Start_Tier__c != null){
                if(pd.End_Tier__c != null){
                    label += ' (' + pd.Start_Tier__c +  ' - ' + pd.End_Tier__c + ' employees)';
                }else{
                    label += ' (' + pd.Start_Tier__c + '+ employees)';
                }
            }

            let option = {};
            option.label = label;
            option.value = pd.Id;
            options.push(option);
        }
        return options;
    }

    handleChange1(event){
        this.value1 = event.detail.value;
        this.message = '';
        console.log(this.value1);
    }

    handleChange2(event){
        this.value2 = event.detail.value;
        this.message = '';
        console.log(this.value2);
    }

    handleSave(){
        if(this.value1 == null && this.value2 == null){
            this.showToastMsg('info', '', 'No changes have been made, so there\'s\ nothing to save at this time.', 0);
            return;
        }
        this.isLoaded = true;

        let selectedProdDetailIDs = [];
        if(this.value1 != null){
            selectedProdDetailIDs.push(this.value1);
        }
        if(this.value2 != null){
            selectedProdDetailIDs.push(this.value2);
        }

        updateProducts({oppID: this.recordId, selectedProdDetailIDs: selectedProdDetailIDs})
        .then(result => {
            this.showToastMsg('success', '', 'Success! The membership product(s) updated.', 1500);
            this.isInitialized = false;
            eval("$A.get('e.force:refreshView').fire();");
            this.isLoaded = false;
            this.handleCancel();
        })
        .catch(error => {
            this.showToastMsg('error', '', 'An error has occurred. Please log a ticket with Sales Ops.', 0);
            this.isLoaded = false;
            console.log(error);
        });
    }

    handleCancel(){
        this.value1 = null;
        this.value2 = null;
        const accordion = this.template.querySelector('.myAccordian');
        accordion.activeSectionName = '';
    }

    showToastMsg(type, title, message, delay){
        const event = new ShowToastEvent({
            title: title,
            variant: type,
            message: message,
        });
        setTimeout(function(){
            this.dispatchEvent(event);
        }, delay);
    }
}