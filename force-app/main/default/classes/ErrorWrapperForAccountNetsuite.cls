public class ErrorWrapperForAccountNetsuite{

    public string body;
    public integer statuscode;

    public ErrorWrapperForAccountNetsuite(String body,Integer statuscode){
        this.body = body;
        this.statuscode = statuscode;
    }
}