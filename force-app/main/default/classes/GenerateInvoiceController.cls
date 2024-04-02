public class GenerateInvoiceController {
    
    @AuraEnabled  
    public static void GenerateInvoice(String recId) {
        
        String invoiceNumber = [SELECT Invoice_Number__c FROM Opportunity WHERE Id = :recId].Invoice_Number__c;
        List<ContentVersion> conVerExisting = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = :invoiceNumber ORDER BY LastModifiedDate DESC LIMIT 1];
        
        PageReference invoiceFromOpportunity = new PageReference('/apex/InvoiceFromOpportunity');
        invoiceFromOpportunity.getParameters().put('id', recId);
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = invoiceNumber + '.pdf';
        conVer.Title = invoiceNumber;
        if(Test.isRunningTest()){
            conVer.VersionData = blob.valueOf('Unit.Test');
        }else{
            conVer.VersionData = invoiceFromOpportunity.getContentAsPDF();
        }
        
        
        if(conVerExisting.size() > 0)
            conVer.ContentDocumentId = conVerExisting[0].ContentDocumentId;
        
        insert conVer;
        
        if(conVerExisting.size() == 0){
        	conVerExisting = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id];    
        
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recId;
            conDocLink.ContentDocumentId = conVerExisting[0].ContentDocumentId;
            conDocLink.shareType = 'I';
            conDocLink.Visibility = 'AllUsers';
            insert conDocLink;
        }
    }
    
}