/********************************************************
 * Created by: CloudRoute @ CloudRoute Solutions
 * Created Date: 19/03/20.
 * Description: JoinNowRequestWrapper
 ********************************************************/

/*
LastModified By             ModifiedDate            Methods                                                 Against 
========================================================================================================================
Kalyani Chiluveri           22-May-2020             Added Country Field                                     SFDC - 1373      
*/

public class JoinNowRequestWrapper {

    public String accountId;
    public String projectSlug;
    public String productID;

    
    public String company;
    public String address;
    public String city;
    public String state;
    public String country;
    public String zip;
    public String category;
    public String employeeSize;
    public String lm_employeeSize;
    public String logo_url;
    public String website;
    public Boolean display_logo;
    public Boolean press_release_announcement;
    public String preferred_invoice_method;
    public String mode;
    public Boolean sign_msa;
    public String zero_memebership;

    public String pm_po_required;
    public String po_con_name;
    public String po_con_emailParam;

    //Project Membership: Project Details
    public String pm_project;
    public String pm_product;
    public String pm_product_detail;
    public String pm_fees;
    public String pm_po;

    //Project Membership: Primary Contact
    public String pm_primary_con_id;
    public String pm_primary_con_emailParam;
    public String pm_primary_con_fname;
    public String pm_primary_con_lname;
    public String pm_primary_con_title;
    public String pm_primary_con_phone;
    public String pm_primary_con_twitter;
    public String pm_primary_con_github;
    public String pm_primary_con_linkedIn;
    public Boolean pm_primary_con_subscribed;
    public Boolean pm_primary_con_invoice_copy;

    //Project Membership: Billing Contact
    public String pm_billing_con_id;
    public String pm_billing_con_emailParam;
    public String pm_billing_con_fname;
    public String pm_billing_con_lname;
    public String pm_billing_con_title;
    public String pm_billing_con_phone;
    public String pm_billing_con_twitter;
    public String pm_billing_con_github;
    public String pm_billing_con_linkedIn;
    public Boolean pm_billing_con_subscribed;

    //Project Membership: Authorized Signatory Contact
    public String pm_authSig_id;
    public String pm_authSig_emailParam;
    public String pm_authSig_fname;
    public String pm_authSig_lname;
    public String pm_authSig_title;
    public String pm_authSig_phone;
    public String pm_authSig_twitter;
    public String pm_authSig_github;
    public String pm_authSig_linkedIn;
    public Boolean pm_authSig_subscribed;

    //Project Membership: Invoice Contact
    public String pm_inv_con_id;
    public String pm_inv_con_emailParam;
    public String pm_inv_con_fname;
    public String pm_inv_con_lname;
    public String pm_inv_con_title;
    public String pm_inv_con_phone;
    public String pm_inv_con_twitter;
    public String pm_inv_con_github;
    public String pm_inv_con_linkedIn;
    public Boolean pm_inv_con_subscribed;


    //Project Membership: Technical Contacts
    public String pm_tech_con_1_id;
    public String pm_tech_con_1_emailParam;
    public String pm_tech_con_1_fname;
    public String pm_tech_con_1_lname;
    public String pm_tech_con_1_title;
    public String pm_tech_con_1_phone;
    public String pm_tech_con_1_twitter;
    public String pm_tech_con_1_github;
    public String pm_tech_con_1_linkedIn;
    public Boolean pm_tech_con_1_subscribed;

    public String pm_tech_con_2_id;
    public String pm_tech_con_2_emailParam;
    public String pm_tech_con_2_fname;
    public String pm_tech_con_2_lname;
    public String pm_tech_con_2_title;
    public String pm_tech_con_2_phone;
    public String pm_tech_con_2_twitter;
    public String pm_tech_con_2_github;
    public String pm_tech_con_2_linkedIn;
    public Boolean pm_tech_con_2_subscribed;

    public String pm_tech_con_3_id;
    public String pm_tech_con_3_emailParam;
    public String pm_tech_con_3_fname;
    public String pm_tech_con_3_lname;
    public String pm_tech_con_3_title;
    public String pm_tech_con_3_phone;
    public String pm_tech_con_3_twitter;
    public String pm_tech_con_3_github;
    public String pm_tech_con_3_linkedIn;
    public Boolean pm_tech_con_3_subscribed;

    //Project Membership: Marketing Contacts
    public String pm_mkt_con_1_id;
    public String pm_mkt_con_1_emailParam;
    public String pm_mkt_con_1_fname;
    public String pm_mkt_con_1_lname;
    public String pm_mkt_con_1_title;
    public String pm_mkt_con_1_phone;
    public String pm_mkt_con_1_twitter;
    public String pm_mkt_con_1_github;
    public String pm_mkt_con_1_linkedIn;
    public Boolean pm_mkt_con_1_subscribed;

    public String pm_mkt_con_2_id;
    public String pm_mkt_con_2_emailParam;
    public String pm_mkt_con_2_fname;
    public String pm_mkt_con_2_lname;
    public String pm_mkt_con_2_title;
    public String pm_mkt_con_2_phone;
    public String pm_mkt_con_2_twitter;
    public String pm_mkt_con_2_github;
    public String pm_mkt_con_2_linkedIn;
    public Boolean pm_mkt_con_2_subscribed;

    //Project Membership: PR Contact
    public String pm_pr_con_id;
    public String pm_pr_con_emailParam;
    public String pm_pr_con_fname;
    public String pm_pr_con_lname;
    public String pm_pr_con_title;
    public String pm_pr_con_phone;
    public String pm_pr_con_twitter;
    public String pm_pr_con_github;
    public String pm_pr_con_linkedIn;
    public Boolean pm_pr_con_subscribed;

    //Project Membership: Legal Contact
    public String pm_legal_con_id;
    public String pm_legal_con_emailParam;
    public String pm_legal_con_fname;
    public String pm_legal_con_lname;
    public String pm_legal_con_title;
    public String pm_legal_con_phone;
    public String pm_legal_con_twitter;
    public String pm_legal_con_github;
    public String pm_legal_con_linkedIn;
    public Boolean pm_legal_con_subscribed;
    
    //Project Membership : Event Sponsership Details
    public String eventSponsor_con_id;
    public String eventSponsor_con_fname;
    public String eventSponsor_con_lname;
    public String eventSponsor_con_title;
    public String eventSponsor_con_phone;
    public String eventSponsor_con_emailParam;
    public String eventSponsor_con_twitter;
    public String eventSponsor_con_github;
    public String eventSponsor_con_linkedIn;


    //Project Membership: Additional Information
    public String pm_addInt;

    //Linux Membership: Project Details
    public String lm_project;
    public String lm_product;
    public String lm_product_detail;
    public String lm_fees;
    public String lm_po;

    //Linux Membership: Primary Contact
    public String lm_primary_con_id;
    public String lm_primary_con_emailParam;
    public String lm_primary_con_fname;
    public String lm_primary_con_lname;
    public String lm_primary_con_title;
    public String lm_primary_con_phone;
    public String lm_primary_con_twitter;
    public String lm_primary_con_github;
    public String lm_primary_con_linkedIn;
    public Boolean lm_primary_con_subscribed;
    public Boolean lm_primary_con_invoice_copy;

    //Linux Membership: Billing Contact
    public String lm_billing_con_id;
    public String lm_billing_con_emailParam;
    public String lm_billing_con_fname;
    public String lm_billing_con_lname;
    public String lm_billing_con_title;
    public String lm_billing_con_phone;
    public String lm_billing_con_twitter;
    public String lm_billing_con_github;
    public String lm_billing_con_linkedIn;
    public Boolean lm_billing_con_subscribed;

    //Linux Membership: Authorized Signatory Contact
    public String lm_authSig_id;
    public String lm_authSig_emailParam;
    public String lm_authSig_fname;
    public String lm_authSig_lname;
    public String lm_authSig_title;
    public String lm_authSig_phone;
    public String lm_authSig_twitter;
    public String lm_authSig_github;
    public String lm_authSig_linkedIn;
    public Boolean lm_authSig_subscribed;

    //Linux Membership: Invoice Contact
    public String lm_inv_con_id;
    public String lm_inv_con_emailParam;
    public String lm_inv_con_fname;
    public String lm_inv_con_lname;
    public String lm_inv_con_title;
    public String lm_inv_con_phone;
    public String lm_inv_con_twitter;
    public String lm_inv_con_github;
    public String lm_inv_con_linkedIn;
    public Boolean lm_inv_con_subscribed;

    //Linux Membership: Technical Contacts
    public String lm_tech_con_1_id;
    public String lm_tech_con_1_emailParam;
    public String lm_tech_con_1_fname;
    public String lm_tech_con_1_lname;
    public String lm_tech_con_1_title;
    public String lm_tech_con_1_phone;
    public String lm_tech_con_1_twitter;
    public String lm_tech_con_1_github;
    public String lm_tech_con_1_linkedIn;
    public Boolean lm_tech_con_1_subscribed;

    public String lm_tech_con_2_id;
    public String lm_tech_con_2_emailParam;
    public String lm_tech_con_2_fname;
    public String lm_tech_con_2_lname;
    public String lm_tech_con_2_title;
    public String lm_tech_con_2_phone;
    public String lm_tech_con_2_twitter;
    public String lm_tech_con_2_github;
    public String lm_tech_con_2_linkedIn;
    public Boolean lm_tech_con_2_subscribed;

    public String lm_tech_con_3_id;
    public String lm_tech_con_3_emailParam;
    public String lm_tech_con_3_fname;
    public String lm_tech_con_3_lname;
    public String lm_tech_con_3_title;
    public String lm_tech_con_3_phone;
    public String lm_tech_con_3_twitter;
    public String lm_tech_con_3_github;
    public String lm_tech_con_3_linkedIn;
    public Boolean lm_tech_con_3_subscribed;

    //Linux Membership: Marketing Contacts
    public String lm_mkt_con_1_id;
    public String lm_mkt_con_1_emailParam;
    public String lm_mkt_con_1_fname;
    public String lm_mkt_con_1_lname;
    public String lm_mkt_con_1_title;
    public String lm_mkt_con_1_phone;
    public String lm_mkt_con_1_twitter;
    public String lm_mkt_con_1_github;
    public String lm_mkt_con_1_linkedIn;
    public Boolean lm_mkt_con_1_subscribed;

    public String lm_mkt_con_2_id;
    public String lm_mkt_con_2_emailParam;
    public String lm_mkt_con_2_fname;
    public String lm_mkt_con_2_lname;
    public String lm_mkt_con_2_title;
    public String lm_mkt_con_2_phone;
    public String lm_mkt_con_2_twitter;
    public String lm_mkt_con_2_github;
    public String lm_mkt_con_2_linkedIn;
    public Boolean lm_mkt_con_2_subscribed;

    //Linux Membership: PR Contact
    public String lm_pr_con_id;
    public String lm_pr_con_emailParam;
    public String lm_pr_con_fname;
    public String lm_pr_con_lname;
    public String lm_pr_con_title;
    public String lm_pr_con_phone;
    public String lm_pr_con_twitter;
    public String lm_pr_con_github;
    public String lm_pr_con_linkedIn;
    public Boolean lm_pr_con_subscribed;

    //Linux Membership: Legal Contact
    public String lm_legal_con_id;
    public String lm_legal_con_emailParam;
    public String lm_legal_con_fname;
    public String lm_legal_con_lname;
    public String lm_legal_con_title;
    public String lm_legal_con_phone;
    public String lm_legal_con_twitter;
    public String lm_legal_con_github;
    public String lm_legal_con_linkedIn;
    public Boolean lm_legal_con_subscribed;

    //Linux Membership: Additional Information
    public String lm_addInt;


    //Bill To Address
    public String billto_account_id;
    public String billto_account;
    public String billto_account_name;      
    public String billto_street;        
    public String billto_city;  
    public String billto_state; 
    public String billto_country;   
    public String billto_zip;   

    /*Added by Priyesh @CloudRoute to store the committeeData which creates the membership roles*/
    //list of committee Data
    public cls_committeeData[] committeeData;

    //committeeData contact info and list of types
    public class cls_committeeData {
        public String ContactID;
        public String FirstName;
        public String LastName;
        public String Email;
        public String Title;
        public String[] committeeType;
    }
}