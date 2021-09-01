import { LightningElement, api } from 'lwc';

export default class Assignment extends LightningElement {
    
    @api recordId;

    connectedCallback() {
        console.log(this.recordId);
    }
    
}