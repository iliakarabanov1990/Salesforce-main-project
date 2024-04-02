@istest
public class HandleInboundEmailTest {
    
  	@TestSetup
	static void testSetup() {
        List<Opportunity> opps = new List<Opportunity>();
 		opps.add(new Opportunity(StageName='Negotiation/Review', Name='first', CloseDate=System.today()));    
        opps.add(new Opportunity(StageName='Closed Lost', Name='second', CloseDate=System.today()));
   		insert opps;     
  	}

    @isTest
    static void TestApproved(){
        
        String[] stages = new String[0];
        for(PicklistEntry value: Opportunity.StageName.getDescribe().getPicklistValues()) {
            stages.add(value.getValue());
        }
        
        String oppNumber1 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'first'][0].Invoice_Number__c;
        String oppNumber2 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'second'][0].Invoice_Number__c;
        
        Integer stageNegotInd = stages.indexOf('Negotiation/Review'); 
        String nextStage = stages[stageNegotInd+1];
            
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'iliakarabanovsc@gmail.com'};        
        email.subject = 'Invoice ' + oppNumber1 + ' of IliaCorp';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.plainTextBody = 'Approved, thank you! ';      
       	ProcessingResponseToInvoice  testInbound  = new ProcessingResponseToInvoice();
        
        
        Test.startTest();
        	testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
        /*Assert.areEqual(
        '1',
        [SELECT Id, Invoice_Number__c FROM Opportunity][0].Invoice_Number__c,
        'Approved case doesn\'t work');*/
        
      	Assert.areEqual(
        1,
        [SELECT Id FROM Opportunity WHERE StageName = :nextStage].size(),
        'Approved case doesn\'t work');
        
    }   

    @isTest
    static void TestRejected(){
        
        String oppNumber1 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'first'][0].Invoice_Number__c;
        String oppNumber2 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'second'][0].Invoice_Number__c;
        
    	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'iliakarabanovsc@gmail.com'};        
        email.subject = 'Invoice ' + oppNumber1 + ' of IliaCorp';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.plainTextBody = 'Rejected, thank you! ';      
       	ProcessingResponseToInvoice  testInbound  = new ProcessingResponseToInvoice();
        
        
        Test.startTest();
        	testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
      	Assert.areEqual(
        [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost' AND Invoice_Number__c != :oppNumber2].size(),
        1,
        'Rejected case doesn\'t work');
    }

	@isTest
    static void TestWithoutAnswer(){
        
        String oppNumber1 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'first'][0].Invoice_Number__c;
        String oppNumber2 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'second'][0].Invoice_Number__c;
        
		String[] stages = new String[0];
        for(PicklistEntry value: Opportunity.StageName.getDescribe().getPicklistValues()) {
            stages.add(value.getValue());
        }
        
        Integer stageNegotInd = stages.indexOf('Negotiation/Review'); 
        String nextStage = stages[stageNegotInd+1];

    	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'iliakarabanovsc@gmail.com'};        
        email.subject = 'Invoice ' + oppNumber1 + ' of IliaCorp';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.plainTextBody = 'thank you! ';      
       	ProcessingResponseToInvoice  testInbound  = new ProcessingResponseToInvoice();
        
        
        Test.startTest();
        	testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
      	Assert.areEqual(
        [SELECT Id FROM Opportunity WHERE StageName = :nextStage].size(),
        0,
        'Without answer case doesn\'t work');

		Assert.areEqual(
        [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost' AND Invoice_Number__c != :oppNumber2].size(),
        0,
        'Without answer case doesn\'t work');
    }

	@isTest
    static void TestWithoutInvoiceNumber(){
        
        String oppNumber1 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'first'][0].Invoice_Number__c;
        String oppNumber2 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'second'][0].Invoice_Number__c;
        
		String[] stages = new String[0];
        for(PicklistEntry value: Opportunity.StageName.getDescribe().getPicklistValues()) {
            stages.add(value.getValue());
        }
        
        Integer stageNegotInd = stages.indexOf('Negotiation/Review'); 
        String nextStage = stages[stageNegotInd+1];

    	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'iliakarabanovsc@gmail.com'};        
        email.subject = 'Invoice of IliaCorp';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.plainTextBody = 'Rejected, thank you! ';      
       	ProcessingResponseToInvoice  testInbound  = new ProcessingResponseToInvoice();
        
        
        Test.startTest();
        	testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
      	Assert.areEqual(
        [SELECT Id FROM Opportunity WHERE StageName = :nextStage].size(),
        0,
        'Without invoice number case doesn\'t work');

		Assert.areEqual(
        [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost' AND Invoice_Number__c != :oppNumber2].size(),
        0,
        'Without invoice number case doesn\'t work');
    }

	@isTest
    static void TestWrongInvoiceNumber(){
        
        String oppNumber1 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'first'][0].Invoice_Number__c;
        String oppNumber2 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'second'][0].Invoice_Number__c;     
        
		String[] stages = new String[0];
        for(PicklistEntry value: Opportunity.StageName.getDescribe().getPicklistValues()) {
            stages.add(value.getValue());
        }
        
        Integer stageNegotInd = stages.indexOf('Negotiation/Review'); 
        String nextStage = stages[stageNegotInd+1];

    	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'iliakarabanovsc@gmail.com'};        
        email.subject = 'Invoice INV-999999 of IliaCorp';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.plainTextBody = 'thank you! ';      
       	ProcessingResponseToInvoice  testInbound  = new ProcessingResponseToInvoice();
        
        
        Test.startTest();
        	testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
      	Assert.areEqual(
        [SELECT Id FROM Opportunity WHERE StageName = :nextStage].size(),
        0,
        'Wrong invoice number case doesn\'t work');

		Assert.areEqual(
        [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost' AND Invoice_Number__c != :oppNumber2].size(),
        0,
        'Wrong invoice number case doesn\'t work');
    }

	@isTest
    static void TestAlreadyClosedOpp(){
        
        String oppNumber1 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'first'][0].Invoice_Number__c;
        String oppNumber2 = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'second'][0].Invoice_Number__c;
        
		String[] stages = new String[0];
        for(PicklistEntry value: Opportunity.StageName.getDescribe().getPicklistValues()) {
            stages.add(value.getValue());
        }
        
        Integer stageNegotInd = stages.indexOf('Negotiation/Review'); 
        String nextStage = stages[stageNegotInd+1];

    	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'iliakarabanovsc@gmail.com'};        
        email.subject = 'Invoice ' + oppNumber2 + ' of IliaCorp';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.plainTextBody = 'thank you! ';      
       	ProcessingResponseToInvoice  testInbound  = new ProcessingResponseToInvoice();      
        
        Test.startTest();
        	testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
      	Assert.areEqual(
        [SELECT Id FROM Opportunity WHERE StageName = :nextStage].size(),
        0,
        'Already closed opp case doesn\'t work');

		Assert.areEqual(
        [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost'].size(),
        1,
        'Already closed opp case doesn\'t work');
    }

}