public with sharing class ValidationAllocatedResourceTrigger {
    public static void beforeInsert(List <AllocatedResource__c> newAllocations){
        Date startDate= newAllocations[0].Start_Date__c;
        Date endDate= newAllocations[0].End_Date__c;


        List <User> freeResources = ProjectDataService.getFreeResources(startDate, endDate);

        List<AllocatedResource__c> freeResourceConfirmed= new List<AllocatedResource__c>();

        for(AllocatedResource__c resourceInsert: newAllocations){
            for(User resourceItem: freeResources){
                if(resourceInsert.id == resourceItem.id){
                    freeResourceConfirmed.add(resourceInsert);
                }
            }
        }

        if(freeResourceConfirmed.size()== newAllocations.size()){
            System.debug('La lista de elementos a insertar aun esta disponible');
        }
        else {
            System.debug('Hay resources que ya fueron ocupados');
            return;
        }
    }
}
