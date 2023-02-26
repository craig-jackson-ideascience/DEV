/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 09-10-2019.
 * Description: MailBoxWrapper
 ********************************************************/
public class MailBoxWrapper {

    public String email;
    public String did_you_mean;
    public String user;
    public String domain;
    public Boolean format_valid;
    public Boolean mx_found;
    public Boolean smtp_check;
    public Object catch_all;
    public Boolean role;
    public Boolean disposable;
    public Boolean free;
    public Double score;
    public Error error;
    public Boolean success;


    public static MailBoxWrapper parse(String json) {
        return (MailBoxWrapper) System.JSON.deserialize(json, MailBoxWrapper.class);
    }
    public class Error {
        public Double code;
        public String type;
        public String info;
    }
}