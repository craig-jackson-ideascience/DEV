import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getCorporateMemberships from '@salesforce/apex/ProjectMemberSummaryController.getCorporateMemberships';
import getIndividualMemberships from '@salesforce/apex/ProjectMemberSummaryController.getIndividualMemberships';

import LFProjectID from '@salesforce/label/c.The_Linux_Foundation_Project';
import CorporateMembershipsReportID from '@salesforce/label/c.Project_Corporate_Memberships_Report_ID';
import IndividualMembershipsReportID from '@salesforce/label/c.Project_Individual_Memberships_Report_ID';

import LOGO_URL_FIELD from '@salesforce/schema/Project__c.Project_Logo__c';

const fields = [LOGO_URL_FIELD];

export default class ProjectLogo extends LightningElement {
    @api recordId;
    isInitialized = false;

    @track hasCorpMemberships = false;
    @track corpMembershipTiers = [];
    @track corpMemberCount = 0;
    @track corpReportURL = '';

    @track hasIndMemberships = false;
    @track indMembershipTiers = [];
    @track indMemberCount = 0;
    @track indReportURL = '';
    

    @wire(getRecord, { recordId: '$recordId', fields })
    proj;

    get logoURL(){
        return getFieldValue(this.proj.data, LOGO_URL_FIELD);
    }

    connectedCallback(){

        if(!this.isInitialized){
            getCorporateMemberships({projectID: this.recordId})
                .then((result) => {
                    if(result.length > 0){
                        this.hasCorpMemberships = true;
                    }

                    if(this.recordId == LFProjectID){
                        //process corporate membership tiers if this is LF
                        //(this is separated out from processing corporate tiers for other projects
                        // to combine Silver - MPSF memberships w/ regular Silver memberships)
                        this.processLFCorpMembershipTiers(result);

                    }else{
                        //process corporate membership tiers if this is any other project
                        this.corpMemberCount = this.processMembershipTiers(result, this.corpMembershipTiers);
                    }
                })
                .catch((error) => {
                    console.log('Error querying Membership records');
                });

            getIndividualMemberships({projectID: this.recordId})
                .then((result) => {
                    if(result.length > 0){
                        this.hasIndMemberships = true;
                    }
                    //process individual membership tiers
                    this.indMemberCount = this.processMembershipTiers(result, this.indMembershipTiers);
                })
                .catch((error) => {
                    console.log('Error querying Asset records of Individual record type');
                });

            this.isInitialized = true;

            //set URLs for 'View Details' reports
            this.corpReportURL = '/lightning/r/Report/' + CorporateMembershipsReportID +'/view?fv0=' + this.recordId;
            this.indReportURL = '/lightning/r/Report/' + IndividualMembershipsReportID + '/view?fv0=' + this.recordId;
        }
        
    }

    renderedCallback(){
        this.setHeight();
    }

    processMembershipTiers(result, membershipTierArray){
        let totalCount = 0;
        for(let i=0; i<result.length; i++){
            let name = result[i].Name;
            let count = result[i].expr0;

            totalCount = totalCount + count;
            
            //shorten name of tier
            name = name.replace(" Membership", "");
            name = name.replace(" Member", "");

            //format count with commas if > 999
            count = this.formatNumber(count);

            let tier = {};
            tier.Name = name;
            tier.Count = count;
            membershipTierArray.push(tier);
        }
        return this.formatNumber(totalCount);
    }

    processLFCorpMembershipTiers(result){
        let silverLFTier = {};
        silverLFTier.Name = "Silver";
        silverLFTier.Count = 0;

        for(let i=0; i<result.length; i++){
            let name = result[i].Name;
            let count = result[i].expr0;

            if(name.includes("Silver")){
                silverLFTier.Count = silverLFTier.Count + count;
                this.corpMemberCount = this.corpMemberCount + count;

            }else{
                //shorten name of tier
                name = name.replace(" Membership", "");
                name = name.replace(" Member", "");

                this.corpMemberCount = this.corpMemberCount + count;

                //format count with commas if > 999
                count = this.formatNumber(count);

                let tier = {};
                tier.Name = name;
                tier.Count = count;
                this.corpMembershipTiers.push(tier);
            }
        }
        //now push silver tier immediately after gold tier
        silverLFTier.Count = this.formatNumber(silverLFTier.Count);
        var indexOfGold = this.corpMembershipTiers.findIndex(i => i.Name == "Gold");
        this.corpMembershipTiers.splice(indexOfGold+1, 0, silverLFTier);

        //and format total member count with commas if > 999
        this.corpMemberCount = this.formatNumber(this.corpMemberCount);
    }

    formatNumber(num){
        //add commas to number if it's > 999
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    setHeight(){
        //get the 3 sections of this LWC
        let corpMemberContainer = this.getContainerByDataIds('corpMembContainer1', 'corpMembContainer2');
        let indMemberContainer = this.getContainerByDataIds('indMembContainer1', 'indMembContainer2');
        let logoContainer = this.getContainerByDataIds('logoContainer1', 'logoContainer2');

        //get the current height of each section
        let corpMemberHeight = corpMemberContainer.clientHeight;
        let indMemberHeight = indMemberContainer.clientHeight;
        let logoHeight = logoContainer.clientHeight;

        //calculate the height needed for the tallest membership section
        let membershipHeight = (indMemberHeight < corpMemberHeight) ? corpMemberHeight : indMemberHeight;

        //calculate the max height of all 3 sections
        let maxHeight = (logoHeight > membershipHeight) ? logoHeight :  membershipHeight;

        //calculate the desired height of this LWC
        let hasLogo = (getFieldValue(this.proj.data, LOGO_URL_FIELD) == null) ? false : true;
        let hasMembership = (this.hasCorpMemberships || this.hasIndMemberships);
        let lwcHeight = 0;
        if((hasLogo && !hasMembership) ||
           (hasLogo && hasMembership && logoHeight > membershipHeight)){
            lwcHeight = 140;
        }else{
            lwcHeight = maxHeight;
        }

        //set the height of all 3 sections to single desired height
        let heightString = lwcHeight.toString() + 'px';
        corpMemberContainer.style.height = heightString;
        indMemberContainer.style.height = heightString;
        logoContainer.style.height = heightString;
    }

    getContainerByDataIds(containerName1, containerName2){
        let container = this.template.querySelector('[data-id="' + containerName1 + '"]');
        if(!container){
            container = this.template.querySelector('[data-id="' + containerName2 + '"]');
        }
        return container;
    }

}