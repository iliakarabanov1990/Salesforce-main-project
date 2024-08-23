import { LightningElement, api, wire } from 'lwc';
import executeBatchByName from '@salesforce/apex/ScheduleHelper.executeBatchByName';
import setSchedulerByBatchName from '@salesforce/apex/ScheduleHelper.setSchedulerByBatchName';
import getDataSchedulerByName from '@salesforce/apex/ScheduleHelper.getDataSchedulerByName';
import getDataSchedulerById from '@salesforce/apex/ScheduleHelper.getDataSchedulerById';
import abortJob from '@salesforce/apex/ScheduleHelper.abortJob';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ScheduleController extends LightningElement {

    //@api schedulerClass;
    @api batchClass;
    
    title = '';
    cronString = '';
    cronDisabled = false;
    batchId;

    scheduleButtonVariant = "brand";
    scheduleButtonLabel = "Schedule Batch";
    schedulerId;
    schedulerState;
    schedulerTimesTriggered;
    schedulerNextFireTime;

    @wire(getDataSchedulerByName, { schedulerName: '$batchClass' })
    wiredGetDataSchedulerByName({ error, data }) {
        if (data)
            this.fillSchedulerData(data);
        else if (error)
            this.showToast('Error', JSON.stringify(error), 'error');
    }

    handleRunOnce(event){
        this.executeBatch(event);
    }

    handleCronChange(event) {
        this.cronString = event.target.value;
    }

    handleScheduleButton(event){
        console.log('schedulerId: ' + this.schedulerId);
        console.log('chech: ' + !!this.schedulerId);
        if(!!this.schedulerId){
            this.abortScheduler();
            console.log('processAbortBatch');
        }                      
        else {
            this.setScheduler(); 
            console.log('processScheduleBatch');
        }              
    }

    executeBatch(){
        executeBatchByName({ className: this.batchClass})
            .then(data => {
                this.batchId = data;
                this.showToast('Success', 'Batch has been launched!', 'success');
            })
            .catch(error => this.showToast('Error', JSON.stringify(error), 'error'));    
    }

    setScheduler(){
        setSchedulerByBatchName({ schedulerName: this.batchClass, className: this.batchClass, cron: this.cronString}) 
            .then(data => this.schedulerId = data)
            .then(() => getDataSchedulerById({schedulerId: this.schedulerId}))
            .then(data => this.fillSchedulerData(data))
            .catch(error => {
                this.showToast('Error', JSON.stringify(error), 'error');
                console.log(error);
            });       
    }

    abortScheduler(event){
        abortJob({ jobId: this.schedulerId})
        .then(data => this.fillSchedulerData([{Id: '', State: '', TimesTriggered: '', NextFireTime: '', CronExpression: ''}]))
        .catch(error => this.showToast('Error', JSON.stringify(error), 'error'));    
    }

    fillSchedulerData(data){
        data.forEach(el => {
            this.schedulerId = el.Id;
            this.schedulerState = el.State;
            this.schedulerTimesTriggered = el.TimesTriggered;
            this.schedulerNextFireTime = el.NextFireTime;
            this.cronString = el.CronExpression;

            if(!!this.schedulerId){
                this.scheduleButtonVariant = "destructive";            
                this.scheduleButtonLabel = "Abort Batch";
                this.cronDisabled = true;     
            }
            else{
                this.scheduleButtonVariant = "brand";
                this.scheduleButtonLabel = "Schedule Batch";
                this.cronDisabled = false;              
            }
        })
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}