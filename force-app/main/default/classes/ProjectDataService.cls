public with sharing class ProjectDataService {
    
    //método para traernos los roles con horas pendientes en un project__c
    @AuraEnabled(Cacheable=true)
    public static List<ProjectLineItem__c> getPendingRoles(Id projectId) {
        return [SELECT Id, Role__c, Quantity__c, QuantityHours__c
                FROM ProjectLineItem__c
                WHERE Project__c = :projectId AND Covered__c = false];        
    }
    
    //método para traernos los recursos libres fuera de las fechas pasadas como parámetro
    @AuraEnabled(Cacheable=true)
    public static List<User> getFreeResources(Date startDate, Date endDate) {
        return [SELECT Id, Name, UserRole.Name
                FROM User
                WHERE Id NOT IN (SELECT Resource__c
                                 FROM AllocatedResource__c
                                 WHERE ((Start_Date__c >= :startDate AND Start_Date__c <= :endDate) OR //empieza durante el proyecto
                                        (End_Date__c >= :startDate AND End_Date__c <= :endDate) OR     //termina durante el proyecto
                                        (Start_Date__c <= :startDate AND End_Date__c >= :endDate)))];  //empieza y termina fuera del proyecto
    }
    
    //método para traernos los recursos libres fuera de las fechas pasadas como parámetro
    @AuraEnabled(Cacheable=true)
    public static List<User> getFreeResourcesByRole(Date startDate, Date endDate, String role) {
        return [SELECT Id, Name, UserRole.Name
                FROM User
                WHERE UserRole.Name = :role AND Id NOT IN (SELECT Resource__c
                                                           FROM AllocatedResource__c
                                                           WHERE ((Start_Date__c >= :startDate AND Start_Date__c <= :endDate) OR //empieza durante el proyecto
                                                                  (End_Date__c >= :startDate AND End_Date__c <= :endDate) OR     //termina durante el proyecto
                                                                  (Start_Date__c <= :startDate AND End_Date__c >= :endDate)))];  //empieza y termina fuera del proyecto
    }
    
    //método para insertar registros en el objeto AllocatedResource (asignar recursos)
    @AuraEnabled(Cacheable=true)
    public static void assignResource(List<Object> newJSONAllocatedResources) {

            System.debug(newJSONAllocatedResources);
            List<Object> objectList = (List<Object>) newJSONAllocatedResources;
            List<AllocatedResource__c> newAllocatedResourcesList = new List<AllocatedResource__c>();

            for (Object obj : objectList) {
                Map<String, Object> objectMap = (Map<String, Object>) obj;
                AllocatedResource__c newResource = new AllocatedResource__c();
                newResource.Resource__c = (Id)objectMap.get('Resource__c');
                newResource.ProjectsItem__c = (Id)objectMap.get('ProjectsItem__c');
                newAllocatedResourcesList.add(newResource);
            }
        
		insert newAllocatedResourcesList;

        //System.debug('hola');
        //System.debug(newAllocatedResources);
        //insert newAllocatedResources;

    }
    
}