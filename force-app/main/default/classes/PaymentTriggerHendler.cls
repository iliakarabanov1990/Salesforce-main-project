public class PaymentTriggerHendler {
    
    public static void handleAfterInsert(Map<Id, Payment__c> payments){
        Set<Id> oppIds = PaymentTriggerHendler.getOppIdByPaymentsId(payments.keySet());
        PaymentTriggerHendler.processPaymentChange(oppIds, 'Inserts');       
    }
    
    public static void handleAfterUpdate(Map<Id, Payment__c> payments){
        Set<Id> oppIds = PaymentTriggerHendler.getOppIdByPaymentsId(payments.keySet());
        PaymentTriggerHendler.processPaymentChange(oppIds, 'Update');       
    }
    
    public static void handleAfterDelete(Map<Id, Payment__c> payments){
        Set<Id> oppIds = PaymentTriggerHendler.getOppIdByPayments(payments.values());
        PaymentTriggerHendler.processPaymentChange(oppIds, 'Delete');       
    }
    
    public static void handleAfterUndelete(Map<Id, Payment__c> payments){
        Set<Id> oppIds = PaymentTriggerHendler.getOppIdByPaymentsId(payments.keySet());
        PaymentTriggerHendler.processPaymentChange(oppIds, 'Undelete');       
    }
    
    public static void processPaymentChange(Set<ID> oppSet, String Descr){
         Map<ID, Opportunity> oppsForUpd = new Map<ID, Opportunity>(
           [SELECT 
            	Payment_Status__c, 
            	Amount, 
            	(SELECT Contact.OwnerId FROM OpportunityContactRoles WHERE IsPrimary = TRUE LIMIT 1)
         	FROM Opportunity
            WHERE Id IN :oppSet
           ]);
        List<AggregateResult> oppWithfPayments = [
                SELECT Opportunity__c, SUM(Amount__c) SumAmount 
                FROM Payment__c 
                WHERE Opportunity__c IN :oppsForUpd.keySet()  
                GROUP BY Opportunity__c
            ];
        
        for(AggregateResult oppSum: oppWithfPayments){
           
            Opportunity opp = oppsForUpd.get((ID)oppSum.get('Opportunity__c'));
            Decimal oppSumAmount = (Decimal)oppSum.get('SumAmount');
            if(opp.Amount <= oppSumAmount){
                if(opp.Payment_Status__c != 'Fully Paid'){
                    opp.Payment_Status__c = 'Fully Paid';
                    Date remindDate = System.today().addDays(2);
                    Time remindTime = Time.newInstance(10, 0, 0, 0);
                    List<OpportunityContactRole> contacts = opp.OpportunityContactRoles;
                    if(contacts.size() > 0){ 
                        PaymentTriggerHendler.createTask(contacts[0].Contact.OwnerId, 'High', 'Not Started', 'Delivery of goods', DateTime.newInstance(remindDate, remindTime), opp.Id, '');
                    }
                }
            }            
            else if(oppSumAmount == 0)
                opp.Payment_Status__c = 'Unpaid';
            else
                opp.Payment_Status__c = 'Partially Paid'; 
            
            
            opp.Description = Descr + ' oppAmount ' + opp.Amount +  'oppSumAmount ' + oppSumAmount;
        }
        
        update oppsForUpd.values();
    }
    
    private static void createTask(ID OwnerId, String Priority, String Status, String Subject, DateTime ReminderDateTime, Id WhatId, String Description){
        
        Task newTask = new Task(
            OwnerId = OwnerId,
            WhatId = WhatId,   	
        	Priority = Priority,
        	Status = Status,
        	Subject = Subject,
            Description = Description,
        	IsReminderSet = true,
        	ReminderDateTime = ReminderDateTime
        	);
        insert newTask;
    }  
    
    private static Set<Id> getOppIdByPayments(List<Payment__c> payments){
        Set<Id> opps = new Set<Id>();
        for(Payment__c p : payments)
        	opps.add(p.Opportunity__c); 
        
        return opps;
    } 
    
    private static Set<Id> getOppIdByPaymentsId(Set<Id> payments){
        return new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Id in (SELECT Opportunity__c FROM Payment__c WHERE Id IN :payments)]).keySet();
    } 
    
}