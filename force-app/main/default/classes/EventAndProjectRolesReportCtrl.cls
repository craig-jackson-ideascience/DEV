public class EventAndProjectRolesReportCtrl {
    public String EventID {
        get {
            System.debug('====> EventId Getter');
            return EventID;
        }
        set {
            System.debug('====> EventId Setter');
            EventID = value;
        }
    }
    public String campaignId { get; set; }
    public String ProjectID { get; set; }
    public String selectedProjectRole { get; set; }
    public String filterType { get; set; }
    public Boolean eventSelected { get; set; }
    public String statusMsgString { get; set; }
    public Boolean recordsFetched { get; set; }
    public Boolean errorMsg { get; set; }
    public String emailOptOut { get; set; }
    public Boolean addtoCampaignModal { get; set; }
    private String sortExp = 'Contact';
    private String sortDirection = 'ASC';
    public String ProjectIdsString { get; set; }
    public List<SelectOption> rolesPickListSelectoptions { get; set; }
    public Map<String, String> rolesPicklistMap { get; set; }
    public List<EventProjectContactWrapper> limitedreportWrapperList { get; set; }

    public list<EventProjectContactWrapper> reportWrapperList;

    //Custom Pagination
    public ReportIterable setcon { get; set; }

    public Boolean hasNext {
        get {
            return setcon.hasNext();
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            return setcon.hasPrevious();
        }
        set;
    }
    /*
    METHOD FOR SORTING THE ASSETS
    */
    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp) {
                sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';
            } else {
                sortDirection = 'ASC';
            }
            sortExp = value;
        }
    }

    /*
    METHOD FOR SORTING DIRECTION THE ASSETS (ASC OR DESC)
    */
    public String getSortDirection() {
        //if not column is selected
        if (sortExpression == null || sortExpression == '') {
            return 'ASC';
        } else {
            return sortDirection;
        }
    }

    public EventAndProjectRolesReportCtrl() {
        limitedreportWrapperList = new List<EventProjectContactWrapper>();
        reportWrapperList = new List<EventProjectContactWrapper>();
        rolesPicklistMap = new Map<String, String>();
        populateRolesPickList();
        eventSelected = false;
        filterType = '';
        recordsFetched = false;
        errorMsg = false;
        addtoCampaignModal = false;
        setCon = new ReportIterable(reportWrapperList);
        next();
    }


    public void next() {
        limitedreportWrapperList = setCon.next();
    }

    public void previous() {
        limitedreportWrapperList = setCon.previous();
    }

    public void clearFilter() {
        EventID = '';
        ProjectID = '';
        selectedProjectRole = '';
        emailOptOut = '';
        populateRolesPickList();
    }

    public void debug() {
        System.debug('  ===> event Selected');
    }

    public void addToCampaign() {
        boolean pass = false;
        for (EventProjectContactWrapper wrap : reportWrapperList) {
            if (wrap.selected) {
                pass = true;
                break;
            }
        }
        if (pass) {
            addtoCampaignModal = true;
        } else {
            statusMsgString = 'No Records Selected';
            errorMsg = true;
        }
    }

    public void cancelAddtoCampaign() {
        addtoCampaignModal = false;
    }

    public void callReport() {
        if (filterType == 'events') {
            createEventReport();
        } else if (filterType == 'projects') {
            createProjectReport();
        }
        if (reportWrapperList.size() > 0) {
            recordsFetched = true;
            errorMsg = false;

        } else {
            statusMsgString = 'No Records Found';
            errorMsg = true;
            recordsFetched = false;
        }
    }

    public void eventSelectedMethod() {
        System.debug(EventId + '  ===> eventSelected');
        rolesPickListSelectoptions = new List<SelectOption>();
        rolesPickListSelectoptions.add(new selectoption('', ''));

        if (String.isNotBlank(EventID)) {
            System.debug(eventId + '====> eventId');
            System.debug('  ===> eventSelected');
            eventSelected = true;
            populateEventReportWrapper();
            ProjectIdsString = '(';
            Set<String> opts = new Set<String>();
            for (EventProjectContactWrapper wrap : reportWrapperList) {
                ProjectIdsString += '\\\'' + wrap.projRole.Asset__r.Projects__c + '\\\',';

                if (!opts.contains(wrap.projRole.Role__c)) {
                    rolesPickListSelectoptions.add(new SelectOption(wrap.projRole.Role__c, rolesPicklistMap.get(wrap.projRole.Role__c)));
                    opts.add(wrap.projRole.Role__c);
                }

            }

            System.debug(rolesPickListSelectoptions + '====> rolesPickListSelectoptions');
            ProjectIdsString = ProjectIdsString.removeEnd(',');
            ProjectIdsString += ')';

        }
    }


    public void projectSelectedMethod() {
        System.debug(ProjectID + '  ===> project Selected');
        rolesPickListSelectoptions = new List<SelectOption>();
        rolesPickListSelectoptions.add(new selectoption('', ''));
        Set<String> opts = new Set<String>();
        selectedProjectRole = '';
        if (String.isNotBlank(ProjectID)) {
            System.debug(ProjectID + '====> ProjectID');
            if (filterType == 'events') {
                populateEventReportWrapper();
            } else if (filterType == 'projects') {
                populateProjectReportWrapper();
            }
            for (EventProjectContactWrapper wrap : reportWrapperList) {
                if (!opts.contains(wrap.projRole.Role__c)) {
                    rolesPickListSelectoptions.add(new SelectOption(wrap.projRole.Role__c, rolesPicklistMap.get(wrap.projRole.Role__c)));
                    opts.add(wrap.projRole.Role__c);
                }
            }
        }
    }


    public void addSelectedToCampaign() {
        System.debug(campaignId + '====> campaignId');
        Set<Id> contactIds = new Set<Id>();
        Boolean successBoolean = false;
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        for (EventProjectContactWrapper wrap : reportWrapperList) {
            if (wrap.selected) contactIds.add(wrap.cnt.Id);
        }
        for (Id cntId : contactIds) {
            campaignMembers.add(new CampaignMember(ContactId = cntId, CampaignId = campaignId));
        }
        List <Database.SaveResult > results = Database.insert(campaignMembers, false);
        for (Database.SaveResult r : results) {
            if (r.success) {
                successBoolean = true;
                statusMsgString = 'Contacts Added to Campaign.';
            }
        }
        if (!successBoolean) {
            statusMsgString = 'Contacts are already added to the selected Campaign';
        }
        addtoCampaignModal = false;
        errorMsg = true;
    }

    public void populateRolesPickList() {
        //FieldDescription=SObjectName.FieldName.getDescribe()
        schema.DescribeFieldResult fd = Project_Role__c.Role__c.getdescribe();

        //Get all picklist value in a list of scheme.picklistentry type
        list<schema.picklistentry> pc = fd.getpicklistvalues();
        rolesPickListSelectoptions = new List<SelectOption>();
        //Add each value in the list of selectoption
        rolesPickListSelectoptions.add(new selectoption('', ''));
        for (schema.picklistentry f : pc) {
            rolesPickListSelectoptions.add(new selectoption(f.getvalue(), f.getlabel()));
            rolesPicklistMap.put(f.getValue(), f.getLabel());
        }
    }


    public void createEventReport() {
        populateEventReportWrapper();
        EventProjectContactWrapper.compareField = sortExp;
        EventProjectContactWrapper.sortOrder = sortDirection;
        reportWrapperList.sort();
        setCon = new ReportIterable(reportWrapperList);
        next();
    }

    public void populateEventReportWrapper() {
        Set<Id> contactIds = New Set<Id>();
        List<Event__c> eventList = [SELECT ID,Name,Start_Date__c,Event_Location_Country__c FROM Event__c WHERE ID = :EventID];
        List<Event_Registrations__c> contactListOfEventRegistrations = [
                SELECT Contact__c,Event__c
                FROM Event_Registrations__c
                WHERE
                        Event__c = :EventID
        ];
        for (Event_Registrations__c eventReg : contactListOfEventRegistrations) {
            contactIds.add(eventReg.Contact__c);
        }
        Map<Id, Contact> contactsMap = new Map<id, Contact>([
                SELECT Id, Name, FirstName, LastNAme, MailingCountry, Email, HasOptedOutOfEmail
                FROM Contact
                WHERE Id IN :contactIds
        ]);
        List<Project_Role__c> contactsOfProjectRoles = new List<Project_Role__c>();
        String projectRoleQuery = 'SELECT Contact__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.Name,Contact__r.MailingCountry, Contact__r.Email,Contact__r.HasOptedOutOfEmail,Role__c,PrimaryContact__c,Asset__r.Projects__c, Asset__r.Projects__r.Name FROM Project_Role__c WHERE Contact__c IN:contactIds';
        if (String.isNotBlank(ProjectID)) {
            System.debug(ProjectID + '  ===> Project Selected');
            projectRoleQuery += ' AND Asset__r.Projects__c = :ProjectID ';
        }
        if (String.isNotBlank(selectedProjectRole)) {
            System.debug(selectedProjectRole + '  ===> Project Role Selected');
            projectRoleQuery += ' AND Role__c = :selectedProjectRole ';
        }
        if (String.isNotBlank(emailOptOut)) {
            System.debug(emailOptOut + '  ===> emailOptOut');
            if (emailOptOut == 'true') projectRoleQuery += ' AND Contact__r.HasOptedOutOfEmail = true ';
            if (emailOptOut == 'false') projectRoleQuery += ' AND Contact__r.HasOptedOutOfEmail = false ';
        }
        System.debug(projectRoleQuery + '====> projectRoleQuery');
        contactsOfProjectRoles = Database.query(projectRoleQuery);
        System.debug(contactsOfProjectRoles + '====> contactsOfProjectRoles');
        reportWrapperList = new List<EventProjectContactWrapper>();

        for (Project_Role__c projectRoles : contactsOfProjectRoles) {
            reportWrapperList.add(new EventProjectContactWrapper(eventList[0], projectRoles, contactsMap.get(projectRoles.Contact__c)));
        }
    }


    public void createProjectReport() {
        populateProjectReportWrapper();
        EventProjectContactWrapper.compareField = sortExp;
        EventProjectContactWrapper.sortOrder = sortDirection;
        reportWrapperList.sort();

        setCon = new ReportIterable(reportWrapperList);
        next();

    }

    public void populateProjectReportWrapper() {
        Set<Id> contactIds = New Set<Id>();
        List<Project_Role__c> projectRoleList = new List<Project_Role__c>();

        String projectRoleQuery = 'SELECT ID,Asset__r.Projects__r.Name,Role__c,PrimaryContact__c, Contact__c FROM Project_Role__c WHERE Asset__r.Projects__c = :ProjectID';
        if (String.isNotBlank(selectedProjectRole)) {
            projectRoleQuery += ' AND Role__c = :selectedProjectRole';
        }
        projectRoleList = Database.query(projectRoleQuery);

        Map<Id, Project_Role__c> project_roleMap = new Map<Id, Project_Role__c>();
        for (Project_Role__c projectRole : projectRoleList) {
            contactIds.add(projectRole.Contact__c);
            project_roleMap.put(projectRole.Contact__c, projectRole);
        }
        Map<Id, Contact> contactsMap = new Map<id, Contact>([
                SELECT Id, Name, FirstName, LastNAme, MailingCountry, Email, HasOptedOutOfEmail
                FROM Contact
                WHERE Id IN :contactIds
        ]);

        List<Event_Registrations__c> eventRegistrationsList = [
                SELECT Contact__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingCountry,
                        Contact__r.Email,Contact__r.Name,Contact__r.HasOptedOutOfEmail,Event__r.Name,Event__r.Start_Date__c,Event__r.Event_Location_Country__c
                FROM Event_Registrations__c
                WHERE Contact__c IN :contactIds
        ];

        reportWrapperList = new List<EventProjectContactWrapper>();

        for (Event_Registrations__c eventReg : eventRegistrationsList) {
            Event__c event = new Event__c(
                    Id = eventReg.Event__c,
                    Name = eventReg.Event__r.Name,
                    Event_Location_Country__c = eventReg.Event__r.Event_Location_Country__c,
                    Start_Date__c = eventReg.Event__r.Start_Date__c
            );
            reportWrapperList.add(new EventProjectContactWrapper(event, project_roleMap.get(eventReg.Contact__c), contactsMap.get(eventReg.Contact__c)));
        }
    }


    public void sortWrapperList() {
        System.debug('##CampareF :' + sortExp);
        System.debug('##sortO :' + sortDirection);
        EventProjectContactWrapper.compareField = sortExp;
        EventProjectContactWrapper.sortOrder = sortDirection;
        System.debug('##reportWrapperList :' + reportWrapperList);
        reportWrapperList.sort(); // Sorting wrapper list
        System.debug('##reportWrapperList :' + reportWrapperList);
        setCon = new ReportIterable (reportWrapperList);
        next();
    }


    public class ReportIterable implements Iterator<list<EventProjectContactWrapper>> {
        list<EventProjectContactWrapper> InnerList { get; set; }
        list<EventProjectContactWrapper> ListRequested { get; set; }

        public Integer i { get; set; }
        public Integer setPageSize { get; set; }
        public Integer PageSize { get; set; }
        public Integer totalPages { get; set; }
        public Integer pageNumber { get; set; }


        public ReportIterable(List<EventProjectContactWrapper> lstAccWr) {
            InnerList = new list<EventProjectContactWrapper>();
            ListRequested = new list<EventProjectContactWrapper>();
            InnerList = lstAccWr;
            setPageSize = 200;
            i = 0;
            pageNumber = 0;
            totalPages = InnerList.size() / setPageSize + 1;
        }

        public boolean hasNext() {
            if (i >= InnerList.size()) {
                return false;
            } else {
                return true;
            }
        }

        public boolean hasPrevious() {
            if (i <= setPageSize) {
                return false;
            } else {
                return true;
            }
        }

        public list<EventProjectContactWrapper> previous() {
            ListRequested = new list<EventProjectContactWrapper >();
            integer size = InnerList.size();
            if (i == size) {
                if (math.mod(size, setPageSize) > 0) {
                    i = size - math.mod(size, setPageSize);
                } else {
                    i = (size - setPageSize);
                }
            } else {
                i = (i - setPageSize);
            }

            for (integer start = (i - setPageSize); start < i; ++start) {
                ListRequested.add(InnerList[start]);
            }
            PageSize = ListRequested.size();
            pageNumber--;
            return ListRequested;
        }

        public list<EventProjectContactWrapper> next() {
            ListRequested = new list<EventProjectContactWrapper>();
            integer startNumber;
            integer size = InnerList.size();
            if (hasNext()) {
                if (size <= (i + setPageSize)) {
                    startNumber = i;
                    i = size;
                } else {
                    i = (i + setPageSize);
                    startNumber = (i - setPageSize);
                }

                for (integer start = startNumber; start < i; start++) {
                    ListRequested.add(InnerList[start]);
                }
            }
            System.debug('ListRequested :' + ListRequested.size());
            PageSize = ListRequested.size();
            pageNumber++;
            return ListRequested;
        }
    }


}