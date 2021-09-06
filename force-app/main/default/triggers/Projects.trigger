trigger Projects on Project__c (before update) {
	ProjectsTrigger.beforeUpdate(Trigger.newMap, Trigger.oldMap);
}