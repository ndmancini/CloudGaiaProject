public with sharing class updateStage {
    public updateStage() {
        List<Project__c> projectsInPreKickOff= [SELECT Id, Status__c FROM Project__c WHERE Status__c = 'Pre Kick-Off'];
        List<Project__c> updatedProjects= new List<Project__c>();
        
        for(Project__c project: projectsInPreKickOff){
            project.Status__c= 'Start';
            updatedProjects.add(project); 
        }
        update updatedProjects;
    }   
}
