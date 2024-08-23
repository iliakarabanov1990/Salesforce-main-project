public with sharing class AccountTriggerHandler {

    /*private boolean isExecuting = false;
    private integer batchSize = 0;
    
    public AccountTriggerHandler(boolean isExecuting, integer size)
    {
        this.isExecuting = isExecuting;
        batchSize = size;
    }

    public void OnBeforeDelete(List<Account> oldAccs, Map<ID, Account> oldAccMap)
    {       
        List<Case> cases = DeleteObjectsHelper.getCasesForAccounts(oldAccMap.keySet());
        DeleteObjectsHelper.removeAccountFromCases(cases);        
    }          

    public boolean IsTriggerContext
    {
        get{ return isExecuting;}
    }*/
}