trigger AllocatedResource on AllocatedResource__c (before insert, after insert) {
	
    if (Trigger.isBefore) AllocatedResourceTrigger.beforeInsert(Trigger.new);
    if (Trigger.isAfter) AllocatedResourceTrigger.afterInsert(Trigger.new);
}