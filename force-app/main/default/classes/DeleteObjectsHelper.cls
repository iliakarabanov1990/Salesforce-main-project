public with sharing class DeleteObjectsHelper {

    public static List<Contact> getContacts(Set<Id> oppIds, Boolean onlyDeleteable){

        String strOnlyDeleteable = onlyDeleteable ? 'AND UnDeletable__c = false ' : '';
        String queries = 
            'SELECT Id, UnDeletable__c, Name ' + 
            'FROM Contact ' +  
            'WHERE Id IN (SELECT ContactId FROM Opportunity WHERE Id IN :oppIds) ' + 
            strOnlyDeleteable + 
            'ORDER BY Name ';

        List<Contact> contacts = Database.queryWithBinds(queries, new Map<String, Object>{'oppIds' => oppIds}, accessLevel.USER_MODE);

        queries = 
            'SELECT Id, UnDeletable__c, Name ' +  
            'FROM Contact ' +
            'WHERE Id IN (SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId IN :oppIds) ' +
            'AND Id NOT IN :contacts ' + 
            strOnlyDeleteable +
            'ORDER BY Name ';

        contacts.addAll((List<Contact>)Database.queryWithBinds(queries, new Map<String, Object>{'oppIds' => oppIds, 'contacts' => contacts}, accessLevel.USER_MODE));

        return contacts;
    }

    public static List<Account> getAccounts(Set<Id> OppIds, Boolean onlyDeleteable){

        String strOnlyDeleteable = onlyDeleteable ? 'AND UnDeletable__c = false ' : '';
        String queries = 
        'SELECT Id, UnDeletable__c, Name ' +
        'FROM Account ' +  
        'WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :OppIds) ' + 
        strOnlyDeleteable +
        'ORDER BY Name ';

        return Database.queryWithBinds(queries, new Map<String, Object>{'OppIds' => OppIds}, accessLevel.USER_MODE);
    }

    public static List<Case> getCasesForAccounts(List<Account> accounts){

        return 
            [SELECT Id 
            FROM Case 
            WHERE AccountId IN :accounts];
    }

    public static List<Case> getCasesForContacts(List<Contact> contacts){

        return 
            [SELECT Id 
            FROM Case 
            WHERE ContactId IN :contacts];
    }

    public static void deleteAccounts(){
        
        if(Stash.pendDeleteAccounts == null) {
            return;
        }

        List<Account> accounts = Stash.pendDeleteAccounts;
        Stash.pendDeleteAccounts = null;

        delete accounts;
    }

    public static void deleteContacts(){

        if(Stash.pendDeleteContacts == null) {
            return;
        }

        List<Contact> contacts = Stash.pendDeleteContacts;
        Stash.pendDeleteContacts = null;
        system.debug('deleteContacts contacts 2' + contacts);
        delete contacts;
    }

    public static void removeAccountFromCases(List<Case> cases){

        for(Case cas : cases)
            cas.AccountId = null;

        update cases;
    }

    public static void removeContactFromCases(List<Case> cases){
        
        for(Case cas : cases)
            cas.ContactId = null;

        update cases;
    }

    public static Map<String, String> deleteOpportunities(List<Id> opps){

        String message = '';
        String status = 'success';
        List<Database.DeleteResult> results = Database.delete(opps, false);
        for (Database.DeleteResult result: results){
            if (!result.isSuccess()){
                status = 'error';     
                for(Database.Error err : result.getErrors()) {
                    message += err.getMessage();
                }
            }
        }

        message = message == '' ? 'success' : message;

        return new Map<String, String>{'status' => status, 'message' => message};
    }
}