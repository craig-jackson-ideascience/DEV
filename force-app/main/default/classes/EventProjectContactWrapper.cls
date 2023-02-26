public class EventProjectContactWrapper implements Comparable {
    public Boolean selected { get; set; }
    public Event__c event { get; set; }
    public Project_Role__c projRole { get; set; }
    public Contact cnt { get; set; }
    public static String compareField { get; set; } // Variable to hold the value of Field / Column for Sorting
    public static String sortOrder { get; set; } // Variable to hold the order for Sorting (ASC/DESC)

    public EventProjectContactWrapper(Event__c event, Project_Role__c projRole, Contact cnt) {
        this.event = event;
        this.projRole = projRole;
        this.cnt = cnt;
        this.selected = true;
    }

    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {

        EventProjectContactWrapper compareToEmp = (EventProjectContactWrapper) compareTo;
        switch on compareField {
            when 'cnt.Name' {
                return sortByContactName(compareToEmp);
            }
            when 'cnt.FirstName' {
                return sortByContactFirstName(compareToEmp);
            }
            when 'cnt.LastName' {
                return sortByContactLastName(compareToEmp);
            }
            when 'cnt.MailingCountry' {
                return sortByContactMailingCountry(compareToEmp);
            }
            when 'cnt.Email' {
                return sortByContactEmail(compareToEmp);
            }
            when 'cnt.HasOptedOutOfEmail' {
                return sortByHasOptedOutOfEmail(compareToEmp);
            }
            when 'projRole.Asset__r.Projects__r.Name' {
                return sortByProjectName(compareToEmp);
            }
            when 'projRole.Role__c' {
                return sortByProjectRole(compareToEmp);
            }
            when 'projRole.PrimaryContact__c' {
                return sortByPrimaryContact(compareToEmp);
            }
            when 'event.Name' {
                return sortByEventName(compareToEmp);
            }
            when 'event.Start_Date__c' {
                return sortByEventStartDate(compareToEmp);
            }
            when 'event.Event_Location_Country__c' {
                return sortByEventCountry(compareToEmp);
            }
            when else {
                return sortByContactName(compareToEmp);
            }
        }

    }


    private Integer sortByContactName(EventProjectContactWrapper compareToEmp) {
        if (cnt.Name > compareToEmp.cnt.Name) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (cnt.Name < compareToEmp.cnt.Name) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }

    private Integer sortByContactFirstName(EventProjectContactWrapper compareToEmp) {
        if (cnt.FirstName > compareToEmp.cnt.FirstName) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (cnt.FirstName < compareToEmp.cnt.FirstName) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }

    private Integer sortByContactLastName(EventProjectContactWrapper compareToEmp) {
        if (cnt.LastName > compareToEmp.cnt.LastName) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (cnt.LastName < compareToEmp.cnt.LastName) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }

    private Integer sortByContactMailingCountry(EventProjectContactWrapper compareToEmp) {
        if (cnt.MailingCountry > compareToEmp.cnt.MailingCountry) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (cnt.MailingCountry < compareToEmp.cnt.MailingCountry) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }

    private Integer sortByContactEmail(EventProjectContactWrapper compareToEmp) {
        if (cnt.Email > compareToEmp.cnt.Email) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (cnt.Email < compareToEmp.cnt.Email) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }
    private Integer sortByHasOptedOutOfEmail(EventProjectContactWrapper compareToEmp) {
        if (String.valueOf(cnt.HasOptedOutOfEmail) > String.valueOf(compareToEmp.cnt.HasOptedOutOfEmail)) {
            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (String.valueOf(cnt.HasOptedOutOfEmail) < String.valueOf(compareToEmp.cnt.HasOptedOutOfEmail)) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }

    private Integer sortByProjectName(EventProjectContactWrapper compareToEmp) {
        if (projRole.Asset__r.Projects__r.Name > compareToEmp.projRole.Asset__r.Projects__r.Name) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (projRole.Asset__r.Projects__r.Name < compareToEmp.projRole.Asset__r.Projects__r.Name) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }
    private Integer sortByProjectRole(EventProjectContactWrapper compareToEmp) {
        if (projRole.Role__c > compareToEmp.projRole.Role__c) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (projRole.Role__c < compareToEmp.projRole.Role__c) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }
    private Integer sortByPrimaryContact(EventProjectContactWrapper compareToEmp) {
        if (String.valueOf(projRole.PrimaryContact__c) > String.valueOf(compareToEmp.projRole.PrimaryContact__c)) {
            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (String.valueOf(projRole.PrimaryContact__c) < String.valueOf(compareToEmp.projRole.PrimaryContact__c)) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }
    private Integer sortByEventName(EventProjectContactWrapper compareToEmp) {
        if (event.Name > compareToEmp.event.Name) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (event.Name < compareToEmp.event.Name) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }
    private Integer sortByEventStartDate(EventProjectContactWrapper compareToEmp) {
        if (event.Start_Date__c > compareToEmp.event.Start_Date__c) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (event.Start_Date__c < compareToEmp.event.Start_Date__c) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }
    private Integer sortByEventCountry(EventProjectContactWrapper compareToEmp) {
        if (event.Event_Location_Country__c > compareToEmp.event.Event_Location_Country__c) {

            return (sortOrder.equals('ASC') ? 1 : -1);
        } else if (event.Event_Location_Country__c < compareToEmp.event.Event_Location_Country__c) {
            return (sortOrder.equals('ASC') ? -1 : 1);
        }
        return 0;
    }
}