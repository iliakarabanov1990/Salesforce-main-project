trigger OpportunityTrigger on Opportunity (before delete, after delete) {

    OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    switch on Trigger.operationType {
        when BEFORE_DELETE {
            handler.OnBeforeDelete(trigger.Old, trigger.OldMap);
        }
        when AFTER_DELETE {
            handler.OnAfterDelete(trigger.Old, trigger.OldMap);
        }
    }
}