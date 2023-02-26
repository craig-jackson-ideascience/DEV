public class FindProject {
    public Id OppID{get;set;}
    public opportunity objopp{
        get{
           return [Select id,name,Account.Name,Owner.Name,Amount from opportunity where id=:OppID limit 1]; 
        }set;
    }
    public OpportunityLineItem objoppLine{
        get{
            return [Select id,Projects__r.name,Start_Date__c from OpportunityLineItem where opportunity.id=:OppID limit 1];
        }set;
    }
    
    public Project__c objpro{
        get{
            string ProjectName=[Select id,Projects__r.name from OpportunityLineItem where opportunity.id=:OppID limit 1].Projects__r.name;
            return [Select id,Program_Manager__r.name from Project__c where name=:ProjectName];
        }set;
    }
}