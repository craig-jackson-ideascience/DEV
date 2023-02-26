public class ReportSettingCtrl{
    public EventWrapper eventsWrapper{get;set;}
    public EventWrapper projectsWrapper{get;set;}
    public String selectedProduct{get;set;}
    public String selectedProject{get;set;}
    public String selectedEvent{get;set;}
    public Map<String,Map<ID,set<id>>> eventAccountMap{get;set;}
    public list<EventWrapperReport> eventReport{get;set;}
    public Map<String,Map<String,list<String>>> accountProductMap{get;set;}  
    public String eventReportCsv {get;set;}
    public Map<String,String> accountNameIDMap{get;set;}
    public Map<String,String> productNameIDMap{get;set;}
    public Map<String,String>ProductNameMemberLevelMap{get;set;}
    public list<SelectOption> eventsName{get;set;}
    public ReportSettingCtrl(){
        eventAccountMap = new Map<String,Map<ID,set<id>>>();
        accountNameIDMap = new Map<String,String>();
        productNameIDMap = new Map<String,String>();
        ProductNameMemberLevelMap = new Map<String,String>();
        eventsName = new list<SelectOption>();
        selectedProduct = '';
        selectedProject = '';
        selectedEvent ='';
        Report_Settings__c reportSetting = Report_Settings__c.getInstance('Kubecone Event');
        String jsonString = reportSetting.Filter__c;
        system.debug('#---#'+jsonString);

        eventsWrapper = (EventWrapper)JSON.deserialize(jsonString, EventWrapper.class);
        selectedProduct = multiselectString(eventsWrapper.Events.ProductName);
        String jsonStringProj = reportSetting.Project_Filter__c;
        system.debug('#-----jsonStringProj-----#'+jsonStringProj);
        projectsWrapper = (EventWrapper)JSON.deserialize(jsonStringProj, EventWrapper.class);
        
        selectedProject = multiselectString(projectsWrapper.Projects.ProjectName);
        system.debug('==================selectedProject======='+selectedProject);
        selectedEvent = multiselectString(projectsWrapper.Projects.EventName);

        Integer Year = Date.Today().Year();
        eventsWrapper.Events.EventEndDate = eventsWrapper.Events.EventEndDate ==  eventsWrapper.Events.EventStartDate ?  date.parse('12/31/'+Year) : eventsWrapper.Events.EventEndDate;
        system.debug('selectedProduct#'+selectedProduct);
        createReport();
         if(selectedProject!=null){
            getEventNameValues();
         }
         
    }
    
    public static EventWrapper parse(String json) {
        return (EventWrapper) System.JSON.deserialize(json, EventWrapper.class);
    }
    /*public static ProjectWrapper parse(String json){
        return (ProjectWrapper) System.JSON.deserialize(json, ProjectWrapper.class);
    }*/
    
    public list<SelectOption> getProductName(){
        list<Product2> productList = [select id,name from Product2 where isactive = TRUE AND Name IN ('Diamond Sponsorship','Platinum Sponsorship','Gold Sponsorship','Silver Sponsorship') limit 1000];
        list<SelectOption> productsName = new list<SelectOption>();
        for(Product2 productsTemp : productList){
            productsName.add(new SelectOption(productsTemp.name,productsTemp.name));
        }
        system.debug('=============productsName====='+productsName);
        return productsName;
    }
    public list<SelectOption>getProjectName(){
        
        list<Asset> AssetList = [select id,name,Bill_From__c,Bill_From_ID__r.Name from Asset WHERE Bill_From_ID__c!=null order by Bill_From_ID__r.Name ASC];
        list<SelectOption> projectsName = new list<SelectOption>();
        Set<String>BillFromValues = new Set<String>();
        
        
        for(Asset projectsTemp : AssetList){
            BillFromValues.add(projectsTemp.Bill_From_ID__r.Name);
        }
        system.debug('=================billfromvalues=='+billfromvalues);
        for(String str:BillFromValues){
            projectsName.add(new SelectOption(str,str));
        }
        system.debug('=====================projectsName==='+projectsName);
        return projectsName;
        
    }
    public void getEventNameValues(){
        list<String> selectedOptionValProject = multiselectList(selectedProject);
        system.debug('======selectedOptionValProject='+selectedOptionValProject);
        //list<Asset> AssetList = [select id,name,Bill_From__c,Event__r.Name from Asset WHERE Bill_From__c!=null AND Bill_From__c IN:selectedOptionValProject AND Event__c!=null order by name ASC];
        List<Event__c>EventList = new List<Event__c>();
        EventList = [SELECT Id, Name, BillFromProject__c,BillFromProject__r.Name  FROM Event__c WHERE BillFromProject__r.name IN:selectedOptionValProject AND BillFromProject__c!=null ORDER BY Name ASC ];

        list<SelectOption>TempeventsName = new list<SelectOption>();
        eventsName = new List<SelectOption>();
         Set<String>BillFromEvents = new Set<String>();
        for(Event__c projectsTemp : EventList){
            BillFromEvents.add(projectsTemp.Name);
        }
        for(String str:BillFromEvents){
            eventsName.add(new SelectOption(str,str));
        }
        eventsName.sort();
        Report_Settings__c reportSetting = Report_Settings__c.getInstance('Kubecone Event');
        String jsonString = reportSetting.Filter__c;
        system.debug('#---#'+jsonString);
        eventsWrapper = (EventWrapper)JSON.deserialize(jsonString, EventWrapper.class);
        selectedProduct = multiselectString(eventsWrapper.Events.ProductName);
        system.debug('======EventList='+eventsName);
        system.debug('======BillFromEvents='+BillFromEvents.size());
        //return eventsName;
    }
    public void LoadEventsfromProjects(){
        list<String> selectedOptionValProject = multiselectList(selectedProject);
          //selectedProject = multiselectList(selectedProject);
         system.debug('========LoadEventsfromProjects==='+selectedOptionValProject);
        if(selectedOptionValProject!=null){
            getEventNameValues();
        }
    }
    public void createReport(){
     system.debug('#-under create seleted pro-#'+selectedProduct);
     list<String> selectedOptionVal = multiselectList(selectedProduct);
     list<String> selectedOptionValProject = multiselectList(selectedProject);
     Map<Integer,list<String>> orderBYMap = new Map<Integer,list<String>>();   
     system.debug('#-selectedOptionVal-#'+selectedOptionVal);
     system.debug('=========selectedOptionValProject======'+selectedOptionValProject);
     list<String> selectedOptionValEvents = multiselectList(selectedEvent);
     system.debug('========selectedEvent======='+selectedOptionValEvents);
     eventReport = new list<EventWrapperReport>();
     accountProductMap = new Map<String,Map<String,list<String>>> (); 
     String eventNameText = '%'+eventsWrapper.Events.EventName+'%'; 
     system.debug('======eventNameText='+eventNameText);
     Date startDate =  eventsWrapper.Events.EventStartDate;  
     Date endDate =  eventsWrapper.Events.EventEndDate;  
     AggregateResult[] groupedResults = [SELECT Event__r.Name event, Account.id acc ,Product2.Name prod, 
                                         Count(Product2ID) FROM asset where Event__r.Name 
                                         in : selectedOptionValEvents and event__r.start_date__c >= :startDate
                                         and event__r.End_Date__c <= :endDate
                                         and Product2.Name in : selectedOptionVal
                                         and AccountId !=null and Event__c != null and Product2id != null 
                                         GROUP BY ROLLUP (Event__r.Name,Account.id,Product2.Name)];
       
     AggregateResult[] groupedResultsOpp = [SELECT Event__r.Name event, Opportunity.Account.id acc ,Product2.Name prod, 
                                         Count(Product2ID) FROM OpportunityLineItem where Event__r.Name 
                                         in:selectedOptionValEvents and event__r.start_date__c>= :startDate
                                         and event__r.End_Date__c <= :endDate
                                         and Product2.Name in : selectedOptionVal
                                         and Opportunity.Account.id !=null and Event__c != null and Product2id != null and Opportunity.StageName!='Closed Won' and Opportunity.StageName!='Closed Lost'
                                         GROUP BY ROLLUP (Event__r.Name,Opportunity.Account.id,Product2.Name)];
       
    
        set<String> eventName  = new set<String>();
        set<String> accountID  = new set<String>();
        set<String>  ProductIds= new set<String>();
        Map<String,Map<String,set<String>>> accountEventProductMap = new Map<String,Map<String,set<String>>>(); 
        //Map<String,String> accountTempVar = new Map<String,String>(); 
        set<String> temSet = new Set<String>(); 
        for(AggregateResult ar : groupedResults){
            if(!String.isEmpty((String)ar.get('prod'))){
            eventName.add((String)ar.get('event'));
            accountId.add((String)ar.get('acc'));
            ProductIds.add((String)ar.get('prod'));
            }
        }
        for(AggregateResult ar : groupedResultsOpp){
            if(!String.isEmpty((String)ar.get('prod'))){
            eventName.add((String)ar.get('event'));
            accountId.add((String)ar.get('acc'));
            ProductIds.add((String)ar.get('prod'));
            }
        }
        
        List<OpportunityLineItem>OppLines = new List<OpportunityLineItem>();
        //OppLines = [SELECT id,Name,OpportunityId,Product2.Name from OpportunityLineItem where Product2.Name IN:ProductIds AND  ];
        
        List<Account> accountList = [select id,Name from Account where id in:accountId];
        Map<String,String> accountNameMap = new  Map<String,String>();
        for(Account acc : accountList){
            accountNameMap.put(acc.id,acc.Name);
            accountNameIDMap.put(acc.Name,acc.id);
            ProductNameMemberLevelMap.put(acc.Name,'');
        }
        List<Asset>PurchaseHistoryRecords = new List<Asset>();
        //PurchaseHistoryRecords = [SELECT ID,name,Account.Name,Projects__c,Projects__r.Name,Product2.Name from Asset WHERE AccountID IN:accountId AND Projects__r.Name='Cloud Native Computing Foundation' AND Status='Active'];
        PurchaseHistoryRecords = [SELECT ID,name,Account.Name,Projects__c,Projects__r.Name,Product2.Name from Asset WHERE AccountID IN:accountId AND Projects__r.Name IN:selectedOptionValProject AND Status='Active'];
        for(Asset arec:PurchaseHistoryRecords){
            //if(!ProductNameMemberLevelMap.Containskey(arec.Account.Name)){
               String ProductVal = arec.Product2.Name;
               String ProductName = ProductVal.Replace('Membership','');
                ProductNameMemberLevelMap.put(arec.Account.Name,ProductName);
            //}
        }
        system.debug('=================ProductNameMemberLevelMap==='+ProductNameMemberLevelMap.values());
        
        List<Product2> ProdList = [select id,Name from Product2 where Name in:ProductIds];
        for(Product2 pro : ProdList){
            if(!productNameIDMap.containsKey(pro.name))
                productNameIDMap.put(pro.Name,pro.id);
            else
                productNameIDMap.get(pro.Name);
        }
        for(String eventNameVar : eventName){
            Map<String,list<String>> tempMapVar = new  Map<String,list<String>>(); 
            for(String accountNameVar : accountNameMap.values()){
                //system.debug('#--eventNameVar-#'+eventNameVar);
                tempMapVar.put(accountNameVar,new list<String>{''});
                accountProductMap.put(eventNameVar,tempMapVar);
            }
        }
        
       for(AggregateResult ar : groupedResults){
          temSet.add((String)ar.get('event'));
            Map<String,String> accountTempVar = new Map<String,String>(); 
            if((String)ar.get('event') != null){
                if((String)ar.get('acc') != null && (String)ar.get('prod') != null){
                    String tempString = (String)ar.get('event');
                    if(accountProductMap.containsKey(tempString)){
                        //system.debug('#-accountProductMap-#'+accountProductMap);
                        //system.debug('#-(String)ar.get(event) -#'+(String)ar.get('event'));
                        if(accountProductMap.get(tempString).containskey(accountNameMap.get((String)ar.get('acc')))){
                            if((Integer)ar.get('expr0') > 0){
                            if(accountProductMap.get(tempString).containskey(accountNameMap.get((String)ar.get('acc')))){
                                    accountProductMap.get(tempString).get(accountNameMap.get((String)ar.get('acc'))).add((String)ar.get('prod'));
                                }
                                else{
                                    accountProductMap.get(tempString).put(accountNameMap.get((String)ar.get('acc')),new list<String>{(String)ar.get('prod')});
                                } 
                            }
                            //system.debug('#-accountProductMapNEXT-#'+accountProductMap.get(tempString));
                        }
                    }
                    
                }
            }
        }
        
        for(AggregateResult ar : groupedResultsOpp){
          temSet.add((String)ar.get('event'));
            Map<String,String> accountTempVar = new Map<String,String>(); 
            if((String)ar.get('event') != null){
                if((String)ar.get('acc') != null && (String)ar.get('prod') != null){
                    String tempString = (String)ar.get('event');
                    if(accountProductMap.containsKey(tempString)){
                        //system.debug('#-accountProductMap-#'+accountProductMap);
                        //system.debug('#-(String)ar.get(event) -#'+(String)ar.get('event'));
                        if(accountProductMap.get(tempString).containskey(accountNameMap.get((String)ar.get('acc')))){
                            if((Integer)ar.get('expr0') > 0){
                            if(accountProductMap.get(tempString).containskey(accountNameMap.get((String)ar.get('acc')))){
                                    accountProductMap.get(tempString).get(accountNameMap.get((String)ar.get('acc'))).add((String)ar.get('prod')+'-Pending');
                                }
                                else{
                                    accountProductMap.get(tempString).put(accountNameMap.get((String)ar.get('acc')),new list<String>{(String)ar.get('prod')+'-Pending'});
                                } 
                            }
                           // system.debug('#-accountProductMapNEXT-#'+accountProductMap.get(tempString));
                        }
                    }
                    
                }
            }
        }
                
        List<String> eventNameList =new List<String>();
        eventNameList.addAll(eventName);
        eventNameList.sort();
         List<String> eventNameListSorting =new List<String>();

        List<Event__c> EventList = new List<Event__c>();
        EventList = [SELECT ID,Name from Event__c WHERE Name IN:eventNameList ORDER BY Start_Date__c ASC];
        for(Event__c eve:EventList){
            eventNameListSorting.add(eve.Name);
            
        }
        /*Event_Sorting__mdt[] eventsorting = [SELECT MasterLabel, QualifiedApiName, Event_Name__c,Sort_Order__c FROM Event_Sorting__mdt ORDER  BY Sort_Order__c ASC];
        List<String> eventNameListSort =new List<String>();
        for(Event_Sorting__mdt eventmeta:eventsorting){
            if(eventNameList.contains(eventmeta.Event_Name__c)){
                eventNameListSort.add(eventmeta.Event_Name__c);
                
            }
        }*/
        List<String> accountListTemp = new List<String>();
        accountListTemp.addAll(accountNameMap.values());
        accountListTemp.sort();
        eventReport.add(new EventWrapperReport(accountListTemp,eventNameListSorting));
    }
    private String multiselectString(list<String> optionValue){
        String TempVal = '';
        for(String productName : optionValue){
            TempVal +=productName+',';
        }
       TempVal = '['+TempVal.removeEnd(',')+']';
        return TempVal;
    }
    public void createCsv(){
        //String eventReportCsv;
        String[] headerArray = new list<String>();
        headerArray.add(format('Company Name'));
        for(EventWrapperReport eventReport : eventReport){
            for(String eventName : eventReport.eventName){
            headerArray.add(format(eventName));
            }
        }
       
        eventReportCsv = csvFormat(accountProductMap,line(headerArray).escapeUnicode());
    }
    
     private String line(String[] cells) {
        return String.join(cells, ',') + '\n';
    }
    private String format(Date d)    {
        return d != null ? d.format().escapeCsv() : '""';
    }
    private String format(String s) {
        String temp = s != null ?  s.escapeCsv() : '""';
            system.debug('---'+temp);
          return temp;
        
    }
    
    private String csvFormat( Map<String,Map<String,list<String>>> csvFormatMap,String headerarray){
      
        for(EventWrapperReport eventVarTemp : eventReport){
            for(string AccountName : eventVarTemp.accountName){
                String[] csvBodyArray = new list<String>();
                system.debug('#-AccountName-#'+AccountName);
                csvBodyArray.add(format(AccountName));
                for(String eventName : eventVarTemp.eventName){
                    String tempist = '';
                    Integer i = 0;
                    for(String productList : csvFormatMap.get(eventName).get(AccountName)){
                        i++;
                        if(!String.isEmpty(productList)){
                        tempist += csvFormatMap.get(eventName).get(AccountName).size() !=  i ? productList+',':productList;
                        }
                    }
                    csvBodyArray.add(format(tempist));
                }
                headerarray+= line(csvBodyArray).escapeUnicode();
            }
        }
        return headerarray;
    }
    
    public list<String> multiselectList(String optionValue){
        list<String> selectedOptionSet = new list<String>();
        String tempVal =  optionValue.removeEnd(']').removeStart('[');
        list<String> selectedOptionList = new list<String>();
        for(String temp : tempVal.split(','))
        {
            selectedOptionList.add(temp.trim()); 
        }
        return selectedOptionList;
    }    
    
    public class EventWrapperReport{
        public list<String> accountName{get;set;}
        public list<String> eventName{get;set;}
        public EventWrapperReport(list<String> accountName,list<String> eventName){
            this.accountName = accountName;
            this.eventName = eventName;
        }
    }
}