import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, createRecord } from 'lightning/uiRecordApi';
import getPendingRoles from '@salesforce/apex/ProjectDataService.getPendingRoles';
import assignResource from '@salesforce/apex/ProjectDataService.assignResource';

//fields del objeto Project__c
import START_DATE_FIELD from '@salesforce/schema/Project__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/Project__c.End_Date__c';

//fields del objeto AllocatedResource__c
import ALLOCATED_RESOURCE from '@salesforce/schema/AllocatedResource__c';
import RESOURCE from '@salesforce/schema/AllocatedResource__c.Resource__c';
import PROJECT_ITEM from '@salesforce/schema/AllocatedResource__c.ProjectsItem__c';
import START_DATE from '@salesforce/schema/AllocatedResource__c.Start_Date__c';
import END_DATE from '@salesforce/schema/AllocatedResource__c.End_Date__c';

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
        this.listToAssign.push({ userId: e.detail.id.substring(0, e.detail.id.length-4), projectItemId: e.detail.roleId })
        console.log(this.listToAssign);
    }

    handleRemove(e) {
        for (let i = 0; i < this.listToAssign.length; i++) {
            if (this.listToAssign[i].userId == e.detail.id) {
                this.listToAssign.splice(i, 1);
                break;
            }
        }
        console.log(this.listToAssign);
    }

    assign() {

        this.listToAssign.forEach(item => {

            const fields = {};
            fields[RESOURCE.fieldApiName] = item.userId;
            fields[PROJECT_ITEM.fieldApiName] = item.projectItemId;
            fields[START_DATE.fieldApiName] = this.startDate;
            fields[END_DATE.fieldApiName] = this.endDate;

            const recordInput = { apiName: ALLOCATED_RESOURCE.objectApiName, fields}

            createRecord(recordInput)
            .then(() => console.log('listo'))

        });

        /*const fields = {};
        fields[RESOURCE.fieldApiName] = '0055f000000unFzAAI';
        fields[PROJECT_ITEM.fieldApiName] = 'a025f000001bXIAAA2';
        const recordInput = { Resource__c: '0055f000000unG4AAI', ProjectsItem__c: 'a025f000001bXIAAA2' }

        let arrToAsign = [];
        arrToAsign.push(recordInput);
        assignResource(arrToAsign);*/
    }
}