public Class TestDataUtils {
    /** 
    * ******************************************************
    * This method is test data for create User
    * ******************************************************
    */
    public static User createUser(boolean doInsert, String name) {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        //Create User
        user uTest = new User(Username = name + '@gmail.com.' + Math.round(Math.random() * 1000),
                email = name + Math.round(Math.random() * 1000) + '@gmail.com',
                Firstname = name,
                Lastname = 'mike',
                Alias = 'mwhite',
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.ID
        );

        if (doInsert) {
            insert uTest;
        }
        return uTest;
    }

    public static User createUser(String name) {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        //Create User
        user uTest = new User(Username = name + '@gmail.com',
                email = name + '@gmail.com',
                Firstname = name,
                Lastname = 'mike',
                Alias = 'mwhite',
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.ID
        );

        insert uTest;
        return uTest;
    }

    public static Account createAccount(String name) {

        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    /** 
    * ******************************************************
    * This method is test data for create Account
    * ******************************************************
    */

    public static Account createAccount(boolean doInsert, String name) {
        Account acc = new Account();
        acc.Name = name;
        if (doInsert) {
            insert acc;
        }
        return acc;
    }

    /** 
    * ********************************************************
    * This method is test data for create Lead
    * ********************************************************
    */

    public static Lead createLead(Boolean doInsert, String firstName, String lastName, String company, String LSource, String email) {
        Lead newLead = new Lead() ;
        newLead.FirstName = firstName;
        newLead.LastName = lastName;
        newLead.Company = company;
        newLead.Email = email;
        newLead.LeadSource = LSource;
        if (doInsert) {
            insert newLead;
        }
        return newLead;
    }
    /** 
    * ********************************************************
    * This method is test data for create Open Opportunity
    * ********************************************************
    */

    public static Opportunity createOpenOpportunity(Boolean doInsert, ID accountID, String oppName, String stageName) {
        Opportunity openOpp = new Opportunity(
                AccountId = accountID,
                name = oppName,
                StageName = stageName,
                leadSource = 'Web',
                CloseDate = Date.Today() + 1,
                Amount = 100.00
        );
        if (doInsert) {
            insert openOpp;
        }
        return openOpp;
    }

    /** 
    * ********************************************************
    * This method is test data for create Product
    * ********************************************************
    */
    public static Product2 createProduct(boolean doInsert, String prodName, String description, boolean active, String family) {

        Product2 prd = new Product2 (Name = prodName, Description = description, Family = family, isactive = active);
        if (doInsert) {
            insert prd;
        }
        return prd;
    }

    /** 
    * ********************************************************
    * This method is test data for create Price Book Entry
    * ********************************************************
    */
    public static PricebookEntry createPriceBookEntryID(boolean doInsert, ID prodid) {

        ID pbkID = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(product2id = prodid, unitprice = 6000, pricebook2id = pbkID, isActive = true, UseStandardPrice = false);
        if (doInsert) {
            insert pbe;
        }
        return pbe;
    }
    /** 
    * ********************************************************
    * This method is test data for create Opportunity Product
    * ********************************************************
    */
    public static OpportunityLineItem createOpportunityProduct(boolean doInsert, ID opportunityID, ID pricebookID) {

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Quantity = 1;
        oli.TotalPrice = 6000;
        oli.OpportunityId = opportunityID;
        oli.PricebookEntryId = pricebookID;
        oli.Converted_to_Asset__c = false;
        oli.project__c = 'Project';

        if (doInsert) {
            insert oli;
        }
        return oli;

    }

    /** 
    * ********************************************************
    * This method is test data for create Asset
    * ********************************************************
    */
    public static Asset createAsset(boolean doInsert, String name, ID accId, ID prodId, String status) {

        Asset asst = new Asset(Name = name, AccountId = accId, Product2id = prodId, Price = 500, Status = status, PurchaseDate = System.Today(), UsageEndDate = System.Today() + 200);

        if (doInsert) {
            insert asst;
        }
        return asst;


    }

    public static Contact createContact(String firstname, String lastname, ID accountid) {

        Contact con = new Contact(firstName = firstname, lastname = lastname, accountid = accountid);
        insert con;
        return con;
    }

    public static Opportunity createOpenOpportunity(ID accountID, String oppName, String stageName) {
        Opportunity openOpp = new Opportunity(
                AccountId = accountID,
                name = oppName,
                StageName = stageName,
                leadSource = 'Web',
                CloseDate = Date.Today() + 1,
                Amount = 100.00
        );
        insert openOpp;
        return openOpp;
    }

    public static Opportunity createClosedOpportunity(ID accountID, String oppName, String stageName) {
        Opportunity closedOpp = new Opportunity(
                AccountId = accountID,
                name = oppName,
                StageName = stageName,
                leadSource = 'Web',
                CloseDate = Date.Today() + 1,
                Amount = 100.00
        );
        insert closedOpp;
        return closedOpp;
    }

    public static OpportunityContactRole createBillingContact(ID oppid, ID contactid) {

        //Create a product and populates the data.
        OpportunityContactRole ocr = new OpportunityContactRole (opportunityid = oppid, contactid = contactid, role = 'Decision Maker');
        insert ocr;
        return ocr;
    }

    public static Product2 createProduct(String prodName, String description, Integer committedMonths, String family) {

        //Create a product and populates the data.
        Product2 prd = new Product2 (Name = prodName, Description = description, Family = family);
        insert prd;
        return prd;
    }

    public static PricebookEntry createPriceBookEntryID(ID prodid) {

        ID pbkID = Test.getStandardPricebookId();

        //Create a product and populates the data.
        PricebookEntry pbe = new PricebookEntry(product2id = prodid, unitprice = 6000, pricebook2id = pbkID, isActive = true, UseStandardPrice = false);
        insert pbe;
        return pbe;
    }

    public static OpportunityLineItem createOpportunityProduct(ID opportunityID, ID pricebookID) {

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Quantity = 1;
        oli.TotalPrice = 6000;
        oli.OpportunityId = opportunityID;
        oli.PricebookEntryId = pricebookID;
        oli.Converted_to_Asset__c = false;
        oli.project__c = 'Project';
        insert oli;

        return oli;
    }

    /** 
    * ****************************************************************************
    * This method is test data for create Profile_by_allowed_Opportunity_Type__c
    * ****************************************************************************
    */
    public static Profile_by_allowed_Opportunity_Type__c createProfileAllowedOpportunityType(Boolean doInsert, String name, String UserProfileName) {
        Profile_by_allowed_Opportunity_Type__c pb = new Profile_by_allowed_Opportunity_Type__c();
        pb.Name = name;
        pb.Allowed_Opportunity_Type__c = UserProfileName;

        if (doInsert) {
            insert pb;
        }
        return pb;
    }

    /** 
    * ********************************************************
    * This method is test data for create Project
    * ********************************************************
    */
    public static Project__c createProject(boolean doInsert, String Name, String type, String category, String status) {

        Project__c project = new Project__c(Name = Name, Category__c = category, Status__c = status, slug__c ='testproject',Model__c = 'Membership',Funding__c = 'Funded');
        if (doInsert) {
            insert project;
        }
        return project;
    }

    /** 
    * ********************************************************
    * This method is test data for create Event
    * ********************************************************
    */
    public static Event__c createEvent(boolean doInsert, String Name, String type, String category, String status) {

        Event__c event = new Event__c(Name = Name, Category__c = category, Status__c = status);
        if (doInsert) {
            insert event;
        }
        return event;
    }
    
    /** 
    * ********************************************************
    * This method is test data for create Event
    * ********************************************************
    */
    public static Event__c createEvent(boolean doInsert, String Name, String type,String billFromProject, String category, String status) {

        Event__c event = new Event__c(Name = Name, Category__c = category, Status__c = status, BillFromProject__c =billFromProject );
        if (doInsert) {
            insert event;
        }
        return event;
    }

    /** 
    * ********************************************************
    * This method is test data for create Training
    * ********************************************************
    */
    public static Training__c createTraining(boolean doInsert, String Name, String type, String category, String status) {

        Training__c training = new Training__c(Name = Name, Category__c = category, Status__c = status);
        if (doInsert) {
            insert training;
        }
        return training;
    }

    /** 
    * ***************************************************************************************
    * This method is test data for create Product Detail with Project, Event and Training
    * ***************************************************************************************
    */
    public static Product_Details__c createProductDetail(boolean doInsert, Id projectId, Id eventId, Id trainingId, Id prodId) {

        Product_Details__c pd = new Product_Details__c();
        if (projectId != null) {
            pd.Project__c = projectId;
        } else if (eventId != null) {
            pd.Event__c = eventId;
        } else if (trainingId != null) {
            pd.Training__c = trainingId;
        }
        pd.Products__c = prodId;
        pd.Description__c ='Description';

        if (doInsert) {
            insert pd;
        }
        return pd;
    }

    /**
    * ***************************************************************************************
    * This method is test data for create ProjectRole with Contact Id, Opportunity Id, OppLineItem Id, Role, PrimaryContact
    * ***************************************************************************************
    */
    public static Project_Role__c createProjectRole(Boolean doInsert, String contactId, String role, String opportunityId, String oppLineItemId,String assetId,Boolean primaryContact) {
        Project_Role__c objProjectRole = new Project_Role__c();
        objProjectRole.status__c ='Active';
        objProjectRole.Contact__c = contactId;
        objProjectRole.Role__c = role;
        objProjectRole.PrimaryContact__c=primaryContact;
        objProjectRole.Opportunity__c = opportunityId;
        objProjectRole.Opportunity_Line_Item__c = oppLineitemId;
        objProjectRole.Asset__c = assetId; 
        if (doInsert)
            insert objProjectRole;
        return objProjectRole;
    }

   	/**
	 * ***************************************************************************************
	 * This method is test data for create Cvent Integration Custom setting
	 * ***************************************************************************************
	 */
	public static Cvent_Integration__c createCventIntegrationSetting(Boolean doInsert){
		Cvent_Integration__c cventIntegration = new Cvent_Integration__c();
		cventIntegration.Cvent_Password__c = 'CPassword';
		cventIntegration.Cvent_Time_Zone__c = 'America/New_York';
		cventIntegration.Cvent_Username__c = 'CUsername';
		cventIntegration.Event_Last_Synced__c = Datetime.now().addDays(-1);
		cventIntegration.Events_Retrieval_Months__c = 6;
		cventIntegration.Event_Statuses__c = 'Active;Completed';
		cventIntegration.Registration_Last_Synced__c = Datetime.now().addDays(-1);
		cventIntegration.Cvent_AccountNumber__c = 'CAccntNo';
		if (doInsert){
			insert cventIntegration;
		}
		return cventIntegration;
	}

	/**
	 * ***************************************************************************************
	 * This method is test data for create Cvent Registration log
	 * ***************************************************************************************
	 */
	public static Cvent_Registration_Log__c createCventRegistrationLog(Boolean doInsert, String cventId, String type){
		Cvent_Registration_Log__c cventRegistrationLog = new Cvent_Registration_Log__c();
		cventRegistrationLog.Cvent_Id__c = cventId;
		cventRegistrationLog.Type__c = type;
		cventRegistrationLog.Sfdc_Upsert_Attempts_Count__c = 0;

		if (doInsert){
			insert cventRegistrationLog;
		}
		return cventRegistrationLog;
	}
    
    public static Id createSeriesLLC(){
        Project__c prj = new Project__c(Name = 'LF Projects, LLC',Slug__c='lfproject', Do_not_Invoice__c = true,Status__c = 'Planned',Category__c = 'Subproject');
        insert prj;
        Project__c seriesLLC = new Project__c();
        seriesLLC.Name = 'Test Series LLC';
        seriesLLC.Project_Status__c = 'Formation - Exploratory';
        seriesLLC.Category__c = 'Series LLC';
        seriesLLC.Slug__c = 'test-series-llc';
        seriesLLC.Parent_Entity_Relationship__c = prj.Id;
        insert seriesLLC;
        return seriesLLC.Id;

    }

}