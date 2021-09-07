public with sharing class StartProjects {
    
    public static void updateStage() {
        
        //día actual
        Date todayDate = Date.today();
        
        //traemos los projects en cuyo StartDate = hoy
        Map<Id, Project__c> projects = new Map<Id, Project__c>([SELECT Id, Status__c, Project_Manager__r.Email FROM Project__c
                                                                WHERE (Status__c = 'Pre Kick-Off' AND Start_Date__c = :todayDate)
                                                                OR (Status__c = 'Start' AND End_Date__c = :todayDate)]);
        
        //actualizamos los proyectos
        for (Project__c project : projects.values()) {
            if (project.Status__c == 'Pre Kick-Off') project.Status__c = 'Start';
            else if (project.Status__c == 'Start') project.Status__c = 'Completed';
        }
        Database.SaveResult[] updatedList = Database.update(projects.values(), false);

        //iteramos el resultado de la actualización del bulk de projects
        for (Database.SaveResult item : updatedList) {
            if (item.isSuccess()) System.debug('Project updated');
            else {
                //Si el project no cumplía las condiciones, enviar un mail a su ProjectManager
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};

                for(Database.Error error : item.getErrors()) {               
                    System.debug(error.getMessage());
                    message.toAddresses = new String[] { projects.get(item.getId()).Project_Manager__r.Email };
                    message.optOutPolicy = 'FILTER';
                    message.subject = 'Project unable to be updated to Start status';
                    message.plainTextBody = 'Please, verify your projects in PreKickOff status. One of them has pending hours to cover or has no Squad Lead assigned.';
                }
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                if (results[0].success) System.debug('The email was sent successfully.');
                else System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }
}
