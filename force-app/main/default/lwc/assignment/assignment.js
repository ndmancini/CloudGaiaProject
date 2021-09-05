import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getFreeResources from '@salesforce/apex/ProjectDataService.getFreeResources';
import getPendingRoles from '@salesforce/apex/ProjectDataService.getPendingRoles';
import assignResource from '@salesforce/apex/ProjectDataService.assignResource';

//fields del objeto Project__c
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
        this.listToAssign.push({ Resource__c: e.detail.id.substring(0, e.detail.id.length-4), ProjectsItem__c: e.detail.roleId, Start_Date__c: e.detail.startDate, End_Date__c: e.detail.endDate })
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

    assign() {
        assignResource({ newAllocatedResources: this.listToAssign })
        .then(() =>{
            getFreeResources({ startDate: this.startDate, endDate: this.endDate })
            .then(result => console.log(result))
            window.location.reload()
        })
    }
}