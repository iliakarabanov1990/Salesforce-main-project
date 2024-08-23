public class Stash {  // Don't use statics in triggers. They behave oddly.
    private static Set<Account> setPendDeleteAccounts;
    private static Set<Contact> setPendDeleteContacts;
    private static Set<Case> setPendDeleteCasesForAccounts;
    private static Set<Case> setPendDeleteCasesForContacts;
    private static Set<Opportunity> setPendDeleteOpportunities;


    public static List<Account> pendDeleteAccounts{ 
        get {
            if(setPendDeleteAccounts == null)
                return null;
            return new List<Account>(setPendDeleteAccounts);
        } 
        set {
            if(value == null)
                setPendDeleteAccounts = null;
            else
                setPendDeleteAccounts = new Set<Account>(value); } 
      }  

      public static List<Contact> pendDeleteContacts{ 
        get {
            if(setPendDeleteContacts == null)
                return null;
            return new List<Contact>(setPendDeleteContacts); } 
        set {
            if(value == null)
                setPendDeleteContacts = null;
            else
                setPendDeleteContacts = new Set<Contact>(value); } 
      }

      public static List<Case> pendDeleteCasesForAccounts{ 
        get {
            if(setPendDeleteCasesForAccounts == null)
                return null;
            return new List<Case>(setPendDeleteCasesForAccounts); } 
        set {
            if(value == null)
                setPendDeleteCasesForAccounts = null;
            else
                setPendDeleteCasesForAccounts = new Set<Case>(value); } 
      }

      public static List<Case> pendDeleteCasesForContacts{ 
        get {
            if(setPendDeleteCasesForContacts == null)
                return null;
            return new List<Case>(setPendDeleteCasesForContacts); } 
        set {
            if(value == null)
                setPendDeleteCasesForContacts = null;
            else
                setPendDeleteCasesForContacts = new Set<Case>(value); } 
      }

      

      /*
      
      
      public static List<Opportunity> pendDeleteOpportunities{ 
        get {
            if(setPendDeleteOpportunities == null){
                return null;
            }
            return new List<Opportunity>(setPendDeleteOpportunities);
        } 
        set {
            if(value == null){
                setPendDeleteOpportunities = null;
            }
            setPendDeleteOpportunities = new Set<Opportunity>(value);
        } 
      }*/

}