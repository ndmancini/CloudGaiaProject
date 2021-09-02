import { LightningElement, api } from 'lwc';

export default class Resource extends LightningElement {
    @api id;
    @api name;
    @api roleId;
    selected = false;

    selectResource(e) {
        e.preventDefault();

        //despacha un evento custom a su abuelo 'assignment' con la información del recurso asignado
        const selectedResource = new CustomEvent('addresource', { detail: { id: this.id, name: this.name }, bubbles: true, composed: true })
        this.dispatchEvent(selectedResource);
    }

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

