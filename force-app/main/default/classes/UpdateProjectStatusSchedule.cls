global with sharing class UpdateProjectStatusSchedule implements Schedulable {
    global void execute(SchedulableContext SC){
        StartProjects.updateStage(); //hola
    }
}