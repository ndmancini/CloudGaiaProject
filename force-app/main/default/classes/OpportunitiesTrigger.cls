public with sharing class OpportunitiesTrigger {
    
    public static void beforeUpdate(Map<Id, Opportunity> newOppsById, Map<Id, Opportunity> oldOppsById) {
        
        //Tomamos los mapas de opportunities recibidos por parámetro
        // y nos quedamos sólo con aquellos cuyo Stage pasó de 'Negotiation/Review' a 'Closed Won'
        Set<Id> closedOpps = new Set<Id>();
        for (Opportunity opp : newOppsById.values()) {
            if (opp.StageName == 'Closed Won') {
                if (oldOppsById.get(opp.Id).StageName == 'Negotiation/Review') {
                    closedOpps.add(opp.Id);
                }
            }
        }
        
        //Buscamos los items de dichas opportunities que se han cerrado
        List<OpportunityLineItem> oppsItemsList = [SELECT Quantity, Role__c,
                                                   Opportunity.Start_Date__c, Opportunity.End_Date__c,
                                                   Opportunity.Account.Id, Opportunity.Project_Manager__c
                                                   FROM OpportunityLineItem WHERE OpportunityId IN :closedOpps];
        
        //creamos un map donde key=opportunityId, value=List<OpportunityLineItem>>
        Map<Id, List<OpportunityLineItem>> oppsItemsByOppId = new Map<Id, List<OpportunityLineItem>>();  

        //completa el Map
        for (OpportunityLineItem item : oppsItemsList) {
            if (!oppsItemsByOppId.containsKey(item.OpportunityId)) {
                oppsItemsByOppId.put(item.OpportunityId, new List<OpportunityLineItem>{item});
            }
            else {
                oppsItemsByOppId.get(item.OpportunityId).add(item);
            }
        }
        
        //ahora recorremos el Map y creamos un nuevo Project__c
        List<Project__c> newProjectsList = new List<Project__c>();
        List<ProjectLineItem__c> newProjectItemsList = new List<ProjectLineItem__c>();
                
        for (Id oppId : oppsItemsByOppId.keySet()) {
            Project__c newProject = new Project__c();
            Opportunity opp = newOppsById.get(oppId);
        
            newProject.Opportunity__r.Id = oppId;  
            newProject.Account__r.Id = opp.AccountId;
            newProject.Start_Date__c = opp.Start_Date__c;
            newProject.End_Date__c = opp.End_Date__c;
            newProject.Project_Manager__c = opp.Project_Manager__c;

            //creamos nuevos projectItems a partir de los oppItems
            for (OpportunityLineItem item : oppsItemsByOppId.get(oppId)) {
                ProjectLineItem__c newProjectItem = new ProjectLineItem__c();

                newProjectItem.Project__r = newProject;
                newProjectItem.Role__c = item.Role__c;
                newProjectItem.Quantity__c = item.Quantity;

                newProjectItemsList.add(newProjectItem);
            }
            newProjectsList.add(newProject);
        }
        insert newProjectsList;
        
        //ahora recorremos los items para actualizar su relación con los Project
        for (ProjectLineItem__c item : newProjectItemsList) {
            item.Project__c = item.Project__r.Id;
        }

        insert newProjectItemsList;
    }
}