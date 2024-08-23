public with sharing class OpportunityManagerController {

    @AuraEnabled(cacheable=true)
    public static List<User> getUsers(){
        return [SELECT Id, Username FROM User];
    }

    @AuraEnabled
    public static List<Account> getAccounts(List<Id> oppIds){
        return DeleteObjectsHelper.getAccounts(new Set<Id>(oppIds), false);
    }

    @AuraEnabled
    public static List<Contact> getContacts(List<Id> oppIds){
        return DeleteObjectsHelper.getContacts(new Set<Id>(oppIds), false);
    }

    @AuraEnabled
    public static List<Opportunity> getOpportunities(){

        return [SELECT Id, CreatedDate, CloseDate, Amount, Account.Name, Name
                FROM Opportunity
                ORDER BY CloseDate DESC];
    }

    @AuraEnabled
    public static Map<String, Decimal> getOpportunitiesAmount(){

        Map<String, Decimal> result = new Map<String, Decimal>{'payment' => 0, 'rest' => 0}; 
        List<AggregateResult> oppsAmount =  [
            SELECT  
            SUM(Amount) Amount
            FROM Opportunity
            WHERE StageName = 'Closed Won'
           ];
        List<AggregateResult> paymentsAmount = [
                SELECT SUM(Amount__c) Amount 
                FROM Payment__c 
                WHERE Opportunity__c IN (SELECT Id FROM Opportunity WHERE StageName = 'Closed Won')];

        if(oppsAmount.size() > 0 && paymentsAmount.size() > 0){
            result.put('payment', (Decimal)paymentsAmount[0].get('Amount')); 
            result.put('rest', (Decimal)oppsAmount[0].get('Amount') - (Decimal)paymentsAmount[0].get('Amount'));    
        }
        return result;
    }
    
    @AuraEnabled
    public static Map<String, String> assignOpportunities(List<Id> opps, List<Id> users, String accessLevel){

        List<OpportunityShare> opportunityShrs = new List<OpportunityShare>();
        for(Id userId: users){ 
            opportunityShrs.addAll(OpportunityManagerController.createOpportunitySharesForUser(userId, opps, accessLevel));
        }

        List<Database.SaveResult> results  = Database.insert(opportunityShrs);
        Map<String, String> assigngResult = new Map<String, String>{'status' => 'success', 'message' => ''};
        String mess = '';

        for(Database.SaveResult result: results){
            if(!result.isSuccess()){
                Database.Error err = result.getErrors()[0];

                if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  && 
                    err.getMessage().contains('AccessLevel')){
                        mess = 'Access level must be more permissive than the object\'s default' + '\r\n'
                                + 'Some of these sharing records are not required and thus an insert exception is acceptable';
                }
                else{
                    assigngResult.put('status', 'error');
                    mess = err.getMessage();
                }
                
                assigngResult.put('message', assigngResult.get('message') + mess + '\r\n');
            }
        }

        return assigngResult;
    }

    @AuraEnabled
    public static Map<String, String> deleteOpportunities(List<Id> opps){

        return DeleteObjectsHelper.deleteOpportunities(opps);   
    }

    @AuraEnabled
    public static void setUndeleteableAcc(Map<String, String> accs){

        List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :accs.keySet()];
        for(Account acc: accounts){
            acc.UnDeletable__c = accs.get(acc.Id) == 'true';         
        } 

        update accounts;
    }

    @AuraEnabled
    public static void setUndeleteableCont(Map<String, String> conts){

        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN :conts.keySet()];
        for(Contact cont: contacts){
            cont.UnDeletable__c = conts.get(cont.Id) == 'true';         
        } 

        update contacts;
    }

    private static List<OpportunityShare> createOpportunitySharesForUser(Id userId, List<Id> opps, String accessLevel){
        List<OpportunityShare> opportunityShrs  = new List<OpportunityShare>();
        for(Id oppId: opps){
            OpportunityShare opportunityShr  = new OpportunityShare();       
            opportunityShr.OpportunityId = oppId;
            opportunityShr.UserOrGroupId = userId;
            opportunityShr.OpportunityAccessLevel = accessLevel;                  
            opportunityShr.RowCause = Schema.OpportunityShare.RowCause.Manual; 
            opportunityShrs.add(opportunityShr);          
        }

        return opportunityShrs;
    }
}