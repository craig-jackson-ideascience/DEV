@isTest
public class TicketEmailHandlerTest {
    static testmethod void emailTicket(){
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inboundAttachment = new Messaging.InboundEmail.BinaryAttachment();
        
        email.subject = 'Send Email Ticket';
        email.fromAddress = 'test@gmail.com';
        email.plainTextBody = 'Hello, Text message for Long Description';
        
        TicketEmailHandler emailHandler = new TicketEmailHandler();
        emailHandler.handleInboundEmail(email, env);

    }
}