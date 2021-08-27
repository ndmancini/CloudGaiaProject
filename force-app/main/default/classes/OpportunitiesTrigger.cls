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
        List<OpportunityLineItem__c> oppsItemsList = [SELECT Quantity__c, Roles__c,
                                                   Opportunity__c,
                                                   Opportunity__r.Start_Date__c, Opportunity__r.End_Date__c,
                                                   Opportunity__r.Account.Id, Opportunity__r.Project_Manager__c
                                                   FROM OpportunityLineItem__c WHERE Opportunity__c IN :closedOpps];
        
        //creamos un map donde key=opportunityId, value=List<OpportunityLineItem>>
        Map<Id, List<OpportunityLineItem__c>> oppsItemsByOppId = new Map<Id, List<OpportunityLineItem__c>>();  

        //completa el Map
        for (OpportunityLineItem__c item : oppsItemsList) {
            if (!oppsItemsByOppId.containsKey(item.Opportunity__c)) {
                oppsItemsByOppId.put(item.Opportunity__c, new List<OpportunityLineItem__c>{item});
            }
            else {
                oppsItemsByOppId.get(item.Opportunity__c).add(item);
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
            for (OpportunityLineItem__c item : oppsItemsByOppId.get(oppId)) {
                ProjectLineItem__c newProjectItem = new ProjectLineItem__c();
                newProjectItem.Project__r = newProject;
                newProjectItem.Role__c = item.Roles__c;
                newProjectItem.Quantity__c = item.Quantity__c;

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