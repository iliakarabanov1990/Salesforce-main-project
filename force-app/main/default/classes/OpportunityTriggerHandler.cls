public with sharing class OpportunityTriggerHandler{

    private boolean isExecuting = false;
    private integer batchSize = 0;
    
    public OpportunityTriggerHandler(boolean isExecuting, integer size)
    {
        this.isExecuting = isExecuting;
        batchSize = size;
    }

    public void OnBeforeDelete(List<Opportunity> oldOpps, Map<ID, Opportunity> oldOpptMap)
    {
        Set<Id> oppsId = oldOpptMap.keySet();
        Stash.pendDeleteAccounts = DeleteObjectsHelper.getAccounts(oppsId, true);
        Stash.pendDeleteContacts = DeleteObjectsHelper.getContacts(oppsId, true);
        
        Stash.pendDeleteCasesForAccounts = DeleteObjectsHelper.getCasesForAccounts(Stash.pendDeleteAccounts);
        Stash.pendDeleteCasesForContacts = DeleteObjectsHelper.getCasesForContacts(Stash.pendDeleteContacts);
    }
            

    public void OnAfterDelete(List<Opportunity> oldOpps, Map<ID, Opportunity> oldOpptMap)
    {        
        DeleteObjectsHelper.removeAccountFromCases(Stash.pendDeleteCasesForAccounts);   
        DeleteObjectsHelper.removeContactFromCases(Stash.pendDeleteCasesForContacts);
        DeleteObjectsHelper.deleteAccounts();  
        DeleteObjectsHelper.deleteContacts();     
    }

    public boolean IsTriggerContext
    {
        get{ return isExecuting;}
    }
    
}