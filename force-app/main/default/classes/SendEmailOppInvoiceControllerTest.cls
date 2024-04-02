@isTest
public class SendEmailOppInvoiceControllerTest {
    
    @TestSetup
	static void testSetup() {
 		Opportunity opp = new Opportunity(StageName='Negotiation/Review', Name='first', CloseDate=System.today());
   		insert opp;
        
        Contact cont = new Contact(FirstName ='contactTest1', LastName='contactTest1');
        insert cont;      
        
        OpportunityContactRole oppContRole = new OpportunityContactRole(ContactId = cont.id, OpportunityId = opp.id, IsPrimary = true);     
        insert oppContRole;
        
        GenerateInvoiceController.GenerateInvoice(opp.Id); 
  	}
    
    @isTest
    static void TestSendEmail(){
        
        String oppNumber1 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'first'][0].Invoice_Number__c;
        
        List<ContentVersion> conVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = :oppNumber1 ORDER BY LastModifiedDate DESC LIMIT 1];
        
    	Test.startTest();
            SendEmailOppInvoiceController.sendEmail('fromAddress@gmail.com', 'toAddress@gmail.com', 'subject', 'body', 'fileTitle', conVer[0].Id);
            Integer invocations = Limits.getEmailInvocations();
    	Test.stopTest();
    
    	Assert.areEqual(invocations, 1, 'sendEmail doesn\'t work');
    }
    
    @isTest
    static void TestSendEmailWithOWEA(){
        
        String oppNumber1 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'first'][0].Invoice_Number__c;
        
        List<ContentVersion> conVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = :oppNumber1 ORDER BY LastModifiedDate DESC LIMIT 1];
        
    	Test.startTest();
            SendEmailOppInvoiceController.sendEmail('iliakarabanovsc@gmail.com', 'toAddress@gmail.com', 'subject', 'body', 'fileTitle', conVer[0].Id);
            Integer invocations = Limits.getEmailInvocations();
    	Test.stopTest();
    
    	Assert.areEqual(invocations, 1, 'sendEmail doesn\'t work');
    }
    
    @isTest
    static void TestGetEmailData(){
        
        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'first'][0];
        String oppId = opp.Id;
        String invoiceNumber = opp.Invoice_Number__c;
        
    	Test.startTest();
        	Map<String, String> data = SendEmailOppInvoiceController.getEmailData(oppId);
    	Test.stopTest();
    
    	Assert.areEqual(data.get('invoiceNumber'), invoiceNumber, 'getEmailData doesn\'t work');
    }

}