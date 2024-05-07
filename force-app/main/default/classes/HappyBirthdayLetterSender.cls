public class HappyBirthdayLetterSender implements Database.Batchable<sObject>, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
     	String query = 'SELECT Email FROM Contact WHERE BirthDate = TODAY';
        return Database.getQueryLocator(query);
   	}
    
   	public void execute(Database.BatchableContext BC, List<Contact> ContactList) {
       
        EmailTemplate emailTempl;
     	List<EmailTemplate> emailTempls = [SELECT Id FROM EmailTemplate WHERE Name = 'HappyBirthdayLetter' AND IsActive = true LIMIT 1];

       	if(emailTempls.size() > 0)
       		emailTempl = emailTempls[0];   
       	else
			return;
    
   		List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();
    
        for(Contact cont : ContactList){
            if(String.isBlank(cont.Email))
                continue;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(emailTempl.Id);
            mail.setToAddresses(new List<String>{cont.Email});
            mail.setTargetObjectId(cont.Id);
            lstEmail.add(mail);
        }
           
        Messaging.SendEmail(lstEmail);
	}  

    public void finish(Database.BatchableContext BC) {  
    }
}