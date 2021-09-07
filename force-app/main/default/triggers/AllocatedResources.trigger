trigger AllocatedResources on AllocatedResource__c (before insert, after insert) {
	
    if (Trigger.isBefore) AllocatedResourcesTrigger.beforeInsert(Trigger.new);
    if (Trigger.isAfter) AllocatedResourcesTrigger.afterInsert(Trigger.new);
}