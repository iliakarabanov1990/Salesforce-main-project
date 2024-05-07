@isTest
public class ScheduledHappyBirthdayLetterSenderTest {
    
    static testMethod void testSchedule(){
        Test.startTest();
        	ScheduledHappyBirthdayLetterSender sender = new ScheduledHappyBirthdayLetterSender();
        	Id jobid = System.schedule('test', '0 0 23 * * ?', sender);
        Test.stopTest();
    }
}