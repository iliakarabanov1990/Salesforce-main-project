({    
    onInit: function(component, event, helper){          
        let action = component.get("c.GenerateInvoice");  
        action.setParams({  
            recId: component.get("v.recordId")          
        });  
        action.setCallback(this, function(response){    
            if(response.getState() === "SUCCESS"){                  
                $A.get("e.force:closeQuickAction").fire();  
                $A.get('e.force:refreshView').fire();                 
            }else {                
                let showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Error',
                    message : 'File Not Saved due to error.' ,
                    type : 'error',
                    mode : 'sticky',
                    message : JSON.stringify(response.getError())
                });
                showToast.fire();              
            }
        });  
        $A.enqueueAction(action);              
    }  
})