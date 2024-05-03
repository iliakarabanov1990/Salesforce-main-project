trigger PaymentTrigger on Payment__c (after update, after insert, after delete, after undelete) {
    
    switch on Trigger.operationType {
        when AFTER_INSERT {
            PaymentTriggerHendler.handleAfterInsert(Trigger.newMap);
        }	
        when AFTER_UPDATE {		
            PaymentTriggerHendler.handleAfterUpdate(Trigger.newMap);
        }
        when AFTER_DELETE {
            PaymentTriggerHendler.handleAfterDelete(Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            PaymentTriggerHendler.handleAfterUndelete(Trigger.newMap);
        }
    }
}