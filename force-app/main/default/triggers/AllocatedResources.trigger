trigger AllocatedResources on AllocatedResource__c (before insert) {
	AllocatedResourcesTrigger.beforeInsert(Trigger.newMap);
}