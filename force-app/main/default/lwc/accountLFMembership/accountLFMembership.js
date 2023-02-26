import { LightningElement, api, track, wire } from 'lwc';
import getLFMembershipDetails from '@salesforce/apex/AccountLFMembershipController.getLFMembershipDetails';
import getAtRiskRenewals from '@salesforce/apex/AccountLFMembershipController.getAtRiskRenewals';
import getAccountRecord from '@salesforce/apex/AccountLFMembershipController.getAccountRecord';

export default class AccountLFMembership extends LightningElement {

    @api recordId;

    @track activeLFMember = false;
    @track lfMembershipSummary = '';
    @track lfStartOrEndSummary = '';
    @track StartegicAcount='';
    @track hasAtRiskOpps = false;
    @track isVisible = false;
    @track atRiskOpps = [];

    connectedCallback(){
        //get data for LF Membership section
        getLFMembershipDetails({accountID: this.recordId})
        .then(result => {
            if(result.length > 0){
                let status = result[0];
                let tier = result[1];
                let startYear = result[2];
                let endDate = result[3];
                this.writeLFSummaries(status, tier, startYear, endDate);
            }else{
                this.lfStartOrEndSummary = 'This account has never had a Linux Foundation membership.';
            }
        })
        .catch(error => {
            console.log('Error querying LF membership details');
            console.log(error);
        });
 
        //get StartegicAcount Data
        getAccountRecord({recordId: this.recordId})
        .then(result => {
            if(result != null){
                if(result.Strategic_Account__c){
                 this.isVisible = true;
                this.StartegicAcount ='Strategic';
                }
            }else{
            }
        })
        .catch(error => {
            console.log('Error querying LF membership details');
            console.log(error);
        });

        //get data for At-Risk Renewals section
        getAtRiskRenewals({accountID: this.recordId})
        .then(result => {
            if(result.length > 0){
                this.hasAtRiskOpps = true;
                let opps = [];
                for(let i=0; i<result.length; i++){
                    let opp = {};
                    opp.id = result[i].Id;
                    opp.name = result[i].Name;
                    opp.nameURL = '/' + result[i].Id;
                    opp.owner = result[i].Owner.FirstName + ' ' + result[i].Owner.LastName;
                    opp.closeDate = this.formatDate(result[i].CloseDate);
                    opp.amount = result[i].Amount;

                    //add two decimal places, comma, and $ to amount
                    opp.amount = Number.parseFloat(opp.amount).toFixed(2);
                    opp.amount = '$' + opp.amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");

                    //figure out at risk reason to show for this opp
                    let renewalLikelihood = result[i].Renewal_Likelihood__c;
                    if(result[i].Hold__c){
                        let holdReason = result[i].Hold_Reason__c;
                        let holdComment = result[i].Renewal_Hold_Comment__c;
                        if( !holdReason ){
                            opp.atRiskReason = 'On Hold';
                        }else if( holdReason.includes("Other") ){
                            if( holdComment ){
                                opp.atRiskReason = 'On Hold: ' + holdComment;
                            } else {
                                opp.atRiskReason = 'On Hold';
                            }
                        }else{
                            opp.atRiskReason = 'On Hold: ' + holdReason;
                        }
                    }else if(renewalLikelihood && renewalLikelihood.includes('At Risk')){
                        opp.atRiskReason = renewalLikelihood;
                    }else{
                        if(result[i].StageName == 'Stage 1'){
                            opp.atRiskReason = result[i].StageName;
                        }else{
                            opp.atRiskReason = 'Stage ' + result[i].StageName;
                        }
                    }

                    opps.push(opp);
                }
                this.atRiskOpps = opps;
            }
        })
        .catch(error => {
            console.log('Error querying at-risk renewal Opportunities');
            console.log(error);
        });
    }

    writeLFSummaries(status, tier, startYear, endDate){
        let tierName = tier.replace(" Membership", "");
        //handle Silver Membership - MPSF tier (treat it like normal Silver tier)
        if(tierName.includes("Silver")){
            tierName = "Silver";
        }
        
        if(status == 'Active' || status == 'Purchased'){
            this.lfMembershipSummary = tierName + ' Member of The Linux Foundation';
            this.lfStartOrEndSummary = 'LF member since ' + startYear;
            this.activeLFMember = true;
        }else if(status == 'Expired'){
            this.lfMembershipSummary = 'Former ' + tierName + ' Member of The Linux Foundation';
            this.lfStartOrEndSummary = 'LF membership ended ' + endDate;
        }
    }

    

    formatDate(dateString){
        let date = new Date(dateString);
        let month = date.getUTCMonth() + 1;
        return month + '/' + date.getUTCDate() + '/' + date.getUTCFullYear();
    }

}