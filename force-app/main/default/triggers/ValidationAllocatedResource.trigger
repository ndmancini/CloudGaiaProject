trigger ValidationAllocatedResource on AllocatedResource__c (before insert) {
    ValidationAllocatedResourceTrigger.beforeInsert(Trigger.new);
}