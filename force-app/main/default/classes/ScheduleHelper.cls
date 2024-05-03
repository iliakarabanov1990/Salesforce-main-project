public class ScheduleHelper {

    @AuraEnabled 
    public static Id executeBatchByName(String className){
    	
    	Id batchJobId;    
        Type classType = Type.forName(className);
         
        if (classType != null){
            batchJobId = Database.executeBatch((Database.Batchable<sObject>)classType.newInstance());
        }
        
        return batchJobId;
    }
    
	@AuraEnabled
	public static Id setSchedulerByName(String className, String Cron){
    	
		Id batchJobId;    
        Type classType = Type.forName(className);
         
        if (classType != null){
            batchJobId = System.Schedule(className, Cron, (Schedulable)classType.newInstance());
        }
        
        return batchJobId;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CronTrigger> getDataSchedulerById(Id schedulerId){       
        return [SELECT State, TimesTriggered, NextFireTime, CronExpression FROM CronTrigger WHERE id = :schedulerId LIMIT 1];       
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CronTrigger> getDataSchedulerByName(String schedulerName){       
        return [SELECT Id, State, TimesTriggered, NextFireTime, CronExpression 
                FROM CronTrigger 
                WHERE cronJobDetailId IN (SELECT Id FROM CronJobDetail WHERE Name = :schedulerName) 
                LIMIT 1];      
    }
    
    @AuraEnabled
    public static void abortJob(Id jobId){
        System.abortJob(jobId);
    }
}