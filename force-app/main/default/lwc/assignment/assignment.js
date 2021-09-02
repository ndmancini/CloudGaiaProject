import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getPendingRoles from '@salesforce/apex/ProjectDataService.getPendingRoles';
import getFreeResources from '@salesforce/apex/ProjectDataService.getFreeResources';
import START_DATE_FIELD from '@salesforce/schema/Project__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/Project__c.End_Date__c';

export default class Assignment extends LightningElement {

    @api recordId;
    roles;
    startDate;
    endDate;
    freeResources;

    @wire(getRecord, { recordId: '$recordId', fields: [START_DATE_FIELD, END_DATE_FIELD] })
    loadDates(result) {
        this.startDate = getFieldValue(result.data, START_DATE_FIELD);
        this.endDate = getFieldValue(result.data, END_DATE_FIELD);
    }

    @wire(getPendingRoles, { projectId: '$recordId' })
    pendindRoles(result) {
        this.roles = result;
    }

    @wire(getFreeResources, { startDate: '$startDate', endDate: '$endDate' })
    resources(result) {
        this.freeResources = result;
    }

}