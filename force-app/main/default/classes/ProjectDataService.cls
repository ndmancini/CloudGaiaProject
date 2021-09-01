public with sharing class ProjectDataService {

	@AuraEnabled(Cacheable=true)
	public static List<AllocatedResource__c> getAllocatedResources(Id projectId) {
        return [SELECT Id, Start_Date__c, End_Date__c,
                Resource__r.Name,
                ProjectsItem__r.Role__c
                FROM AllocatedResource__c
                WHERE ProjectsItem__r.Project__c = :projectId];
    }
}