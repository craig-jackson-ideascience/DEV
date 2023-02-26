global class TicketEmailHandler implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String plainTextBody = '';
        plainTextBody = email.plainTextBody;
        String sender = env.fromAddress;
        String ticketName = '';
        String strUserName = '';
        Id userId;
        
       //Creating new Ticket 
        try{
                
            Ticket__c ticket = new Ticket__c();
            ticket.Short_Description__c = email.subject;
            ticket.Long_Description__c= plainTextBody;
            
            //Added by Pratik - 10-Jan
            //Getting User id based on name mentioned in email and setting on Owner field
            strUserName = plainTextBody.substringBefore('\n');
            for(User u : [ SELECT Id 
                            FROM User 
                            WHERE Name = : strUserName 
                            LIMIT 1]){
                ticket.ownerId = u.Id;
            }
            
            insert ticket; 
            ticketName = [Select Name From Ticket__c where Id = : ticket.id].Name;
            
            
        }catch(Exception e){
            result.success = false;
            result.message = 'Error Occured while generating ticket ' +e.getMessage(); 
            return result;
        }
        //send email to the email sender about new ticket generation
        result.success = true;
        result.message = ' Your Ticket has been generated successfully '+ticketName + '.';
        return result;
    }
    
 
}