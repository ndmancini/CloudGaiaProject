trigger Opportunities on Opportunity (before update) {
    OpportunitiesTrigger.beforeUpdate(Trigger.newMap, Trigger.oldMap);
}