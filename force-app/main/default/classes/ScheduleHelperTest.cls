@isTest
public class ScheduleHelperTest {
    
     @TestSetup
	static void testSetup() {
 		List<Contact> contacts = new List<Contact>();     
        contacts.add(new Contact(FirstName ='contactTest1', LastName='contactTest1', BirthDate = date.today()));
        contacts.add(new Contact(FirstName ='contactTest2', LastName='contactTest2', Email = 'iliaKarabanov@gmail.com', BirthDate = date.today()));
        insert contacts;
        
        ScheduledHappyBirthdayLetterSender sender = new ScheduledHappyBirthdayLetterSender();
       	System.schedule('test1', '0 0 23 * * ?', sender);
  	}
   
    @isTest
    static void testBatchByName(){
                      
        Test.startTest();
        	ScheduleHelper.getDataSchedulerByName('test1');
        Test.stopTest();
    }
    
    @isTest
    static void testSetSchedulerByName(){
                      
        Test.startTest();
        	ScheduleHelper.setSchedulerByBatchName('ScheduledHappyBirthdayLetterSender', '0 0 23 * * ?');
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteBatchByName(){
        
        Test.startTest();
            ScheduleHelper.executeBatchByName('HappyBirthdayLetterSender');
        Test.stopTest();
    }
    
    @isTest
    static void testGetDataSchedulerById(){
        
        ScheduledHappyBirthdayLetterSender sender = new ScheduledHappyBirthdayLetterSender();
       	Id jobId = System.schedule('test2', '0 0 23 * * ?', sender);
               
        Test.startTest();           
            ScheduleHelper.getDataSchedulerById(jobId);
        Test.stopTest();
    }
    
    @isTest
    static void testAbortJob(){
        
        ScheduledHappyBirthdayLetterSender sender = new ScheduledHappyBirthdayLetterSender();
       	Id jobId = System.schedule('test3', '0 0 23 * * ?', sender);
               
        Test.startTest();
        	ScheduleHelper.abortJob(jobId);
        Test.stopTest();
    }
}