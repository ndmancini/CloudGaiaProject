
@isTest
public class UpdateProjectStatusScheduleTest {  
    public static String CRON_EXP = '0 0 1 * * ?';
    
    @isTest
    static void testExecute(){
        Test.startTest();
        String jobId = System.schedule('UpdateProjectStatusSchedule', CRON_EXP, new UpdateProjectStatusSchedule());
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM CronTrigger WHERE CronJobDetail.Name = 'UpdateProjectStatusSchedule']);
    }

}
