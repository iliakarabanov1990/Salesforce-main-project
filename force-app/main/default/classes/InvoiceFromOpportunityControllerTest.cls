@isTest
public class InvoiceFromOpportunityControllerTest {
    
    @TestSetup
	static void testSetup() {
            
        Contact cont = new Contact(FirstName ='contactTest1', LastName='contactTest1');
        insert cont;      

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

        Account account = new Account(Name = 'Test Account');
        insert account;

        List<Opportunity> opps = new List<Opportunity>();
 		opps.add(new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = account.Id));
       	opps.add(new Opportunity(Name = 'Test Opportunity2', StageName = 'Prospecting', CloseDate = Date.today()));
        insert opps;

        OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opps[0].Id, PricebookEntryId = customPricebookEntry.Id, Quantity = 10, UnitPrice = customPricebookEntry.UnitPrice);
        insert opportunityProduct;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole(ContactId = cont.id, OpportunityId = opps[0].id, IsPrimary = true);     
        insert oppContRole;      
  	}
    
    @isTest
    static void TestController(){
        
      	Id oppId = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1][0].Id;
    
      	Test.StartTest(); 
			ApexPages.currentPage().getParameters().put('id', String.valueOf(oppId));
			InvoiceFromOpportunityController  testInvoiceContr = new InvoiceFromOpportunityController();
			Opportunity opp = testInvoiceContr.opportunity;
			testInvoiceContr.getContact();
        	testInvoiceContr.getProducts();
		Test.StopTest();
    }
    
      @isTest
    static void TestControllerWithoutCintactRole(){
        
      Id oppId = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity2' LIMIT 1][0].Id;
        
      Test.StartTest(); 
			ApexPages.currentPage().getParameters().put('id', String.valueOf(oppId));
			InvoiceFromOpportunityController testInvoiceContr = new InvoiceFromOpportunityController();
			Opportunity opp = testInvoiceContr.opportunity;
			testInvoiceContr.getContact();
        	testInvoiceContr.getProducts();
		Test.StopTest();
    }

}