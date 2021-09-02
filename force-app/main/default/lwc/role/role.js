import { LightningElement, wire, api } from 'lwc';
import getFreeResourcesByRole from '@salesforce/apex/ProjectDataService.getFreeResourcesByRole';

export default class Role extends LightningElement {
    @api roleId;
    @api roleName;
    @api startDate;
    @api endDate;
    @api totalHours;
    @api coveredHours;
    freeResources;
    pendingHours;

    @wire(getFreeResourcesByRole, { startDate: '$startDate', endDate: '$endDate', role: '$roleName' })
    resources(result) {
        let resources = [];
        if (result.data && result.data.length > 0) {
            for (let i = 0; i < result.data.length; i++) {
                resources.push({Id: result.data[i].Id, Name: result.data[i].Name});
            }
        }
        this.freeResources = resources;
        this.pendingHours = this.totalHours - this.coveredHours;
    }
}