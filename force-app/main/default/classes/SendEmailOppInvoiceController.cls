public with sharing class SendEmailOppInvoiceController {
    
    @AuraEnabled(cacheable=true)
    // Get data from opportunity (by recordId), from organization (by UserInfo), from email template by id = 00XF9000001R4pXMAS
    public static Map<String, String> getEmailData(String recordId) {

        Map<String, String> result = new Map<String, String>();
        result.put('subject', '');
        result.put('body', '');
        result.put('fileTitle', '');
        result.put('fileId', '');
        result.put('conVerId', '');     
        result.put('recipientName', '');
        result.put('fromAddress', '');
        result.put('recipientEmail', '');
        result.put('recipientCompany', '');
        result.put('invoiceNumber', '');
        result.put('oppOwner', '');
        result.put('orgName', [SELECT Name FROM Organization WHERE Id = :UserInfo.getOrganizationId()].Name);

        OrgWideEmailAddress[] owea = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName = 'SalesDepartment'];
        if(owea.size() > 0){
            result.put('fromAddress', owea[0].Address); 
        }
       
        List<Opportunity> oppList = [SELECT Invoice_Number__c, Owner.Name FROM Opportunity WHERE Id = :recordId];
        if(oppList.size() > 0){
            String invoiceNumber = oppList[0].Invoice_Number__c;
            result.put('fileTitle', invoiceNumber + '.pdf');
            result.put('invoiceNumber', invoiceNumber);
            result.put('oppOwner', oppList[0].Owner.Name);
          
            List<ContentVersion> conVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = :invoiceNumber ORDER BY LastModifiedDate DESC LIMIT 1];
            if(conVer.size() > 0){
                result.put('fileId', conVer[0].ContentDocumentId);
                result.put('conVerId', conVer[0].Id);
            }
        }
        
        List<Contact> contacts = [  SELECT Email, Name, Account.Name  
                                    FROM Contact 
                                    WHERE Id IN (SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :recordId AND IsPrimary = true) LIMIT 1];
        if(contacts.size() > 0){
            result.put('recipientName', contacts[0].Name);
            result.put('recipientEmail', contacts[0].Email);
            result.put('recipientCompany', contacts[0].Account.Name);
        }


        List<EmailTemplate> temlList = [SELECT Body, Name, Subject, HTMLValue FROM EmailTemplate WHERE Name = 'InvoiceFromOpporunity' AND IsActive= true];

        if(temlList.size() > 0){
            String subject = temlList[0].Subject.replace('{{{invoiceNumber}}}', result.get('invoiceNumber'))
                                .replace('{{{orgName}}}', result.get('orgName'));
            String body =  temlList[0].HTMLValue.replace('{{{invoiceNumber}}}', result.get('invoiceNumber'))  
                               .replace('{{{recipientName}}}', result.get('recipientName'))
                                    .replace('{{{oppOwner}}}', result.get('oppOwner'));
            result.put('subject', subject);
            result.put('body', body);
        }

        return result;
    }

    @AuraEnabled
    //Send email by infomation from LWC form with pdf invoice attached to opportunity
    public static void sendEmail(String fromAddress, String toAddress, String subject, String body, String fileTitle, String conVerId) {
       
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :fromAddress];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }

        mail.setToAddresses(new List<String>{ toAddress });
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mail.setBccSender(false);
        mail.setUseSignature(false);   
        mail.setEntityAttachments(new List<String>{conVerId});    

        Messaging.sendEmail(new List<Messaging.Email> { mail });
    }
}