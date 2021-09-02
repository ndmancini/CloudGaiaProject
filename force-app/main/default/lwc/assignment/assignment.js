import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getPendingRoles from '@salesforce/apex/ProjectDataService.getPendingRoles';
import START_DATE_FIELD from '@salesforce/schema/Project__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/Project__c.End_Date__c';

export default class Assignment extends LightningElement {

    @api recordId;
    listToAssign = [];
    roles;
    startDate;
    endDate;

    @wire(getRecord, { recordId: '$recordId', fields: [START_DATE_FIELD, END_DATE_FIELD] })
    loadDates(result) {
        this.startDate = getFieldValue(result.data, START_DATE_FIELD);
        this.endDate = getFieldValue(result.data, END_DATE_FIELD);
    }

    @wire(getPendingRoles, { projectId: '$recordId' })
    pendindRoles(result) {
        this.roles = result;
    }

    handleAdd(e) {
        this.listToAssign.push({ userId: e.detail.id, projectItemId: e.detail.roleId })
        //console.log(this.listToAssign);
    }

    handleRemove(e) {
        for (let i = 0; i < this.listToAssign.length; i++) {
            if (this.listToAssign[i].userId == e.detail.id) {
                this.listToAssign.splice(i, 1);
                break;
            }
        }
        //console.log(this.listToAssign);
    }
}