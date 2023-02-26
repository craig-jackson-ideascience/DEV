public interface IEmail {
    
    List<SendEmailWrapper.SendEmailContactWrapper> getRecipients();
    string getBody();
    List<Messaging.EmailFileAttachment> getAttachments(Map<String, Object> parameters);
}