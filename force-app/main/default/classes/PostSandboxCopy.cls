global class PostSandboxCopy implements SandboxPostCopy {
    
    global void runApexClass( SandboxContext context ) {
               
        //update netsuite endpoints
        string nlauth = '4010327_SB1';
        List<Endpoints__c> endpoints = new List<Endpoints__c>();
        endpoints.add(new Endpoints__c(Name='For Membership Asset' ,Endpoint__c='https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=42&deploy=1',Nlauth_Account__c= nlauth));
        endpoints.add(new Endpoints__c(Name='For Other than Membership Asset' ,Endpoint__c='https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=40&deploy=1',Nlauth_Account__c= nlauth));
        endpoints.add(new Endpoints__c(Name='For Product Details' ,Endpoint__c='https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1',Nlauth_Account__c= nlauth));
        endpoints.add(new Endpoints__c(Name='To Get Sales Order ID From NS' ,Endpoint__c='https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=39&deploy=1',Nlauth_Account__c= nlauth));
        endpoints.add(new Endpoints__c(Name='To Get Sales Order Status From NS' ,Endpoint__c='https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=43&deploy=1',Nlauth_Account__c= nlauth));
        upsert endpoints name;
        
    }
    
}