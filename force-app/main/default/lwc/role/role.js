import { LightningElement, api } from 'lwc';

export default class Role extends LightningElement {
    
    @api roleName;
    @api resources;
    @api totalHours;
    @api coveredHours;

    @api roleId;
    @api startDate;
    @api endDate;
    
    freeResources;
    pendingHours;

    connectedCallback() {
        if (this.resources != null && this.roleName != null) {
            this.freeResources = this.resources[this.roleName];
            this.pendingHours = this.totalHours - this.coveredHours;
        }
    }
}