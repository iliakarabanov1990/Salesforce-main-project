import { LightningElement, track, wire, api } from 'lwc';
import sendEmail from '@salesforce/apex/SendEmailOppInvoiceController.sendEmail';
import getEmailData from '@salesforce/apex/SendEmailOppInvoiceController.getEmailData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

export default class emailOpportunityInvoice extends NavigationMixin(LightningElement) {
    
    @api  recordId;

    subject = '';
    body = '';
    fileTitle = '';
    fileId = '';  
    conVerId = ''; 
    fromAddress = '';
    recipientEmail = '';
    recipientName = '';
    recipientCompany = '';
    invoiceNumber = '';
    orgName = '';
    oppOwner = '';
    
    // Get data from Opportunity by id
    @wire(getEmailData, { recordId: '$recordId' })
    wiredFieldValue({ error, data }) {
        if (data) {
            this.subject = data.subject;            
            this.fileTitle = data.fileTitle;
            this.fileId = data.fileId;
            this.conVerId = data.conVerId;
            this.recipientName = data.recipientName;
            this.fromAddress = data.fromAddress;
            this.recipientEmail =  data.recipientEmail;
            this.recipientCompany = data.recipientCompany;
            this.invoiceNumber = data.invoiceNumber;
            this.orgName = data.orgName;
            this.oppOwner = data.oppOwner;
            this.body = data.body;

        } else if (error) {
            this.showToast(error);
        }
    }

    //Open pdf file by clicking on 'Preview invoice' button
    navigateToFiles() {
        this[NavigationMixin.Navigate]({
          type: "standard__namedPage",
          attributes: {
            pageName: "filePreview",
          },
          state: {
            recordIds: this.fileId,
            selectedRecordId: this.fileId,
          },
        });
      }

    // Handler for changes in the message
    handleBodyChange(event) {
        this.body = event.target.value;
    }

    // Function to send the email
    handleSendEmail() {
        console.log('fromAddress: ' + this.fromAddress);
        sendEmail({ fromAddress: this.fromAddress, toAddress: this.recipientEmail, subject: this.subject, body: this.body, fileTitle: this.fileTitle, conVerId: this.conVerId })
            .then(() => {
                this.showToast('Success', 'Email sent successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Failed to send email', 'error');
                console.error(error);
            });
    }

    // Function to show toast notifications
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}