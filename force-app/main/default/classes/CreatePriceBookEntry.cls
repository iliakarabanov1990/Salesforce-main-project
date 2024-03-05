public class CreatePriceBookEntry {
    
    public static void Create(){
        List<PriceBookEntry> entries = new List<PriceBookEntry>();     
        List<PriceBookEntry> entriesSt = new List<PriceBookEntry>();
        List<Product2> products = new List<Product2>([SELECT Id FROM Product2]);
        Map<Id, Product2> prodInStPrices = new Map<Id, Product2>([SELECT Id, Name FROM product2 WHERE Id in (SELECT product2Id FROM PricebookEntry WHERE Pricebook2Id='01sF9000002LBekIAG')]);
        
        Integer i = 1;
        Integer j = 1;
        for(Product2 product : products) {
            
            double price = Math.random() * 1000;
            
            entries.add(new PriceBookEntry(
                Product2Id = product.Id, 
                Pricebook2Id = '01sF9000002LrcfIAC', 
                UnitPrice = price, 
                IsActive = true));  
            System.debug('new entry ' + product.Id);
            i++;
            
            if(!prodInStPrices.containsKey(product.Id)){
                entriesSt.add(new PriceBookEntry(
                Product2Id = product.Id, 
                Pricebook2Id = '01sF9000002LBekIAG', 
                UnitPrice = price, 
                IsActive = true));  
                System.debug('prodInStPrices ' + product.Id);
                j++;
            }
        }
        insert entriesSt;
        insert entries;
        
        System.debug('mine and default ' + i);
        System.debug('mine ' + j);
    }
	
}