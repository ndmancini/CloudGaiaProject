public with sharing class ProjectsTrigger {

    public static void beforeUpdate(Map<Id, Project__c> newProjectsById, Map<Id, Project__c> oldProjectsById) {

        //Tomamos los mapas de projects recibidos por parámetro
        //y nos quedamos sólo con aquellos cuyo Status cambió a 'Started'
        Set<Id> startedProjects = new Set<Id>();
        for (Project__c project : newProjectsById.values()) {
            if (project.Status__c == 'Start' && oldProjectsById.get(project.Id).Status__c != 'Start') {
            	startedProjects.add(project.Id);
            }
        }

        //traemos la lista de projectItems pertenecientes a los projects que pasaron a started
        List<ProjectLineItem__c> projectItems = [SELECT Id, Covered__c, Project__c, Project__r.Project_Manager__r.Email FROM ProjectLineItem__c
                                                 WHERE Project__c IN :startedProjects];

    	//Creamos un map donde key=projectId, value=lista de projectItems correspondientes
    	Map<Id, List<ProjectLineItem__c>> itemsByProjectId = new Map<Id, List<ProjectLineItem__c>>();

        //se completa el map
        for (ProjectLineItem__c item : projectItems) {
            if (!itemsByProjectId.containsKey(item.Project__c)) {
                itemsByProjectId.put(item.Project__c, new List<ProjectLineItem__c>{item});
            }
            else itemsByProjectId.get(item.Project__c).add(item);
        }
        
        //recorremos los items de cada project y buscamos que TODOS tengan su campo covered__c = true
        for (Id projectId : startedProjects) {
            Boolean fail = false;
            String email = itemsByProjectId.get(ProjectId)[0].Project__r.Project_Manager__r.Email;
            
            //fail si algún item NO está cubierto
            for (ProjectLineItem__c projectItem : itemsByProjectId.get(projectId)) {
                if (!projectItem.Covered__c) fail = true;
            	break;
            }
            if (fail) newProjectsById.get(projectId).addError('Project unable to be updated to Start status');
            
            //fail si falta SquadLead
            if (oldProjectsById.get(projectId).Squad_Lead__c == null) newProjectsById.get(projectId).addError('Project unable to be updated to Start status');

        }
    }
}