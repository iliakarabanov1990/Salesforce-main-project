public class ScheduledHappyBirthdayLetterSender implements Schedulable{
	public void execute(SchedulableContext SC) {
   		HappyBirthdayLetterSender sender = new HappyBirthdayLetterSender(); 
      	Database.executeBatch(sender); 
	}
}