public class InvoiceFromOpportunityController {
    
 	private Opportunity opp;
    private Contact contact;
    private List<OpportunityLineItem> products;
    
 	//to fill info Amount, Owner.Name, Invoice_Number__c   
    public Opportunity opportunity {
        get{
            if(opp == null)
      		opp = [SELECT Amount, Owner.Name, Invoice_Number__c 
                   FROM Opportunity 
                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        	return opp;         
        }
    }  
    
    //to fill bill section
    public Contact getContact() {
        if(contact == null){
      		List<Contact> contacts = [SELECT Email, Name, Account.Name, Phone  
                       FROM Contact 
                       WHERE Id IN (SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :ApexPages.currentPage().getParameters().get('id') AND IsPrimary = true) LIMIT 1];
       
        if(contacts.size()==0)
            contact = new Contact();
        else
         	contact = contacts[0];   
        }
        return contact;
    }  

    //to fill the product table
    public List<OpportunityLineItem> getProducts() {
        if(products == null)
      		products = [SELECT Product2.Name, Quantity, UnitPrice, TotalPrice 
                        FROM OpportunityLineItem 
                        WHERE OpportunityId = :ApexPages.currentPage().getParameters().get('id')];
        return products;
    }  
}