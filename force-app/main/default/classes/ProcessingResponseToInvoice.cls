public class ProcessingResponseToInvoice implements Messaging.InboundEmailHandler{
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();      
        
        String subject = email.subject; 
        String body = email.plainTextBody.replace('>', '');
        body = body.replaceAll('\r\n|\n|\r', '');
        body = body.toLowerCase();
        body = body.replace('word approved to confirm the order, or the word rejected to reject the order', '');       
        
        Pattern patt = Pattern.compile('INV-\\d{6}');
        Matcher match = patt.matcher(subject);
        String invoiceNumber = '';
        if(match.find()) {
            invoiceNumber = match.group(0);
        }
        else{
            result.success = false;
            return result;
        }
        
        List<Opportunity> opps = [SELECT Id, StageName FROM Opportunity WHERE Invoice_Number__c = :invoiceNumber LIMIT 1];        
        String[] stages = new String[0];
        for(PicklistEntry value: Opportunity.StageName.getDescribe().getPicklistValues()) {
            stages.add(value.getValue());
        }
        
        if(opps.size()==0){
            result.success = false;
            return result;
        }
        
        Opportunity opp = opps[0];
        Integer stageNegotInd = stages.indexOf('Negotiation/Review'); 
        Integer currStInd = stages.indexOf(opp.StageName);
        if(currStInd > stageNegotInd){
            result.success = true;
            return result;    
        }
        
        if(body.contains('approved')){
            opp.StageName = stages[stageNegotInd+1];
        }
        else if(body.contains('rejected')){ 
            opp.StageName = 'Closed Lost';   
        }  
        else{
            result.success = false;
            return result;
        }
        
        update opp;
        result.success = true;
        
        return result;
        
        /*List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Invoice_Number__c = 'INV-000001' LIMIT 1];
        result.success = true;
        
        Opportunity opp = opps[0];
        opp.Description = email.plainTextBody;
        update opp;
        
        return result;*/
    }
}