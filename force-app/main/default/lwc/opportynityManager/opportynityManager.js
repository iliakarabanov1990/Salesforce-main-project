import { LightningElement, track } from 'lwc';

import assignOpportunities from '@salesforce/apex/OpportunityManagerController.assignOpportunities';
import deleteOpportunities from '@salesforce/apex/OpportunityManagerController.deleteOpportunities';
import getUsers from '@salesforce/apex/OpportunityManagerController.getUsers';
import getOpportunitiesAmount from '@salesforce/apex/OpportunityManagerController.getOpportunitiesAmount';
import getOpportunities from '@salesforce/apex/OpportunityManagerController.getOpportunities';
import getContacts from '@salesforce/apex/OpportunityManagerController.getContacts';
import getAccounts from '@salesforce/apex/OpportunityManagerController.getAccounts';

import setUndeleteableAcc from '@salesforce/apex/OpportunityManagerController.setUndeleteableAcc';
import setUndeleteableCont from '@salesforce/apex/OpportunityManagerController.setUndeleteableCont';
    
import ChartJs from '@salesforce/resourceUrl/ChartJs';
import { loadScript } from 'lightning/platformResourceLoader';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportynityManager extends LightningElement {
    
    currentPageOpp = 1;
    currentPageAcc = 1;
    currentPageCont = 1;
    pageSizeOpp = 4;
    pageSizeAcc = 4;
    pageSizeCont = 4;
    @track displayedDataOpp = [];
    @track displayedDataAcc = [];
    @track displayedDataCont = [];
    @track chartData;
    isChartJsInitialized = false;

    accessLevel;
    picklistAccessesLevels;
    picklistUsers;
    users;
    selectedOpps;
    isModalOpen;
    isModalAccOpen;
    isModalContOpen;
    columns;
    opportunities;
    opportunitiesId;
    
    accounts;
    accountColumns;
    contacts;
    contactColumns;
    selectedAccs;
    selectedConts;

    preSelectedContacts;
    //preSelectedAccounts;

    preSelectedAccs;
    preSelectedConts;

    get disablePreviousOpp() {
        return this.currentPageOpp === 1;
    }

    get disablePreviousAcc() {
        return this.currentPageAcc === 1;
    }

    get disablePreviousCont() {
        return this.currentPageCont === 1;
    }
    
    get disableNextOpp() {
        return this.currentPageOpp === Math.ceil(this.opportunities.length / this.pageSizeOpp);
    }

    get disableNextAcc() {
        return this.currentPageAcc === Math.ceil(this.selectedAccs.length / this.pageSizeAcc);
    }

    get disableNextCont() {
        return this.currentPageCont === Math.ceil(this.selectedConts.length / this.pageSizeCont);
    }

    //Callbacks{
    constructor() {
        super();
        this.accessLevel = 'Read';
        this.picklistAccessesLevels = ['Edit', 'Read', 'All'];
        this.picklistUsers = [];
        this.isModalOpen = false;
        this.isModalAccOpen = false;
        this.isModalContOpen = false;
        this.opportunities = [];
        this.accounts = [];
        this.contacts = [];
        this.selectedAccs = [];
        this.selectedConts = [];

        this.users = [];
        this.opportunitiesId = [];

        this.preSelectedAccs = [];
        this.preSelectedConts = [];
        
        this.chartData = [];

        this.columns = [
            { label: 'Opportunity Name', fieldName: 'Link', type: 'url', typeAttributes: {label: {fieldName: 'Name', }, target: '_blank', tooltip: 'go to opportunity'}},
            { label: 'Account', fieldName: 'Account.Name', type: 'string'},
            { label: 'Created Date', fieldName: 'CreatedDate', type: 'date'},
            { label: 'Close Date', fieldName: 'CloseDate', type: 'date'},
            { label: 'Amount', fieldName: 'Amount', type: 'currency'},

        ];

        this.accountColumns = [
            { label: 'Account Name', fieldName: 'Link', type: 'url', typeAttributes: {label: {fieldName: 'Name', }, target: '_blank', tooltip: 'go to account'}},
        ];

        this.contactColumns = [
            { label: 'Contact Name', fieldName: 'Link', type: 'url', typeAttributes: {label: {fieldName: 'Name', }, target: '_blank', tooltip: 'go to contact'}},
        ];

        this.picklistAccessesLevels = [ {label: 'Edit', value: 'Edit'},
                                        {label: 'Read', value: 'Read'},];

    }

    connectedCallback(){

        getUsers()
            .then(users => {
                this.picklistUsers = users.map(el => { return {label: el.Username, value: el.Username}})
                this.users = users;
            })
            .catch(err => this.showToast('Error', err, 'error'));

        this.getData();
    }

    renderedCallback() {
        this.printChart();
    }
    //}Callbacks

    //Main functionality{
    getData(){
        getOpportunities()
        .then(data => {
            this.opportunities  = data.map(el => { return {...el, Link: '/' + el.Id}});
            this.opportunitiesId  = data.map(el => { return  el.Id});
            this.displayedDataOpp = this.displayData(this.opportunities, this.currentPageOpp, this.pageSizeOpp)
        })
        .then(() => {
            getAccounts({'oppIds': this.opportunitiesId})     
            .then(data => {
                this.accounts = data.map(el => { return {...el, Link: '/' + el.Id}});
                this.setDisplayedAccData();
            })
            getContacts({'oppIds': this.opportunitiesId})     
            .then(data => {
                this.contacts = data.map(el => { return {...el, Link: '/' + el.Id}});
                this.setDisplayedContData();
            })
        })       
        .catch(err => this.showToast('Error', JSON.stringify(err), 'error'));
    
        getOpportunitiesAmount()
        .then(data => this.chartData = [data.payment, data.rest])
        .catch(err => this.showToast('Error', JSON.stringify(err), 'error'));
    }
    //}Main functionality
    
    //Service functionality{
    displayData(table, currentPage, pageSize) {
        const displayedData = table;
        const startIndex = (currentPage - 1) * pageSize;
        const endIndex = startIndex + pageSize;
        return displayedData.slice(startIndex, endIndex);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    getSelectedOpps(){
        return this.template.querySelector('[data-id="oppTable"]').getSelectedRows().map(el => el.Id);
    }
    //}Service functionality


    //Delete functionality{
    deleteOpps(){
        const selectedOpps = this.getSelectedOpps();
        if(selectedOpps.length === 0){
            this.showToast( 'Important', 'First of all select opportunities', 'info');
            return;
        }

        deleteOpportunities({'opps': selectedOpps})
        .then(data => this.showToast(data.status, data.message, data.status))
        .catch(err => this.showToast('Error', JSON.stringify(err), 'error'))
        .then(()=> {
            this.getData();
            this.isChartJsInitialized = false;
        });
    }
    //Delete functionality{

    //Handlers{
    handleDeleteOpportunity(event) {
        this.deleteOpps();
    }

    handleOpenUndeleteableAcc(event){
        this.openAccModal(); 
    }

    handleOpenUndeleteableCont(event){
        this.openContModal(); 
    }

    handleSetUndeleteableAcc(){

        const selectedObj = this.getSelectedAccounts();
        this.accounts.forEach(el => el.UnDeletable__c = selectedObj.includes(el.Id));        

        setUndeleteableAcc({'accs': this.objFromArr(this.accounts)})
        .then(data => {
            this.showToast('Success', 'success', 'success');
        })     
        .catch(err => this.showToast('Error', JSON.stringify(err), 'error'));

        this.setDisplayedAccData();          
        this.closeAccModal();
    }

    handleSetUndeleteableCont(){

        const selectedObj = this.getSelectedContacts();
        this.contacts.forEach(el => el.UnDeletable__c = selectedObj.includes(el.Id));        

        setUndeleteableCont({'conts': this.objFromArr(this.contacts)})
        .then(data => {
            this.showToast('Success', 'success', 'success');
        })     
        .catch(err => this.showToast('Error', JSON.stringify(err), 'error'));

        this.setDisplayedContData();          
        this.closeContModal();
    }

    handlePreviousOpp(){
        if (!this.disablePreviousOpp) {
            this.currentPageOpp--;
            this.displayedDataOpp = this.displayData(this.opportunities, this.currentPageOpp, this.pageSizeOpp);
        }
    }
    
    handleNextOpp(){
        if (!this.disableNextOpp) {
            this.currentPageOpp++;
            this.displayedDataOpp = this.displayData(this.opportunities, this.currentPageOpp, this.pageSizeOpp);
        }
    }

    handlePreviousAcc(){
        if (!this.disablePreviousAcc){
            this.currentPageAcc--;
            this.displayedDataAcc = this.displayData(this.selectedAccs, this.currentPageAcc, this.pageSizeAcc);
        }
    }

    handleNextAcc(){
        if (!this.disableNextAcc){
            this.currentPageAcc++;
            this.displayedDataAcc = this.displayData(this.selectedAccs, this.currentPageAcc, this.pageSizeAcc);
        }
    }

    handlePreviousCont(){
        if (!this.disablePreviousCont) {
            this.currentPageCont--;
            this.displayedDataCont = this.displayData(this.selectedConts, this.currentPageCont, this.pageSizeCont);
        }
    }
    
    handleNextCont(){
        if (!this.disableNextCont) {
            this.currentPageCont++;
            this.displayedDataCont = this.displayData(this.selectedConts, this.currentPageCont, this.pageSizeCont);
        }
    }
    //}Handlers

    //Assign functionality{ 
    handleAssignTo(event) {    
        if(this.getSelectedOpps().length === 0)
            this.showToast( 'Important', 'First of all select opportunities', 'info');
        else
            this.openModal();
    }

    handleAccessesLevelChange(event){
        this.accessLevel = event.target.value;
    }

    handleUserChange(event){
        const user = event.target.value;
        const selectedUsers = [this.users.filter(el => el.Username === user)[0].Id];

        assignOpportunities({'opps': this.getSelectedOpps(), 'users': selectedUsers, 'accessLevel': this.accessLevel})
        .then(data => this.showToast('Success', data.message, 'success'))
        .catch(err => this.showToast('Error', err, 'error'));

        this.closeModal();
    }
    //}Assign functionality

    //Account/Contact functionality{
    getSelectedAccounts(){
        return this.template.querySelector('[data-id="accountChooseTable"]').getSelectedRows().map(el => el.Id);
    }

    getSelectedContacts(){
        return this.template.querySelector('[data-id="contactChooseTable"]').getSelectedRows().map(el => el.Id);
    }

    

    //}Account/Contact functionality


    //Service functionality{
    openModal(event) {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    } 

    openAccModal(event) {
        this.isModalAccOpen = true;
    }

    closeAccModal() {
        this.isModalAccOpen = false;
    }

    openContModal(event) {
        this.isModalContOpen = true;
    }

    closeContModal() {
        this.isModalContOpen = false;
    }

    objFromArr(arr){
        return arr.reduce((acc, el) => {acc[el.Id] = el.UnDeletable__c; return acc;}, {});
    }

    setDisplayedAccData(){
        this.selectedAccs = this.accounts.filter(el => el.UnDeletable__c);
        this.displayedDataAcc = this.displayData(this.selectedAccs, this.currentPageAcc, this.pageSizeAcc);
        this.preSelectedAccs = this.selectedAccs.map(el => el.Id);
    }

    setDisplayedContData(){
        this.selectedConts = this.contacts.filter(el => el.UnDeletable__c);
        this.displayedDataCont = this.displayData(this.selectedConts, this.currentPageCont, this.pageSizeCont);
        this.preSelectedConts = this.selectedConts.map(el => el.Id);
    }
    //}Service functionality

    
    //Chart functionality{
    printChart(){

        if (this.isChartJsInitialized ||  this.chartData === undefined || this.chartData.length === 0) {
            return;
        }

        this.isChartJsInitialized = true;

        Promise.all([
            loadScript(this, ChartJs)
        ])
        .then(() => {
            this.initializePieChart();
        })
        .catch(error => {
            console.log('Error loading Chart.js');
            console.error(error);
        });
    }
    
    initializePieChart() {
        
        if(this.chartData === undefined)
            return;

        const canvas = this.template.querySelector('canvas');
        canvas.InnerText = '';
        canvas.width = '230';;
        canvas.height = '230';
        const ctx = this.template.querySelector('canvas').getContext('2d');    
        
        new window.Chart(ctx, {
            type: 'pie',
            data: {
                labels: ['payment (' + this.chartData[0] + ')', 'rest (' + this.chartData[1] + ')'],
                datasets: [{
                    label: '# of Votes',
                    data: this.chartData,
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.5)',
                        'rgba(54, 162, 235, 0.5)']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                title: {
                    display: true,
                    text: "Payments"
                }
            },
        });
    }
        //}Chart functionality

}