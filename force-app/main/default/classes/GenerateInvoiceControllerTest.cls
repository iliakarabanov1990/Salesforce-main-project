@IsTest
public class GenerateInvoiceControllerTest {
    
    @TestSetup
	static void testSetup() {
        
        List<Opportunity> opps = new List<Opportunity>();
 		opps.add(new Opportunity(StageName='Negotiation/Review', Name='first', CloseDate=System.today()));
        opps.add(new Opportunity(StageName='Negotiation/Review', Name='second', CloseDate=System.today()));
   		insert opps;       
        
        String invoiceNumber = [SELECT Invoice_Number__c FROM Opportunity WHERE Id = :opps[0].Id].Invoice_Number__c;
        ContentVersion contentVersion = new ContentVersion(Title = invoiceNumber, PathOnClient = 'pdf.pdf', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
      	insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.LinkedEntityId = opps[0].Id;
		cdl.ContentDocumentId = documents[0].Id;
		cdl.ShareType = 'I';
		cdl.Visibility = 'AllUsers';
		insert cdl;
  	}
    
    @IsTest
	public static void TestGeneration() {
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'first'];
        Test.startTest();
        	GenerateInvoiceController.GenerateInvoice(opp.Id); 
        Test.stopTest();
        
        Assert.areEqual(1, [SELECT Id FROM ContentDocument].size(), 'wrong creation file, new document was created, although it is already existed');
    }
    
    @IsTest
	public static void TestGenerationWithoutExistedDocument() {
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'second'];
        Test.startTest();
        	GenerateInvoiceController.GenerateInvoice(opp.Id); 
        Test.stopTest();
        
        Assert.areEqual(2, [SELECT Id FROM ContentDocument].size(), 'wrong creation file, new document was not created, although it is\'t existed');
    }
}