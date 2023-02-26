import { LightningElement, api, track } from 'lwc';
import { updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetails from '@salesforce/apex/OppJoinNowVerificationController.getDetails';
//import getCorrectProductDetails from '@salesforce/apex/OppJoinNowVerificationController.getCorrectProductDetails';
import makeUpdates from '@salesforce/apex/OppJoinNowVerificationController.makeUpdates';

export default class OppJoinNowVerification extends LightningElement {

    @api recordId;
 
    @track employeesNeedsVerified = false;
    @track typeNeedsVerified = false;
    @track productNeedsVerified = false;
    @track lwcSpinner = false;
    @track accountName;
    @track employeesOnAccount;
    @track joinNowEmployees;
    @track typeOnAccount;
    @track typeSubmitted;
    @track employeesSubmitted;
    @track StartTier;
    @track EndTier;

    @track heading = '';
    @track employeesInstruction = '';
    @track typeInstruction = '';
    @track productInstruction = '';

    //one variable for each line, since LWC doesn't seem to support passing line breaks in JS strings at this time
    @track message1 = null;
    @track message2 = null;
    @track message3 = null;
    @track message4 = null;

    @api employeesChoices = [];    
    @api employeesChoice = null;
    @api productsChoices = [];
    @api productsChoice = null;
    @api typeChoices = [];
    @api typeChoice = null;

    productDetailResult = [];

    connectedCallback(){
        getDetails({oppID: this.recordId})
        .then(result => {
            if(result.length > 0){
                //convert string to boolean for employeesNeedsVerified
                console.log('result[0].toLowerCase()-->'+result[0].toLowerCase());
                if(result[0].toLowerCase() == 'true'){
                    this.employeesNeedsVerified = true;
                }
                
                //convert string to boolean for typeNeedsVerified
                if(result[1].toLowerCase() == 'true'){
                    this.typeNeedsVerified = true;
                }

                //convert string to boolean for productNeedsVerified
                if(result[2].toLowerCase() == 'true'){
                    this.productNeedsVerified = true;
                }

                this.accountName = result[3];
                this.joinNowEmployees = result[4];
                this.employeesOnAccount = result[5];
                console.log("result 4: " + JSON.stringify(result));
                

                //set typeOnAccount more generically than the specific value on Account
                if(result[6] == 'private' || result[6] == 'public'){
                    this.typeOnAccount = 'commercial';
                }else{
                    this.typeOnAccount = result[6];
                }
                
                this.typeSubmitted = result[7];
                this.employeesSubmitted = result[8];

                this.StartTier = result[9];
                this.EndTier = result[10];

                this.setHeading();

                if(this.employeesNeedsVerified){
                    this.prepEmployeesOptions();                    
                }

                if (this.productNeedsVerified) {
                    this.prepProductInstruction();
                }
    
                if(this.typeNeedsVerified){
                    this.prepTypeOptions();
                }
            }else{
                console.log('Error querying Opportunity or Opportunity Line Item');
            }

        })
        .catch(error => {
            console.log('Error querying Opportunity or Opportunity Line Item');
            console.log(error);
        });

    }

    setHeading(){
        if( this.employeesNeedsVerified ){
            this.heading = 'Validate JoinNow Employee Count';
        }

        /*if( this.typeNeedsVerified ){
            if (this.heading.length > 0 ) {
                this.heading = this.heading + '/ Validate JoinNow Employee Count';
            } else {
                this.heading = 'Validate JoinNow Employee Count';
            }           
        }*/
        
        if( this.productNeedsVerified ){
            if (this.heading.length > 0 ) {
                this.heading = this.heading + '/Validate Product Tier';
            } else {
                this.heading = 'Validate Product Tier';
            }           
        }        
    }

    prepEmployeesOptions(){
        //add if statement to set data up like this only when there actually is a number on Account
        //also verify in if statement that Join Now number is less than Account number
        this.employeesInstruction = "JoinNow Employee Count is " + this.joinNowEmployees + ". Clearbit has " + this.employeesOnAccount;
        this.employeesInstruction += " If you Agree, this may result in replacing product tier." ;
        

        let option1 = {value: 'useJoinNowValue', label: "Agree, " + this.accountName + " JoinNow employee count is correct." };
        let option2 = {value: 'useAccountValue', label: "Disagree, with " + this.accountName + " JoinNow employee count, keep Clearbit #, please update Product Tier."  };

        //let option1 = {value: 'useJoinNo  wValue', label: 'The employee count from Join Now (' + this.employeesSubmitted + ') is correct.'};
        //let option2 = {value: 'useAccountValue', label: 'The employee count from Join Now (' + this.employeesSubmitted + ") is wrong.  Use the count we had (" + this.employeesOnAccount + ') instead.'};

        let tempArray = [];
        tempArray.push(option1);
        tempArray.push(option2);
        this.employeesChoices = tempArray;
    }

    prepTypeOptions(){
        this.typeInstruction =  this.accountName + " indicated their company type is '" + this.typeSubmitted;
        this.typeInstruction += "' in Join Now, which doesn't match the company type we had for them.";
        this.typeInstruction += ' Please verify the company type submitted and choose from the following:';
        
        let option1 = {value: 'useJoinNowValue', label: 'The company type from Join Now (' + this.typeSubmitted + ') is correct.'};
        let option2 = {value: 'useAccountValue', label: 'The company type from Join Now (' + this.typeSubmitted + ") is wrong.  Use the type we had (" + this.typeOnAccount + ') instead.'};

        let tempArray = [];
        tempArray.push(option1);
        tempArray.push(option2);
        this.typeChoices = tempArray;
    }

    prepProductInstruction(){ 

        this.productInstruction =  "Product Tier is " + this.StartTier + '-' + this.EndTier + ". Clearbit employee count is " + this.employeesOnAccount ; //insert Product Start and End Tier number here.                
        let option1 = {value: 'useClearbitValue', label: "AGREE with Clearbit employee count, please change product tier and price." };
        let option2 = {value: 'useProductValue', label: "Disagree, Leave current products with no change."  };       

        let tempArray = [];
        tempArray.push(option1);
        tempArray.push(option2);
        this.productsChoices = tempArray;
    }

    handleEmployeeSelection(event){
        this.employeesChoice = event.detail.value;
        console.log('event.detail.value-->'+event.detail.value);
        console.log('employeesChoice-->'+this.employeesChoice);
        //this.getOppProductMessage();
    }

    handleProductSelection(event){
        this.productsChoice = event.detail.value;
        console.log('event.detail.value-->'+event.detail.value);
        console.log('productsChoice-->'+this.productsChoice);
        //this.getOppProductMessage();
    }

    handleTypeSelection(event){
        this.typeChoice = event.detail.value;
        
        //this.getOppProductMessage();
    }
    /*
    getOppProductMessage(){
        //don't proceed until a value has been chosen for all picklists on the screen
        if( (this.employeesNeedsVerified && this.employeesChoice == null) || (this.typeNeedsVerified && this.typeChoice == null) ){
            return;
        }

       getCorrectProductDetails({oppID: this.recordId, employeesChoice: this.employeesChoice, typeChoice: this.typeChoice})
        .then(result => {
            this.productDetailResult = result;
            if(result.length > 0 && result[0] != 'error'){
                if(result[0] == 'no change'){
                    this.setMessage('No products on this opportunity will change.');
                }else{
                    this.setMessage(result[0]);
                }
            }else{
                this.setErrorMessage();
                console.log('Error choosing correct Product Details');
            }
        })
        .catch(error => {
            this.setErrorMessage();
            console.log('Error choosing correct Product Details');
            console.log(error);
        });
    }
    */

    setMessage(productDetailsMessage){
        this.clearMessages();
        this.message1 = "Got it. When you click Save, here's what will happen:";
        this.message2 = " • " + productDetailsMessage;

        //set message if both employees and type needed verification
        if(this.employeesNeedsVerified && this.typeNeedsVerified){
            //set message3 if Employees field on Account will be updated
            if(this.employeesChoice == 'useJoinNowValue'){
                this.message3 = " • The Employees field on the " + this.accountName + " account will be updated to " + this.employeesSubmitted + ".";
            }

            //set message4 if Company Type field on Account will be updated
            if(this.typeChoice == 'useJoinNowValue'){
                this.message4 = " • The Company Type field on the " + this.accountName + " account will be updated to " + this.typeSubmitted + ".";
            }

        //set message if only employees needed verification
        }else if(this.employeesNeedsVerified){
            if(this.employeesChoice == 'useJoinNowValue'){
                this.message3 = " • The Employees field on the " + this.accountName + " account will be updated to " + this.employeesSubmitted + ".";
            }

        //set message if only type needed verification
        }else if(this.typeNeedsVerified){
            if(this.typeChoice == 'useJoinNowValue'){
                this.message3 = " • The Company Type field on the " + this.accountName + " account will be updated to " + this.typeSubmitted + ".";
            }

        //error catch
        }else{
            this.setErrorMessage();
            return;
        }
    }

    setErrorMessage(){
        this.clearMessages();
        this.message1 = "Sorry, an error has occurred. Please contact Sales Ops.";
    }

    handleCancel(){
        this.employeesChoice = null;
        this.productsChoice = null;
        this.typeChoice = null;
        this.clearMessages();
    }

    clearMessages(){
        this.message1 = null;
        this.message2 = null;
        this.message3 = null;
        this.message4 = null;
    }

    handleSave(){
        //don't allow save until a value has been chosen for all picklists on the screen
        if( this.employeesNeedsVerified && this.typeNeedsVerified && (this.employeesChoice == null || this.typeChoice == null) ){
            this.message1 = "Please make all selections above first.";
            return;
        }else if( (this.employeesNeedsVerified && this.employeesChoice == null) || (this.typeNeedsVerified && this.typeChoice == null) || (this.productNeedsVerified && this.productsChoice == null)){
            this.message1 = "Please make your selection above first.";
            return;
        }
        this.lwcSpinner = true;
        
        let parameters = {oppID: this.recordId,                          
                          employeesChoice: this.employeesChoice,
                          productsChoice: this.productsChoice,
                          typeChoice: this.typeChoice,                          
                          typeSubmitted: this.typeSubmitted,
                         }
        makeUpdates(parameters)
        .then(result => {
            if(result == true){
                this.clearMessages();
                this.message1 = "Success! Verification is now complete.";
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: this.message1,
                    variant: 'success',
                });
                this.lwcSpinner = false;
                // Notify LDS that you've changed the record outside its mechanisms.
                getRecordNotifyChange([{recordId: this.recordId}]);                
                this.dispatchEvent(evt);
            }else{
                this.setErrorMessage();
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: this.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.lwcSpinner = false;
                console.log('Error making updates to Account and/or Opportunity');
            }
        })
        .catch(error => {
            
            this.setErrorMessage();
            this.lwcSpinner = false;
            console.log('Error making updates to Account and/or Opportunity');
            console.log(error);
        });
    }









    // setMessage(productDetailsMessage){
    //     this.message1 = "Got it. When you click Save, here's what will happen:";

    //     //set message if both employees and type needed verification
    //     if(this.employeesNeedsVerified && this.typeNeedsVerified){
    //         //set message2 with what will happen to Opportunity Product(s)
    //         if(this.employeesChoice == 'useAccountValue' && this.typeChoice == 'useAccountValue'){
    //             this.message2 = " • The product(s) on this Opportunity MIGHT change, depending on whether or not the higher number we already had happens to fall in the same tier as the lower number submitted through Join Now AND ";
    //             this.message2 += "depending on whether or not company type matters for the products on this Opportunity."
    //         }else if(this.employeesChoice == 'useAccountValue' && this.typeChoice == 'useJoinNowValue'){
    //             this.message2 = " • The product(s) on this Opportunity MIGHT change, depending on whether or not the higher number we already had happens to fall in the same tier as the lower number submitted through Join Now."
    //         }else if(this.employeesChoice == 'useJoinNowValue' && this.typeChoice == 'useAccountValue'){
    //             this.message2 = " • The product(s) on this Opportunity MIGHT change, depending on whether or not company type matters for the products on this Opportunity."
    //         }else if(this.employeesChoice == 'useJoinNowValue' && this.typeChoice == 'useJoinNowValue'){
    //             this.message2 = " • The product(s) on this Opportunity WON'T change, since the tier and price have already been set based on the employee count and company type provided by the customer.";
    //         }else{
    //             this.setErrorMessage();
    //             return;
    //         }

    //         //set message3 if Employees field on Account will be updated
    //         if(this.employeesChoice == 'useJoinNowValue'){
    //             this.message3 = " • The Employees field on the " + this.accountName + " account will be updated to " + this.employeesSubmitted + ".";
    //         }else{
    //             this.message3 = null;
    //         }

    //         //set message4 if Company Type field on Account will be updated
    //         if(this.typeChoice == 'useJoinNowValue'){
    //             this.message4 = " • The Company Type field on the " + this.accountName + " account will be updated to " + this.typeSubmitted + ".";
    //         }else{
    //             this.message4 = null;
    //         }

    //     //set message if only employees needed verification
    //     }else if(this.employeesNeedsVerified){
    //         if(this.employeesChoice == 'useJoinNowValue'){
    //             this.message2 = " • The product(s) on this Opportunity WON'T change, since the tier and price have already been set based on the employee count provided by the customer.";
    //             this.message3 = " • The Employees field on the " + this.accountName + " account will be updated to " + this.employeesSubmitted + ".";

    //         }else if(this.employeesChoice == 'useAccountValue'){
    //             this.message2 = " • The product(s) on this Opportunity MIGHT change, depending on whether or not the higher number we already had happens to fall in the same tier as the lower number submitted through Join Now."
    //             this.message3 = null;

    //         }else{
    //             this.setErrorMessage();
    //             return;
    //         }

    //     //set message if only type needed verification
    //     }else if(this.typeNeedsVerified){
    //         if(this.typeChoice == 'useJoinNowValue'){
    //             this.message2 = " • The product(s) on this Opportunity WON'T change, since the tier and price have already been set based on the company type provided by the customer.";
    //             this.message3 = " • The Company Type field on the " + this.accountName + " account will be updated to " + this.typeSubmitted + ".";

    //         }else if(this.typeChoice == 'useAccountValue'){
    //             this.message2 = " • The product(s) on this Opportunity MIGHT change, depending on whether or not company type matters for the products on this Opportunity."
    //             this.message3 = null;
                
    //         }else{
    //             this.setErrorMessage();
    //             return;
    //         }

    //     //error catch
    //     }else{
    //         this.setErrorMessage();
    //         return;
    //     }
    // }

}