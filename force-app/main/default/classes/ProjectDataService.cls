public with sharing class ProjectDataService {
    
    //método para traernos los roles con horas pendientes en un project__c
    @AuraEnabled(Cacheable=true)
    public static List<ProjectLineItem__c> getPendingRoles(Id projectId) {
        return [SELECT Id, Role__c, Quantity__c, QuantityHours__c
                FROM ProjectLineItem__c
                WHERE Project__c = :projectId AND Covered__c = false];        
    }

    //método que nos devuelve los recursos asignados a un projecto
    @AuraEnabled(Cacheable=true)
    public static List<User> getResourcesInProject(Id projectId){
        return [SELECT Id, Name FROM User
                WHERE Id IN (SELECT Resource__c FROM AllocatedResource__c WHERE ProjectsItem__r.Project__c = :projectId)];
    }
    
    //método para traernos los recursos libres fuera de las fechas pasadas como parámetro
    @AuraEnabled(Cacheable=true)
    public static Map<String, List<User>> getFreeResources(List<String> roles) { //Date startDate, Date endDate) {
        List<User> freeResourcesList = [SELECT Id, Name, UserRole.Name
                FROM User WHERE UserRole.Name IN :roles];
                //WHERE Id NOT IN (SELECT Resource__c
                //                 FROM AllocatedResource__c
                //                 WHERE ((Start_Date__c >= :startDate AND Start_Date__c <= :endDate) OR //empieza durante el proyecto
                //                        (End_Date__c >= :startDate AND End_Date__c <= :endDate) OR     //termina durante el proyecto
                //                        (Start_Date__c <= :startDate AND End_Date__c >= :endDate)))];  //empieza y termina fuera del proyecto
    
    	//mapa donde key=RoleName; value= list de resources libres con ese rol
        Map<String, List<User>> freeResourcesByRole = new Map<String, List<User>>();
        for (User resource : freeResourcesList) {
            if (!freeResourcesByRole.containsKey(resource.UserRole.Name)) {
                freeResourcesByRole.put(resource.UserRole.Name, new List<User>{resource});
            }
            else freeResourcesByRole.get(resource.UserRole.Name).add(resource);
        }
        return freeResourcesByRole;
    }
    
    //método para traernos los recursos libres fuera de las fechas pasadas como parámetro
    @AuraEnabled(Cacheable=true)
    public static List<User> getFreeResourcesByRole(Date startDate, Date endDate, String role) {
        return [SELECT Id, Name, UserRole.Name
                FROM User
                WHERE UserRole.Name = :role];// AND Id NOT IN (SELECT Resource__c
                                             //              FROM AllocatedResource__c
                                             //              WHERE ((Start_Date__c >= :startDate AND Start_Date__c <= :endDate) OR //empieza durante el proyecto
                                             //                     (End_Date__c >= :startDate AND End_Date__c <= :endDate) OR     //termina durante el proyecto
                                             //                     (Start_Date__c <= :startDate AND End_Date__c >= :endDate)))];  //empieza y termina fuera del proyecto
    }
    
    //método para insertar registros en el objeto AllocatedResource (asignar recursos)
    @AuraEnabled
    public static void assignResource(List<AllocatedResource__c> newAllocatedResources) {
        //insert newAllocatedResources;
        database.insert(newAllocatedResources, false);
    }

    //método para insertar el squadLead del projecto
    @AuraEnabled
    public static void assingSquadLead(Id userId, Id projectId) {
        Project__c project = [SELECT Id, Squad_Lead__c FROM Project__c WHERE Id = :projectId];
        project.Squad_Lead__c = userId;
        update project;
    }

}