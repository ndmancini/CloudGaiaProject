public with sharing class AllocatedResourcesTrigger {

    public static void beforeInsert(List<AllocatedResource__c> newAllocations) {

        //set de usersId presentes en las newAllocations
        Set<Id> usersId = new Set<Id>();
        for(AllocatedResource__c allocation : newAllocations) {
            usersId.add(allocation.Resource__c);
        }

        //traemos las allocations viejas de dichos Users
        List<AllocatedResource__c> oldAllocations= [SELECT Id, Resource__c, Start_Date__c, End_Date__c 
                                                    FROM AllocatedResource__c WHERE Resource__c IN :usersId];

        //map donde Key=userId, value=Lista de sus allocations viejas
        Map<Id, List<AllocatedResource__c>> oldAllocationsByUserId = new Map<Id, List<AllocatedResource__c>>();

        for(AllocatedResource__c allocation : oldAllocations) {
            if(!oldAllocationsByUserId.containsKey(allocation.Resource__c)) {
				oldAllocationsByUserId.put(allocation.Resource__c, new List<AllocatedResource__c>{allocation});
            }
            else oldAllocationsByUserId.get(allocation.Resource__c).add(allocation);
        }

        //Iteramos las nuevas allocations y chequeamos que para cada user, no haya superposición con allocations viejas
        if (oldAllocations.size() > 0) {
            for (AllocatedResource__c newAllocation : newAllocations) {
                Date startDate = newAllocation.Start_Date__c;
                Date endDate = newAllocation.End_Date__c;
                List<AllocatedResource__c> oldAllocationsFromUser= oldAllocationsByUserId.get(newAllocation.Resource__c);
                Boolean fail = false;
                for (AllocatedResource__c oldAllocation : oldAllocationsFromUser) {
                    if ((oldAllocation.Start_Date__c >= startDate && oldAllocation.Start_Date__c <= endDate) || (oldAllocation.End_Date__c >= startDate && oldAllocation.End_Date__c <= endDate) || (oldAllocation.Start_Date__c <= startDate && oldAllocation.End_Date__c >= endDate)){
                        fail = true;
                    } 
                } 
                if (fail) {
                    newAllocation.addError('The resource has already been assigned or is used in another project.');
                }
            }
        }
    }

    public static void afterInsert(List<AllocatedResource__c> newAllocations) {
        
        //Mapa donde key=projectId y value=lista de newAllocations
        Map<Id, List<AllocatedResource__c>> allocationsByProjectId = new Map<Id, List<AllocatedResource__c>>();
        for (AllocatedResource__c allocation : newAllocations) {
            if (!allocationsByProjectId.containsKey(allocation.ProjectsItem__c)) {
                allocationsByProjectId.put(allocation.ProjectsItem__c, new List<AllocatedResource__c>{allocation});
            }
            else allocationsByProjectId.get(allocation.ProjectsItem__c).add(allocation);
        }
        
        //traemos los projectItems para actualizar las horas cubiertas
        List<ProjectLineItem__c> projectItems = [SELECT Id, Quantity__c, QuantityHours__c FROM ProjectLineItem__c
                                                 WHERE Id in :allocationsByProjectId.keySet()];
        
        //ahora iteramos los projectItems para calcular las horas cubiertas con las nuevas allocations
        for (ProjectLineItem__c item : projectItems) {
            integer totalDays = 0;
            
            for (AllocatedResource__c allocation : allocationsByProjectId.get(item.Id)) {
                
                Date startDate = allocation.Start_Date__c;
                Date endDate = allocation.End_Date__c;
                
                for (Date day = startDate; day <= endDate; day = day.addDays(1)) {
                    
                    DateTime dayDate = DateTime.newInstance(day.year(), day.month(), day.day());  
                    String todayDay = dayDate.format('EEEE');  
                    
                    if (todayDay != 'Sunday' && todayDay != 'Saturday') totalDays++;
                }
            }
            item.QuantityHours__c = item.QuantityHours__c + totalDays*8;
            if (item.QuantityHours__c > item.Quantity__c) item.QuantityHours__c = item.Quantity__c;
        }
        
        update projectItems;
    }
}