@isTest()
public class CreatePriceBookEntryTest {
  	 
    //prepare data
    @testSetup static void CreateData(){      
        Test.startTest();
           
        Pricebook2 pB = new Pricebook2(Name = 'First');
        Product2 product = new Product2(Name = 'prod');
        insert pB;
        insert product;
   
        Test.stopTest();
    }
    
    //test contact creating (!one for all because the test data is retrieved using SOQL and I wanted to get it in one query)
    @isTest static void TestCreateContactWithCase() { 
        Test.startTest();     
        CreatePriceBookEntry.Create();
        Test.stopTest();   
      
        Map<Id, PricebookEntry> prBook = new Map<Id, PricebookEntry>([SELECT product2Id FROM PricebookEntry]);     
        System.assertEquals(2, prBook.size(), 'No price has been created for the product');
	}
}