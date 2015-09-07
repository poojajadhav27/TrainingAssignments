/***************************************************************************************************
Class : CRMEmailSearchEngine
Created Date : 31/8/2015
Description : This class is for accessing email mail services
***************************************************************************************************/
global class CRMEmailSearchEngine implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                                           Messaging.InboundEnvelope envelope) {

    // creating instance for objects
    Contact conInstance;
    Email__c emailInstance;
    Query__c queryInstance;
    Send_Response__c resInstace;
    
    // Creating Instance for email result
    Messaging.InboundEmailResult result = new  Messaging.InboundEmailResult();
        
        List <Contact> conList = [select id from Contact where Email = :email.FromAddress];
        
        if(conList.isEmpty()) {
            conInstance = new Contact();
            conInstance.Email = email.FromAddress;
            conInstance.LastName = email.FromName;
            insert conInstance;
        } 
        else {
            conInstance = [select Id,Lastname from Contact where Email = :email.FromAddress];
        }
        // Assigning values to repective fields 
        emailInstance = new Email__c();
        emailInstance.Name = email.FromAddress; 
        emailInstance.Contact__c = conInstance.Id;
        emailInstance.Body__c = email.plainTextBody ;
        emailInstance.From_Address__c = email.FromAddress;
        emailInstance.Subject__c = email.subject;
        insert emailInstance;
        
        queryInstance = new Query__c();
        String strBody = emailInstance.Body__c.substringBetween('[',']');
        String query = strBody.substringAfter(Constants.strQueryFormat);
        queryInstance.Query_Of_User__c = query;
        queryInstance.EmailandContact__c = emailInstance.Id;
        insert queryInstance;
        
        resInstace = new Send_Response__c();
        resInstace.QueryJunction__c = queryInstance.Id;
        resInstace.ContactJunction__c = conInstance.Id;
        insert resInstace;
        
        return result;
    }
}