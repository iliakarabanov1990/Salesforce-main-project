import { LightningElement, api } from 'lwc';
import getData from '@salesforce/apex/AccountSummaryController.getData';

export default class AccountSummary extends LightningElement {

    @api recordId;

    currentPage = 1;
    pageSize = 10;

    data = [];
    displayedData = [];
    products = [];
   
    isModalOpen = false;
    
    accSearchStr = '';
    amountSearchStr = ''; 

    error = '';

    USDollar = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
    });

    columns = [
        { label: 'Opportunity Name', fieldName: 'Link', type: 'url', typeAttributes: {label: {fieldName: 'Name', }, target: '_blank', tooltip: 'go to opportunity'}},
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date'},
        { label: 'Close Date', fieldName: 'CloseDate', type: 'date'},
        { label: 'Amount', fieldName: 'Amount', type: 'currency'},
        {type: 'button', typeAttributes: {
            label: 			'products',
            name: 			'products',
            title: 			'products'
        },},
    ];

    columnsOpp = [
        { label: 'Product', fieldName: 'Product', type: 'text'},
        { label: 'Quantity', fieldName: 'Quantity', type: 'number'},
        { label: 'UnitPrice', fieldName: 'UnitPrice', type: 'currency'},
        { label: 'TotalPrice', fieldName: 'TotalPrice', type: 'currency'}
    ];

    connectedCallback(){

        getData({recordId: this.recordId ?? ''})
        .then(data => {
            if (data) {
    
                const dataDetail = data[1].map(opp => {
                    let products = [];
                    if(opp.OpportunityLineItems){
                        console.log(opp.OpportunityLineItems);
                        products = opp.OpportunityLineItems.map(product => ({...product, Product: product.Product2.Name}));
                    }
    
                    return {...opp, Link: '/' + opp.Id, products};
                });
                this.data = data[0].map(acc => (            
                        {...acc, Opportunities:  dataDetail.filter(opp => opp.AccountId === acc.AccountId), AccountHeader: acc.Name + '     (' + this.USDollar.format(acc.expr0)+ ')'}  
                    )
                );
    
                this.displayData();          
                this.error = '';
            }

        })
        .catch(err =>{
            console.log('err: ' + err);
            console.log(err);
            this.error = err;
            this.data = [];
        })
    }


    displayData() {
        this.displayedData = this.data;

        if(this.accSearchStr !== ''){
            this.displayedData = this.displayedData.filter(el => el.Name === undefined || el.Name === null  ? false : el.Name.toLowerCase().includes(this.accSearchStr));
        }
        if(this.amountSearchStr !== ''){
            this.displayedData = this.displayedData.filter(el => {
                return el.expr0 === this.amountSearchStr;
            });
        }

        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        this.displayedData = this.displayedData.slice(startIndex, endIndex);
    }

    get isTab(){
        return !this.recordId;
    }
    
    get disablePrevious() {
        return this.currentPage === 1;
    }
    
    get disableNext() {
        return this.currentPage === Math.ceil(this.data.length / this.pageSize);
    }
    
    handlePrevious() {
        if (!this.disablePrevious) {
            this.currentPage--;
            this.displayData();
        }
    }
    
    handleNext() {
        if (!this.disableNext) {
            this.currentPage++;
            this.displayData();
        }
    }
    
    async handleSearchAccount(evt){
        this.accSearchStr = evt.target.value.toLowerCase().trim();
        this.currentPage = 1;

        this.displayData();
    }

    async handleSearchAmount(evt){

        this.amountSearchStr = evt.target.value.trim();
        this.currentPage = 1;

        if(this.amountSearchStr === '' || isNaN(this.amountSearchStr))
            this.amountSearchStr = '';
        else
            this.amountSearchStr = Number(this.amountSearchStr);

        this.displayData();
    }

    openModal(event) {
        const row = event.detail.row;
        this.products = row.products;
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }    
}