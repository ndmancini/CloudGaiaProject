import { LightningElement, api } from 'lwc';

export default class Resource extends LightningElement {
    @api id;
    @api name;
    @api roleId;
    @api startDate;
    @api endDate;
    selected = false;

    startDateChange(e) {
        e.preventDefault();
        this.startDate = e.target.value;    //si cambia el input de StartDate, cambiar variable local

        //si el recurso ya fue selectado, está despachado en assignment LWC, por lo que habrá que modificar la fecha
        if (this.selected) {
            const editResource = new CustomEvent('editresource',
                {
                    detail: { id: this.id, startDate: this.startDate, endDate: this.endDate },
                    bubbles: true, composed: true
                })
            this.dispatchEvent(editResource);
        }
    }

    endDateChange(e) {
        e.preventDefault();
        this.endDate = e.target.value;  //si cambia el input de EndDate, cambiar variable local

        //si el recurso ya fue selectado, está despachado en assignment LWC, por lo que habrá que modificar la fecha
        if (this.selected) {
            const editResource = new CustomEvent('editresource',
                {
                    detail: { id: this.id, startDate: this.startDate, endDate: this.endDate },
                    bubbles: true, composed: true
                })
            this.dispatchEvent(editResource);
        }
    }

    //si el checkbox fue seleccionado, despachar 'addresource' al assingment LWC
    //si el checkbox fue deseleccionado, despachar 'removeresource' al assignment LWC
    handleCheck(e) {
        e.preventDefault();
        if (!this.selected) {
            const addResource = new CustomEvent('addresource',
                {
                    detail: { id: this.id, name: this.name, roleId: this.roleId, startDate: this.startDate, endDate: this.endDate },
                    bubbles: true, composed: true
                })
            this.dispatchEvent(addResource);
        }
        else {
            const removeResource = new CustomEvent('removeresource',
                {
                    detail: { id: this.id },
                    bubbles: true, composed: true
                })
            this.dispatchEvent(removeResource);
        }
        this.selected = !this.selected;
    }
}

