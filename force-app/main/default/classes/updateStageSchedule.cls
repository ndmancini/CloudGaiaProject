global with sharing class updateStageSchedule implements Schedulable{
    global void execute(SchedulableContext SC){
        System.enqueueJob(new updateStage());
    }
}