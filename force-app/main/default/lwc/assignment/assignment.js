import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getFreeResources from '@salesforce/apex/ProjectDataService.getFreeResources';
import getPendingRoles from '@salesforce/apex/ProjectDataService.getPendingRoles';
import assignResource from '@salesforce/apex/ProjectDataService.assignResource';

//fields del objeto Project__c
import START_DATE_FIELD from '@salesforce/schema/Project__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/Project__c.End_Date__c';

export default class Assignment extends LightningElement {

    @api recordId;          //recordId del proyecto seleccionado
    listToAssign = [];      //arreglo de resources selectados para ser asignados
    freeResources;          //recursos libres que vienen de la DB
    pendingRoles;           //roles pendientes que vienen de la DB
    startDate;              //comienzo del proyecto
    endDate;                //fin del proyecto

    //traemos fechas del proyecto
    @wire(getRecord, { recordId: '$recordId', fields: [START_DATE_FIELD, END_DATE_FIELD] })
    loadDates(result) {
        this.startDate = getFieldValue(result.data, START_DATE_FIELD);
        this.endDate = getFieldValue(result.data, END_DATE_FIELD);
    }

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        getPendingRoles({ projectId: this.recordId })
        .then(pendingRoles => {
            this.pendingRoles = pendingRoles;
            let roles = pendingRoles.map(item => item.Role__c);
            getFreeResources({ roles })
            .then(freeResources => this.freeResources = freeResources)
        })
    }

    //ataja el customEvent 'addresource' desde Resource LWC
    handleAdd(e) {
        this.listToAssign.push({ Resource__c: e.detail.id.substring(0, e.detail.id.length-4), ProjectsItem__c: e.detail.roleId, Start_Date__c: e.detail.startDate, End_Date__c: e.detail.endDate })
        console.log(this.listToAssign);
    }

    //ataja el customEvent 'removeresource' desde Resource LWC
    handleRemove(e) {
        for (let i = 0; i < this.listToAssign.length; i++) {
            if (this.listToAssign[i].Resource__c == e.detail.id.substring(0, e.detail.id.length-4)) {
                this.listToAssign.splice(i, 1);
                break;
            }
        }
        console.log(this.listToAssign);
    }

    //ataja el customEvent 'editresource' desde Resource LWC
    handleEdit(e) {
        this.listToAssign.forEach(item => {
            if (item.Resource__c == e.detail.id.substring(0, e.detail.id.length-4)) {
                item.Start_Date__c = e.detail.startDate;
                item.End_Date__c = e.detail.endDate;
            }
        });
        console.log(this.listToAssign);
    }

    //guarda la lista listToAssign en la DB
    assign() {
        assignResource({ newAllocatedResources: this.listToAssign })
        .then(() =>{
            
            window.location.reload();
        })
    }

    @api async refresh() {
        await refreshApex(this.loadData());
    }
}