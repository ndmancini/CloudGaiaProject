import { LightningElement, api } from 'lwc';

export default class Role extends LightningElement {
    @api roleName;
    @api startDate;
    @api endDate;

    connectedCallback() {
        console.log(this.roleName, this.startDate, this.endDate);
    }
}