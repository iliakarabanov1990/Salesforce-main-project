@isTest
private class HappyBirthdayLetterSenderTest {
    
    @TestSetup
	static void testSetup() {
 		List<Contact> contacts = new List<Contact>();     
        contacts.add(new Contact(FirstName ='contactTest1', LastName='contactTest1', BirthDate = date.today()));
        contacts.add(new Contact(FirstName ='contactTest2', LastName='contactTest2', Email = 'iliaKarabanov@gmail.com', BirthDate = date.today()));
        insert contacts;
  	}
   
    @isTest
    static void testBatch(){
               
        Test.startTest();
            HappyBirthdayLetterSender  sender = new HappyBirthdayLetterSender();
            Id jobid = Database.executeBatch(sender, 100);
        Test.stopTest();
    }
    
    @isTest
    static void testBatchWithoutTemlate(){
        
        delete [SELECT Id FROM EmailTemplate WHERE Name = 'HappyBirthdayLetter' AND IsActive = true LIMIT 1];
               
        Test.startTest();
            HappyBirthdayLetterSender  sender = new HappyBirthdayLetterSender();
            Id jobid = Database.executeBatch(sender, 100);
        Test.stopTest();
    }
}