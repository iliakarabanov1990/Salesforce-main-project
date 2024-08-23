public with sharing class BatchDeleteOpportunity{}
/*public with sharing class BatchDeleteOpportunity implements Database.Batchable<Object>, Database.Stateful {

    private Id oppId;
    private List<Id> opps;
    private String message;

    public BatchDeleteOpportunity(List<Id> opps, String message) {
        this.oppId = opps.remove(opps.size()-1);
        this.opps = opps;
        this.message = message;
    }

    public Iterable<Object> start(Database.BatchableContext bc){

        List<Object> commonList = new List<Object>();

        List<Contact> contacts = DeleteObjectsHelper.getContactsLinkedToOportunity(oppId);
        List<Account> accounts = DeleteObjectsHelper.getAccountLinkedToOportunity(oppId);
        List<Opportunity> opportunities = DeleteObjectsHelper.getOpportunitiesLinkedToAccount(accounts);

        commonList.add(opportunities);
        commonList.add(accounts);
        commonList.addAll(contacts);       

        return (Iterable<Object>)commonList;
    }

    public void execute(Database.BatchableContext batchableContext, List<Object> scope){

        for(Object obj: scope){
            if (obj instanceof List<Opportunity>){
                message += DeleteObjectsHelper.deleteOpportunities((List<Opportunity>)obj);
            }
            else if(obj instanceof List<Account>){
                message += DeleteObjectsHelper.coscadeDeleteAccount((List<Account>)obj);
            }
            else {
                Contact cont = (Contact)obj;
                message += DeleteObjectsHelper.coscadeDeleteContact(cont.Id);
            }
        }
    }

    public void finish(Database.BatchableContext bc){

        if(opps.size() == 0){
            //Email
            return;  
        }

        Database.executeBatch(new BatchDeleteOpportunity(opps, message), 1);
    }
}*/