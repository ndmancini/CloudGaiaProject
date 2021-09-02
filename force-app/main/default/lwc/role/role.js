import { LightningElement, wire, api } from 'lwc';
import getFreeResourcesByRole from '@salesforce/apex/ProjectDataService.getFreeResourcesByRole';

export default class Role extends LightningElement {
    @api roleName;
    @api startDate;
    @api endDate;
    freeResources = [];

    @wire(getFreeResourcesByRole, { startDate: '$startDate', endDate: '$endDate', role: '$roleName' })
    resources(result) {
        if (result.data && result.data.length > 0) {
            for (let i = 0; i < result.data.length; i++) {
                this.freeResources.push(result.data[i].Name);
            }
        }
        console.log(this.freeResources);
    }
}