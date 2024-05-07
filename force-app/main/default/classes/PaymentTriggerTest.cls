@isTest
public class PaymentTriggerTest {
    
	@TestSetup
	static void testSetup() {
        
        List<Account> accs = new List<Account>();
 		accs.add(new Account(Name = 'Test Account'));
        accs.add(new Account(Name = 'Test Account2'));
        insert accs;

        List<Opportunity> opps = new List<Opportunity>();
 		opps.add(new Opportunity(Name = 'Test Opportunity1', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = accs[0].Id, Amount = 10));
       	opps.add(new Opportunity(Name = 'Test Opportunity2', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = accs[0].Id, Amount = 20));
        opps.add(new Opportunity(Name = 'Test Opportunity3', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = accs[1].Id, Amount = 30));
        opps.add(new Opportunity(Name = 'Test Opportunity4FullyPaid', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = accs[1].Id, Amount = 40, Payment_Status__c = 'Fully Paid'));
        opps.add(new Opportunity(Name = 'Test Opportunity5', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = accs[0].Id, Amount = 10));
        insert opps;
        
        Contact cont = new Contact(FirstName ='contactTest1', LastName='contactTest1');
        insert cont;      
        
        List<OpportunityContactRole> oppContRoles = new List<OpportunityContactRole>();
        oppContRoles.add(new OpportunityContactRole(ContactId = cont.id, OpportunityId = opps[0].id, IsPrimary = true));   
        oppContRoles.add(new OpportunityContactRole(ContactId = cont.id, OpportunityId = opps[1].id, IsPrimary = true));
        oppContRoles.add(new OpportunityContactRole(ContactId = cont.id, OpportunityId = opps[2].id, IsPrimary = true));
        oppContRoles.add(new OpportunityContactRole(ContactId = cont.id, OpportunityId = opps[3].id, IsPrimary = true));
        oppContRoles.add(new OpportunityContactRole(ContactId = cont.id, OpportunityId = opps[4].id, IsPrimary = true));
       	insert oppContRoles;
        
        List<Payment__c> payments = new List<Payment__c>();
 		payments.add(new Payment__c(Name = 'Test1', 			Opportunity__c = opps[0].Id, Amount__c = 5, FirstName__c = 'FTest1', LastName__c = 'Ltest1')); 
        payments.add(new Payment__c(Name = 'Test2FullyPaid', 	Opportunity__c = opps[1].Id, Amount__c = 20, FirstName__c = 'FTest2', LastName__c = 'Ltest2'));
        payments.add(new Payment__c(Name = 'Test3', 			Opportunity__c = opps[2].Id, Amount__c = 20, FirstName__c = 'FTest3', LastName__c = 'Ltest3'));
        payments.add(new Payment__c(Name = 'Test4FullyPaid', 	Opportunity__c = opps[3].Id, Amount__c = 40, FirstName__c = 'FTest3', LastName__c = 'Ltest3'));
        insert payments;
        
        Payment__c payment = [SELECT Id FROM Payment__c WHERE Name = 'Test3' LIMIT 1];     
        delete payment;
  	}  
    
    @isTest
    static void TestInsertWithFullPayPayment(){
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity1' LIMIT 1];

    	Test.startTest();   
    	   insert new Payment__c(Name = 'Test', Opportunity__c = opp.Id, Amount__c = 5, FirstName__c = 'FTest3', LastName__c = 'Ltest3');
    	Test.stopTest();
    
    	Assert.areEqual(4, [SELECT Id FROM Payment__c].size(), 'insertion for Payment__c works wrong');
        Assert.areEqual(1, [SELECT Id FROM Task WHERE WhatId = :opp.Id].size(), 'creation Task for Payment__c works wrong');
    }
    
    @isTest
    static void TestInsertWithoutFullPayPayment(){
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity1' LIMIT 1];

    	Test.startTest();
           insert new Payment__c(Name = 'Test', Opportunity__c = opp.Id, Amount__c = 2, FirstName__c = 'FTest3', LastName__c = 'Ltest3');
    	Test.stopTest();
    
    	Assert.areEqual(4, [SELECT Id FROM Payment__c].size(), 'insertion for Payment__c works wrong');
        Assert.areEqual(0, [SELECT Id FROM Task WHERE WhatId = :opp.Id].size(), 'creation Task for Payment__c works wrong');
    }
    
    @isTest
    static void TestInsertWithoutAmountPayment(){
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity5' LIMIT 1];

    	Test.startTest();
           insert new Payment__c(Name = 'Test', Opportunity__c = opp.Id, Amount__c = 0, FirstName__c = 'FTest3', LastName__c = 'Ltest3');
    	Test.stopTest();
    
    	Assert.areEqual('Unpaid', [SELECT Id, Payment_Status__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1][0].Payment_Status__c, 'insertion for Payment__c works wrong');
        Assert.areEqual(0, [SELECT Id FROM Task WHERE WhatId = :opp.Id].size(), 'creation Task for Payment__c works wrong');
    }
    
    @isTest
    static void TestUpdatePayment(){
        
        Payment__c payment = [SELECT Id, Name FROM Payment__c WHERE Name = 'Test1' LIMIT 1];

        payment.Name = 'Test';
    	Test.startTest();
           update payment;
    	Test.stopTest();
        
        List<Payment__c> payments = [SELECT Id, Opportunity__c FROM Payment__c WHERE Name = 'Test'];
    
    	Assert.areEqual(1, payments.size(), 'updating for Payment__c works wrong');
        Assert.areEqual(0, [SELECT Id FROM Task WHERE WhatId = :payments[0].Opportunity__c].size(), 'creation Task for Payment__c works wrong');
    }
    
   @isTest
    static void TestUpdatePaymentWithFullyPaidStatus(){
        
        Payment__c payment = [SELECT Id, Name FROM Payment__c WHERE Name = 'Test4FullyPaid' LIMIT 1];

        payment.Name = 'Test';
    	Test.startTest();
           update payment;
    	Test.stopTest();
        
        List<Payment__c> payments = [SELECT Id, Opportunity__c FROM Payment__c WHERE Name = 'Test'];
    
    	Assert.areEqual(1, payments.size(), 'updating for Payment__c works wrong');
        Assert.areEqual(0, [SELECT Id FROM Task WHERE WhatId = :payments[0].Opportunity__c].size(), 'creation Task for Payment__c works wrong');
    }
    
    @isTest
    static void TestUpdateAmountPayment(){
        
        Payment__c payment = [SELECT Id, Name, Amount__c FROM Payment__c WHERE Name = 'Test1' LIMIT 1];

        payment.Amount__c = 10;
    	Test.startTest();
           update payment;
    	Test.stopTest();
        
        List<Payment__c> payments = [SELECT Id, Opportunity__c FROM Payment__c WHERE Name = 'Test1'];
    
    	Assert.areEqual(1, payments.size(), 'updating for Payment__c works wrong');
        Assert.areEqual(1, [SELECT Id FROM Task WHERE WhatId = :payments[0].Opportunity__c].size(), 'creation Task for Payment__c works wrong');
    }
    
    @isTest
    static void TestDeletePayment(){
        
        Payment__c payment = [SELECT Id FROM Payment__c LIMIT 1];

    	Test.startTest();
           delete payment;
    	Test.stopTest();
    
    	Assert.areEqual(2, [SELECT Id FROM Payment__c].size(), 'deletion for Payment__c works wrong');
    }
    
    @isTest
    static void TestUndeletePayment(){
        
        Payment__c payment = [SELECT Id, Opportunity__c FROM Payment__c WHERE Name = 'Test3' LIMIT 1 ALL ROWS];
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity3' LIMIT 1];
        insert new Payment__c(Name = 'Test', Opportunity__c = opp.Id, Amount__c = 10, FirstName__c = 'FTest3', LastName__c = 'Ltest3');
        
        
        Assert.areEqual(0, [SELECT Id FROM Task WHERE WhatId = :payment.Opportunity__c].size(), 'creation Task for Payment__c works wrong');

    	Test.startTest();
           undelete payment;
    	Test.stopTest();
    
    	Assert.areEqual(1, [SELECT Id FROM Payment__c WHERE Name = 'Test3'].size(), 'undeletion for Payment__c works wrong');
        Assert.areEqual(1, [SELECT Id FROM Task WHERE WhatId = :payment.Opportunity__c].size(), 'creation Task for Payment__c works wrong');
    }
}