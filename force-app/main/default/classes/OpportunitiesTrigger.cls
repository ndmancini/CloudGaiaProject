public with sharing class OpportunitiesTrigger {
    
    public static void beforeUpdate(Map<Id, Opportunity> newOppsById, Map<Id, Opportunity> oldOppsById) {
        
        //Tomamos los mapas de opportunities recibidos por parámetro
        // y nos quedamos sólo con aquellos cuyo Stage pasó de 'Negotiation-Review' a 'Closed-Won'
        Set<Id> closedOpps = new Set<Id>();
        for (Opportunity opp : newOppsById.values()) {
            if (opp.Stage == 'Closed-Won') {
                if (oldInvoicesById.get(opp.Id).Stage == 'Negotiation-Review') {
                    closedOpps.add(opp.Id);
                }
            }
        }

        //Buscamos los items de dichas opportunities que se han cerrado
        List<OpportunityListItem__c> oppsItemsList = [SELECT Quantity__c, Role 
                                                     Opportunity__r.StartDate__c, Opportunity__r.EndDate__c, Opportunity__r.Account.Id, Opportunity__r.PM__c
                                                     FROM OpportunityListItem__c WHERE Opportunity__c IN :closedOpps];

        //creamos un map donde key=opportunityId, value=List<OpportunityListItem__c>>
        Map<Id, List<OpportunityListItem__c>> oppsItemsByOppId = new Map<Id, List<OpportunityListItem__c>>();  

        //completa el Map
        for (OpportunityListItem__c item : oppsItemsList) {
            if (!oppsItemsByOppId.containsKey(item.Opportunity__c)) {
                oppsItemsByOppId.put(item.Opportunity__c, new List<InvOpportunityListItem__coiceDetail__c>{item});
            }
            else {
                oppsItemsByOppId.get(item.Opportunity__c).add(item);
            }
        }

        //ahora recorremos el Map y creamos un nuevo Project__c
        List<Project__c> newProjectsList = new List<Project__c>();
        List<ProjectItem__c> newProjectItemsList = new List<ProjectItem__c>();
                
        for (Id oppId : oppsItemsByOppId.keySet()) {
            Project__c newProject = new Project__c();
            Opportunity opp = newOppsById.get(oppId);
        
            newProject.Opportunity__c = oppId;  
            newProject.AccountId = opp.AccountId;
            newProject.StartDate__c = opp.StartDate__c;
            newProject.EndDate__c = opp.EndDate__c;
            newProject.PM__c = opp.PM__c;
            newProject.SquadLead__c = opp.SquadLead__c;

            for (ProjectItem__c item : oppsItemsByOppId.get(oppId)) {
                ProjectItem__c newProjectItem = new ProjectItem__c();
                newProjectItem.Project__r = newProject;
                newProjectItem.Role = item.Role;
                newProjectItem.Quantity__c = item.Quantity__c;

                newProjectItemsList.add(newProjectItem);
            }

            newProjectsList.add(newProject);

        }
        insert newProjectsList;

        //ahora recorremos el los items para actualizar su relación con los Project
        for (ProjectItem__c item : newProjectItemsList) {
            item.Project__c = item.Project__r.Id;
        }

        insert newProjectItemsList;

    }
}