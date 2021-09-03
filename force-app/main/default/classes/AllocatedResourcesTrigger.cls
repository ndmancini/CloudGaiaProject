public with sharing class AllocatedResourcesTrigger {

    public static void beforeInsert(List<AllocatedResource__c> newAllocations){

        //Mapa donde key=projectId y value=lista de newAllocations
        Map<Id, List<AllocatedResource__c>> allocationsByProjectId = new Map<Id, List<AllocatedResource__c>>();
        for (AllocatedResource__c allocation : newAllocations) {
            if (!allocationsByProjectId.containsKey(allocation.ProjectsItem__c)) {
                allocationsByProjectId.put(allocation.ProjectsItem__c, new List<AllocatedResource__c>{allocation});
            }
            else allocationsByProjectId.get(allocation.ProjectsItem__c).add(allocation);
        }
        
        //traemos los projectitems para actualizar las horas cubiertas
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