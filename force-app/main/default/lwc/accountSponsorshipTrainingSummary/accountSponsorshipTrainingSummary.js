import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTrainingSponsorships from '@salesforce/apex/AccountSponsorshipSummaryController.getTrainingSponsorships';

const assetColumns = [
    //{ label: 'Purchase History Name', fieldName: 'nameURL', hideDefaultActions: true, type: 'url', typeAttributes: {label: {fieldName: 'Name'}, target: '_blank'}, cellAttributes: {wrapText: true} },
    { label: 'Training', fieldName: 'Training', hideDefaultActions: true, cellAttributes: {wrapText: true} },
    { label: 'Product', fieldName: 'Product', hideDefaultActions: true, initialWidth: 225, cellAttributes: {wrapText: true} },
    { label: 'Status', fieldName: 'Status', hideDefaultActions: true, initialWidth: 60, cellAttributes: {iconName: {fieldName: 'statusIcon' }, iconPosition: 'right'} },
    { label: 'Price', fieldName: 'Price', hideDefaultActions: true, type: 'currency', initialWidth: 100 },
    { label: 'Year', fieldName: 'Year', hideDefaultActions: true, initialWidth: 50, cellAttributes: {alignment: 'right'} },
    { label: 'Purchase History Link', fieldName: 'nameURL', hideDefaultActions: true, initialWidth: 150, type: 'url', typeAttributes: {label: {fieldName: 'openLink'}}, cellAttributes: {wrapText: true, alignment: 'right'} },
];

//TODO: add sorting (?)

export default class NavigationExampleLWC extends NavigationMixin(LightningElement) {
       
   
    @track tableData = [];
    tableDataUnfiltered = [];
    @track tableColumns = assetColumns;
    @track years = [];
    @api recordId;
    oldestYearShown = '';
    @track hasSponsorships = false;
    @track warning;
    @api newRecordId ;
		@track viewAllButton = false;
    
    filterTable(){
        //create array of year objects where the isSelected property is true
        let yearObjArray = this.years.filter(obj => {
            return obj.isSelected == true;
        })

        //from that array of year objects, create an array of strings only
        let yearLabelArray = yearObjArray.map(x => x.label);

        // filter by selected years
        let tableDataFiltered = [];
        for(let i=0; i<this.tableDataUnfiltered.length; i++){
            //compare Year for this row to all years selected individually
            if( yearLabelArray.includes(this.tableDataUnfiltered[i].Year) ){
                tableDataFiltered.push(this.tableDataUnfiltered[i]);

            //compare Year for this row to all "previous years," if the Previous Years button is selected
            }else if(yearLabelArray.includes('Previous Years') &&
                     parseInt(this.tableDataUnfiltered[i].Year) < parseInt(this.oldestYearShown) ){
                        tableDataFiltered.push(this.tableDataUnfiltered[i]);
            }
        }

        

        this.tableData = tableDataFiltered;

        console.log('this.projectLabel');
        console.log(this.projectLabel);
        console.log('yearLabelArray');
        console.log(yearLabelArray);
         
        //calculate and set warning
        if(this.tableData.length == 0){
           
            if(yearLabelArray.length == 0){
                this.warning = 'No years are currently selected. Try clicking the "Show All Years" button, above.';
            }else{
                //I can't think of a use case when this generic warning would be shown, but adding it as a backup just in case
                this.warning = "No sponsorships fit the current filters."
            }
        }else{
            this.warning = undefined;
        }
    }

    showAllYears(){
        for(let i=0; i<this.years.length; i++){
            this.years[i].isSelected = true;
        }
        this.filterTable();
    }
    
    connectedCallback(){
        //get data from Asset query
        getTrainingSponsorships({accountID: this.recordId,NewRecordId :this.newRecordId})
        .then(result => {
            let yearArray = [];
           
            for(let i=0; i<result.length; i++){
                this.hasSponsorships = true;
                 
                
                if( !(yearArray.find(x => x.value == result[i].Year__c)) ){
                    //filter out any undefined values
                    if(result[i].Year__c){
                        let currentYear = {};
                        currentYear.value = result[i].Year__c;
                        currentYear.label = result[i].Year__c;
                        currentYear.hideLabel = result[i].Year__c;
                        currentYear.isSelected = false;
                        yearArray.push(currentYear);
                    }
                }
            }
           

            //sort year array
            yearArray.sort((a,b) => (a.label > b.label) ? -1 : ((b.label > a.label) ? 1 : 0));
            //set the most recent year to be the only one selected by default
            yearArray[0].isSelected = true;

            //if there are more than 4 years in the yearArray, combine all except the last 3 into a "Previous Years" bucket
            if(yearArray.length > 4){
								
                this.oldestYearShown = yearArray[2].label;
                let numberOfYearsToRemove = yearArray.length - 3;
                for(let i=0; i<numberOfYearsToRemove; i++){
                    yearArray.pop();
                }
                yearArray.push({value: 'previous', label: 'Previous Years', hideLabel: 'Previous Years', isSelected: false});
            }

            //set the variable used to add buttons for each year to the year array
            this.years = yearArray;
						console.log('this.newRecordId-->'+this.newRecordId);
						
             if(result.length > 5 && this.newRecordId == null){
							this.viewAllButton = true;	 
						 }
						/*if(!this.newRecordId.includes('undefined')){
							this.viewAllButton = false;	 
						 }*/
            //populate table data
            let data = result.map(row => {
                let rowNameURL = `/${row.Id}`;
                let rowStatusIcon = ((row.Status == "Invoice Cancelled" || row.Status == "Associate Cancelled")  ? "utility:error" : "utility:check" );
                return{
                    nameURL: rowNameURL,
                    //Name: row.Name,
                    openLink: 'View Purchase History',
                    Price: row.Price,
                    Product: row.Product2.Name,
                    Status: '',
                    Training: row.Training__r.Name,
                    statusIcon: rowStatusIcon,
                    Year: row.Year__c,
                }
            })
            this.tableData = data;
            this.tableDataUnfiltered = data;
            //filter table so that only records for the year selected are shown
            this.filterTable();
        })
        .catch(error => {
										console.log('newRecordId--->'+this.newRecordId);

            console.log('Error querying Assets (Product Family == Event)');
        });
    }
		//Navigate to home page
		/*navigateToHomePage() {
                this[NavigationMixin.Navigate]({
						type: 'standard__navItemPage',
						attributes: {
								recordId: this.recordId,
								apiName: 'Training_Page'
						},
				});

        } */
        
        navigateToHomePage() {
					
            this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                            recordId: this.recordId,
                            "url": 'https://linuxfoundation.lightning.force.com/c/ViewAll.app?pageid='+this.recordId+'&type=training'
                    },
            }); 

    } 
		
   changeYearFilter(event){
        event.target.blur();
        let index = this.years.findIndex(x => x.label == event.target.labelWhenOn);
        this.years[index].isSelected = !(this.years[index].isSelected);
        this.filterTable();
    }

}