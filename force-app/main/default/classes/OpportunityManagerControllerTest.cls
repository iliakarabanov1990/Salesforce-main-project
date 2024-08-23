@isTest
private class OpportunityManagerControllerTest {

    @TestSetup
	static void testSetup() {

        List<User> testUsers = new List<User>();

        Profile stProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        testUsers.add(new User(Alias = 'standt', Email='oWUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = stProfile.Id, City = 'Borisov',
            TimeZoneSidKey='America/Los_Angeles', UserName='oWUser@testorg.com'));

        testUsers.add(new User(Alias = 'standt', Email='oW2User@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = stProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='oW2User@testorg.com'));      

        insert testUsers;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 stdPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update stdPricebook;

        Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Price Book', IsActive = true);
        insert customPricebook;

        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TEST001', IsActive = true);
        insert product;

        PricebookEntry stdPricebookEntry = new PricebookEntry(Pricebook2Id = stdPricebook.Id, Product2Id = product.Id, UnitPrice = 100.0, IsActive = true);
        insert stdPricebookEntry;

        PricebookEntry customPricebookEntry = new PricebookEntry(Pricebook2Id = customPricebook.Id, Product2Id = product.Id, UnitPrice = 150.0, IsActive = true);
        insert customPricebookEntry;

        List<Account> accs = new List<Account>();
 		accs.add(new Account(Name = 'Test Account', UnDeletable__c = true));
        accs.add(new Account(Name = 'Test Account2'));
        insert accs;

        List<Contact> conts = new List<Contact>();
        conts.add(new Contact(LastName='cont1', UnDeletable__c = true));
        conts.add(new Contact(LastName='cont2'));
        insert conts;

        List<Case> cases = new List<Case>();
        cases.add(new Case(ContactId = conts[0].Id, AccountId = accs[0].Id));
        cases.add(new Case(ContactId = conts[1].Id, AccountId = accs[1].Id));
        insert cases;
        
        List<Opportunity> opps = new List<Opportunity>();
 		opps.add(new Opportunity(ContactId = conts[0].Id, AccountId = accs[0].Id, StageName='Closed Won', Name='1', CloseDate=System.today()));
        opps.add(new Opportunity(ContactId = conts[1].Id, AccountId = accs[1].Id, StageName='Closed Won', Name='2', CloseDate=System.today()));
        opps.add(new Opportunity(AccountId = accs[0].Id, StageName='Closed Won', Name='3', CloseDate=System.today()));
        opps.add(new Opportunity(ContactId = conts[0].Id, StageName='Closed Won', Name='4', CloseDate=System.today()));
   		insert opps;     
        
        OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opps[0].Id, PricebookEntryId = customPricebookEntry.Id, Quantity = 1, UnitPrice = customPricebookEntry.UnitPrice);
        insert opportunityProduct;

        List<Payment__c> payments = new List<Payment__c>();
        payments.add(new Payment__c(Amount__c=100, Opportunity__c=opps[0].Id));
   		insert payments;       
  	}
    
    @IsTest
	public static void testGetUsers() {

        List<User> usersDef = [SELECT Id FROM User];
		
        Test.startTest();
            List<User> users = OpportunityManagerController.getUsers(); 
        Test.stopTest();
        
        Assert.areEqual(usersDef.size(), users.size(), 'wrong result of OpportunityManagerController.getUsers');
    }

    @IsTest
	public static void testGetAccounts() {
        
        List<Account> accounts;
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
		
        Test.startTest();
            accounts = OpportunityManagerController.getAccounts(new List<Id>{opps[0].Id}); 
        Test.stopTest();
        
        Assert.areEqual(1, accounts.size(), 'wrong result of OpportunityManagerController.getAccounts');
    }

    @IsTest
	public static void testGetContacts() {

        List<Contact> contacts;
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
		
        Test.startTest();
            contacts = OpportunityManagerController.getContacts(new List<Id>{opps[0].Id}); 
        Test.stopTest();
        
        Assert.areEqual(1, contacts.size(), 'wrong result of OpportunityManagerController.getContacts');
    }

    @IsTest
	public static void testGetOpportunities() {
		
        List<Opportunity> opps;
        Test.startTest();
            opps = OpportunityManagerController.getOpportunities(); 
        Test.stopTest();
        
        Assert.areEqual(4, opps.size(), 'wrong result of OpportunityManagerController.getOpportunities');
    }

    @IsTest
	public static void testGetOpportunitiesAmount() {
		
        Test.startTest();
        Map<String, Decimal> amounts = OpportunityManagerController.getOpportunitiesAmount(); 
        Test.stopTest();
        
        Assert.areEqual(2, amounts.size(), 'wrong result of OpportunityManagerController.getOpportunitiesAmount');
        Assert.areEqual(100, amounts.get('payment'), 'wrong payment of OpportunityManagerController.getOpportunitiesAmount');
        Assert.areEqual(50, amounts.get('rest'), 'wrong payment of OpportunityManagerController.getOpportunitiesAmount');
    }

    @IsTest
	public static void testDeleteOpportunities() {

        List<Opportunity> opps = [SELECT Id FROM Opportunity];
		
        Test.startTest();
        Map<String, String> res = OpportunityManagerController.deleteOpportunities(new List<Id>{opps[0].Id, opps[1].Id, opps[2].Id, opps[3].Id}); 
        List<Opportunity> oppsAfter = [SELECT Id FROM Opportunity];
        List<Account> accs = [SELECT Id FROM Account];
        List<Contact> conts = [SELECT Id FROM Contact];
        List<Case> cases = [SELECT Id FROM Case WHERE AccountId != null AND ContactId != null];    
        Test.stopTest();
      
        Assert.areEqual(0, oppsAfter.size(), 'wrong opps of OpportunityManagerController.deleteOpportunities');
        Assert.areEqual(1, accs.size(), 'wrong accaunts of OpportunityManagerController.deleteOpportunities');
        Assert.areEqual(1, conts.size(), 'wrong contacts of OpportunityManagerController.deleteOpportunities');
        Assert.areEqual(1, cases.size(), 'wrong cases of OpportunityManagerController.deleteOpportunities');
    }

    @IsTest
	public static void testSetUndeleteableAcc() {

        List<Account> accs = [SELECT Id FROM Account];
        Map<String, String> accsMap = new Map<String, String>{accs[0].Id => 'true'};		
		
        Test.startTest();
        OpportunityManagerController.setUndeleteableAcc(accsMap); 
        Test.stopTest();

        List<Account> accsAfter = [SELECT Id FROM Account WHERE UnDeletable__c = true];
        
        Assert.areEqual(1, accsAfter.size(), 'OpportunityManagerController.deleteOpportunities doesn\'t work');
    }

    @IsTest
	public static void testSetUndeleteableCont() {

        List<Contact> conts = [SELECT Id FROM Contact];
        Map<String, String> contsMap = new Map<String, String>{conts[1].Id => 'true'};		
		
        Test.startTest();
        OpportunityManagerController.setUndeleteableCont(contsMap); 
        Test.stopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact WHERE UnDeletable__c = true];
        
        Assert.areEqual(2, contactsAfter.size(), 'OpportunityManagerController.setUndeleteableCont doesn\'t work');
    }

    @IsTest
	public static void testAssignOpportunities(){

        List<User> users = [SELECT Id FROM User WHERE LastName='Testing'];
        List<Opportunity> opps = [SELECT Id FROM Opportunity];

        Test.startTest();
        Map<String, String> res = OpportunityManagerController.assignOpportunities(new List<Id>{opps[0].Id}, new List<Id>{users[0].Id}, 'Read'); 
        List<OpportunityShare> shares = [SELECT Id FROM OpportunityShare WHERE UserOrGroupId IN (SELECT Id FROM USER WHERE LastName='Testing')];
        Test.stopTest();
        
        Assert.areEqual(1, shares.size(), 'wrong assign in OpportunityManagerController.testAssignOpportunities');   
    }
}