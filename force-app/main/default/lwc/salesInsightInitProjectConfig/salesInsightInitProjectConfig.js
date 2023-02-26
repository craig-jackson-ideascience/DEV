/**
LWC Controller for SalesInsight Project Configuration
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 23FEB2023  Craig Jackson  LF240-269   Initial Version
*/
// Salesforce Includes
import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Import Apex Worker Classes
import getConfiguredProjectLst from '@salesforce/apex/SalesInsightController.getConfiguredProjectLst';
import hasConfig from '@salesforce/apex/SalesInsightController.hasConfig';
import createSalesInsigtConfigForProject from '@salesforce/apex/SalesInsightController.createSalesInsigtConfigForProject';

export default class SalesInsightInitProjectConfig extends LightningElement {
    // Internal Variables
    cloneProjectId              = undefined;
    hasConfig                   = false;
    dataLoadCalled              = false;
    prjsWithConfig              = [];
    overwriteFlag               = false;
    // Tracked Variables
    @track hasConfigLoaded      = false;
    @track prjsWithConfigLoaded = false;
    @track showSpinner          = true;
    @track btnCreateDisabled    = false;
    @track btnCreateLabel       = "Create Default Configuration";
    @api recordId;

    //
    // Event Handlers
    //
    //
    // Standard Function Called When an Object is Rendered
    //
    renderedCallback() {
        // The first time we have the Record Id call the Apex Classes to Load Data
        if ((this.recordId != undefined) && (this.dataLoadCalled == false)) {
            // Check if the Project Already has a Configuration
            this.getHasConfig();

            // Get the list of Project Clone Options
            this.getPrjsWithConfig();

            // Make sure we only get the data once
            this.dataLoadCalled = true;
        }
    }

    //
    // Handle the Checkbox Being Ticked
    //
    handleCheckboxChange(event) {
        this.overwriteFlag = event.target.checked;
        if (this.overwriteFlag) {
            this.btnCreateDisabled = false;
        } else {
            this.btnCreateDisabled = true;
        }
    }

    //
    // Save the Selected Project To Clone 
    //
    handleProjectSelect(event) {
        this.cloneProjectId = event.detail.value;
        if (this.cloneProjectId == undefined) {
            this.btnCreateLabel = "Create Default Configuration";
        } else {
            this.btnCreateLabel = "Clone Configuration";
        }
    }

    //
    // Clone Button Selected
    //
    cloneProject() {
        // Show the Spinner while Config being created
        this.showSpinner = true;

        // Call the Apex Class createSalesInsigtConfigForProject
        createSalesInsigtConfigForProject(
            {projectId: this.recordId
            ,overwriteExistingConfig: this.overwriteFlag
            ,cloneFromProjectId: this.cloneProjectId})
            .then(result => {
                // Display Success Message
                this.ShowToast('success', 'Configuration Created', 'Sales Insight Configuration has been created for the Project.');

                // Close the Window
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                // Display Error Message
                this.ShowToast('error', 'System Error', 'Failed to Create Configuration: ' + error.body.message);
                console.log('getHasConfig: hasConfig has an error: ' + JSON.stringify(error.body));
            });
    }

    //
    // Close Buttone being Selected
    //
    closeAction() {
        // Close the Window
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    //
    // Helper Functions
    //
    //
    // Check if the Project has an existing Configuration
    //
    getHasConfig () {
        // Call the Apex class hasConfig
        hasConfig({projectId: this.recordId})
            .then(result => {

                // Handle the result
                this.hasConfig = result;

                // Disable button if Overwride Required
                if (this.hasConfig) {
                    this.btnCreateDisabled = true;
                }

                // Stop the Spinner if all data loaded
                this.hasConfigLoaded = true;
                this.StopSpinnerIfDataLoaded();
           })
            .catch(error => {

                // Stop the Spinner if all data loaded
                this.hasConfigLoaded = true;
                this.StopSpinnerIfDataLoaded();

                // Display and log the error
                this.ShowToast('error', 'System Error', 'Cannot check if Configuration Exists: ' + error.body.message);
                console.log('getPrjsWithConfig: hasConfig has an error: ' + JSON.stringify(error.body));
            });
    }

    //
    // Get the List of Projects To Clone
    //
    getPrjsWithConfig() {
        // Call the Apex class getConfiguredProjectLst
        getConfiguredProjectLst()
            .then(result => {

                // Load the Projects to Clone Options
                for (var i = 0; i<result.length; i++) {
                    // Do not try and clone the project being processed
                    if (this.recordId != result[i].Id) {
                        this.prjsWithConfig.push({value: result[i].Id,label: result[i].Name});
                    }
                };

                // Stop the Spinner if all data loaded
                this.prjsWithConfigLoaded = true;
                this.StopSpinnerIfDataLoaded();

            })
            .catch(error => {

                // Stop the Spinner if all data loaded
                this.prjsWithConfigLoaded = true;
                this.StopSpinnerIfDataLoaded();
                
                // Display and log the error
                this.ShowToast('error', 'System Error', 'Error Loading Dropdown: ' +  error.body.message);
                console.log('getPrjsWithConfig: hasConfig has an error: ' + JSON.stringify(error.body));
            });
    }

    //
    // Show Toast Message
    //
    ShowToast (variant, title, message) {
        // Make sure Spinner is off
        this.showSpinner = false;

        // Build Show Toast Event
        const toastEvnt = new ShowToastEvent({
            variant: variant,
            title:   title,
            message: message,
        });

        // Fire Event
        this.dispatchEvent(toastEvnt);

    }

    //
    // Stop the Spinner if we can
    //
    StopSpinnerIfDataLoaded() {
        if ((this.hasConfigLoaded == true) && (this.prjsWithConfigLoaded == true)) {
            this.showSpinner = false;
        }
    }
}