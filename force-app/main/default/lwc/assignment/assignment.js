import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getPendingRoles from '@salesforce/apex/ProjectDataService.getPendingRoles';
import assignResource from '@salesforce/apex/ProjectDataService.assignResource';

//fields del objeto Project__c
import START_DATE_FIELD from '@salesforce/schema/Project__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/Project__c.End_Date__c';

//fields del objeto AllocatedResource__c
import ALLOCATED_RESOURCE_OBJECT from '@salesforce/schema/AllocatedResource__c';
import RESOURCE_FIELD from '@salesforce/schema/AllocatedResource__c.Resource__c';
import PROJECT_ITEM_FIELD from '@salesforce/schema/AllocatedResource__c.ProjectsItem__c';
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
        this.listToAssign.push({ userId: e.detail.id, projectItemId: e.detail.roleId })
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
        let Resource__c = RESOURCE_FIELD;
        let ProjectsItem__c = PROJECT_ITEM_FIELD;
        let rec = { Resource__c, ProjectsItem__c };

        rec.Resource__c = '0055f000000unFVAAY';
        rec.ProjectsItem__c = 'a025f000001bXIBAA2';
        
        console.log(rec);

        assignResource({ newAllocatedResource: rec })
        .then(() => console.log('al demonio'))
    }
}