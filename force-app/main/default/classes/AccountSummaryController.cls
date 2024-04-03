public with sharing class AccountSummaryController {

    @AuraEnabled(cacheable=true)
    public static List<List<SObject>> getData(String recordId){

        List<String> queryArray = new List<String>{
            'SELECT AccountId, Account.Name, Sum(Amount)',
            'FROM Opportunity',
            //'WHERE StageName = \'Closed Won\'' + (String.isEmpty(recordId) ? '' : ' AND AccountId = \'' + recordId + '\''),  
            'WHERE StageName = \'Closed Won\'' + (String.isEmpty(recordId) ? '' : ' AND AccountId = :recordId'),         
            'GROUP BY AccountId, Account.Name',
            'HAVING Sum(Amount) > 0',
            'ORDER BY Account.Name'
        };
        List<SObject> accList = Database.query(String.join(queryArray, ' '));
        
        queryArray = new List<String>{
            'SELECT Id, CreatedDate, CloseDate, Amount, AccountId, Name,', 
            '(SELECT Product2.Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItems) FROM Opportunity',
            //'WHERE StageName = \'Closed Won\'' + (String.isEmpty(recordId) ? '' : ' AND AccountId = \'' + recordId + '\''),
            'WHERE StageName = \'Closed Won\'' + (String.isEmpty(recordId) ? '' : ' AND AccountId = :recordId'),
            'ORDER BY CloseDate'
        };
        List<SObject> detailList = Database.query(String.join(queryArray, ' '));

        return new List<List<SObject>>{accList, detailList};
    }
}