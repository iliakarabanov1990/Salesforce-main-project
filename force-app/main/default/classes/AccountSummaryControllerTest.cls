@isTest
public class AccountSummaryControllerTest {

	@TestSetup
	static void testSetup() {

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
 		accs.add(new Account(Name = 'Test Account'));
        accs.add(new Account(Name = 'Test Account2'));
        insert accs;

        List<Opportunity> opps = new List<Opportunity>();
 		opps.add(new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today(), AccountId = accs[0].Id, Amount = 1000));
       	opps.add(new Opportunity(Name = 'Test Opportunity2', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = accs[1].Id));
        insert opps;

        OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opps[0].Id, PricebookEntryId = customPricebookEntry.Id, Quantity = 10, UnitPrice = customPricebookEntry.UnitPrice);
        insert opportunityProduct;
 
  	}  
    
    @isTest
    static void TestSendEmail(){

    	Test.startTest();
           List<List<SObject>> arr = AccountSummaryController.getData('');
    	Test.stopTest();
    
    	Assert.areEqual(2, arr.size(), 'wrong size of result list');
        Assert.areEqual(1, arr[0].size(), 'wrong size of acc list');
        Assert.areEqual(1, arr[1].size(), 'wrong size of opp list');
    }
}