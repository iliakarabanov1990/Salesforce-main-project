public with sharing class UniversalScheduler implements Schedulable {

    private String batchClass;

    public UniversalScheduler(String batchClass) {
        this.batchClass = batchClass;
    }

    public void execute(SchedulableContext schedCont) {

        Id batchJobId;    
        Type classType = Type.forName(this.batchClass);
         
        if (classType != null){
            batchJobId = Database.executeBatch((Database.Batchable<sObject>)classType.newInstance());
        }
    }
}