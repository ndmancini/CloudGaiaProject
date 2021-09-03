import { LightningElement, api } from 'lwc';

export default class Resource extends LightningElement {
    @api id;
    @api name;
    @api roleId;
    @api startDate;
    @api endDate;
    selected = false;

    handleCheck(e) {
        e.preventDefault();
        if (!this.selected) {
            this.selected = true;
            const addResource = new CustomEvent('addresource', { detail: { id: this.id, name: this.name, roleId: this.roleId }, bubbles: true, composed: true })
            this.dispatchEvent(addResource);
        }
        else {
            this.selected = false;
            const removeResource = new CustomEvent('removeresource', { detail: { id: this.id }, bubbles: true, composed: true })
            this.dispatchEvent(removeResource);
        }
    }
}

