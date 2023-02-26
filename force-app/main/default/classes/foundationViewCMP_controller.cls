/****************
* Created Date: 12 SEP 2019
* Class Name : foundationViewCMP_controller
* Type : Aura Class
* 
* 
* 
*****************/
public class foundationViewCMP_controller {
    
    @AuraEnabled
    public static String getLoggedInUserRole_Apex() {
        system.debug('in Method getLoggedInUserRole_Apex>>>>>');        
        String loogedInUserId;
        User userDetails = new User();        
        loogedInUserId = UserInfo.getUserId();
        system.debug('Loggged USER ID>>>>>>' + loogedInUserId);        
        userDetails = [SELECT Id, Name, UserRole.Name FROM User WHERE Id=:loogedInUserId];
        system.debug('Logged in USER DETAILS>>>> ' + userDetails + ' Logged in USER DETAILS>>>>' + userDetails.Name);
        if(userDetails.UserRole.Name != null) {
            return userDetails.UserRole.Name;
        }
        return null;
    }
    
    /*@AuraEnabled 
public static List<String> getProductDetails(String selectedProjName){
List<Asset> AssetList =new List<Asset>();
List<String> linuxProdList =new List<String>();
set<String>Productset = new set<String>();
List<String>ProductNames = new List<String>();

if(selectedProjName =='Academy Software Foundation'){
AssetList =[Select ID, Product2.Name From Asset Where projects__r.Name= : selectedProjName];
Productset.add('Silver Membership - MSFP');
}
else if(selectedProjName =='The Linux Foundation'){
AssetList =[Select ID, Product2.Name From Asset Where projects__r.Name= : selectedProjName AND Product2.Name !='Silver Membership - MSFP'];

// ProductNames.remove('Silver Membership - MSFP');
}
else{
AssetList =[Select ID, Product2.Name From Asset Where projects__r.Name= : selectedProjName];
}

for(Asset ast :AssetList){
Productset.add(ast.Product2.Name);
}
ProductNames.addAll(Productset);
return ProductNames;
}*/
    
    @AuraEnabled
    public static list<ProjectListWrapper> getFoundationDeails_Apex(String sortField, boolean isAsc) {
        list<ProjectListWrapper> projectListWrapper = new list<ProjectListWrapper>();
        list<Project__c> fndtnList = new list<Project__c>();
        list<Project__c> finalList = new list<Project__c>();
        list<Project__c> tempfndtnList = new list<Project__c>();
        list<RecordType> recordTypelst = new list<RecordType>();
        
        recordTypelst =[Select Id,Name From RecordType where sobjecttype = 'Opportunity' AND Name ='Membership' LIMIT 1];
        String recordTypeID = recordTypelst[0].Id;
        
        String loogedInUserId;
        String sSoql;
        User userDetails = new User();        
        loogedInUserId = UserInfo.getUserId();
        system.debug('Loggged USER ID>>>>>>' + loogedInUserId);        
        userDetails = [SELECT Id, Name, UserRole.Name FROM User WHERE Id=:loogedInUserId];
        system.debug('Logged in USER DETAILS>>>> ' + userDetails + ' Logged in USER Name>>>>' + userDetails.Name);
        
        String columns = 'Id, Name, Project_Type__c, Owner.Name, Owner.UserRole.Name, Executive_Director__c, Executive_Director__r.Name, Executive_Director_U__c, Executive_Director_U__r.Name, Program_Manager__c, Program_Manager__r.Name, Program_Manager_U__c, Program_Manager_U__r.Name ,Business_Development_Manager__c,Business_Development_Manager__r.Name,Business_Development_Manager_U__c,Business_Development_Manager_U__r.Name';
        sSoql = 'SELECT ' + columns + ' FROM Project__c';
        //String projectType = 'Foundation';
        if(userDetails.UserRole.Name == 'Program Manager' ) {            
            //sSoql += ' WHERE Id IN (Select Project__c From Product_Details__c Where RecordTypeID =:recordTypeID AND Status__c =\'Active\') AND Status__c = \'Active\' and (Program_Manager_U__c =: loogedInUserId OR Executive_Director_U__c =: loogedInUserId)';
            //sSoql += ' WHERE Id IN (Select Projects__c From Asset Where RecordTypeID =:recordTypeID AND ProductFamily =\'Membership\') AND Status__c = \'Active\' and (Program_Manager_U__c =: loogedInUserId OR Executive_Director_U__c =: loogedInUserId)';
            sSoql += ' WHERE Id IN (Select Project_Name__c From Opportunity Where RecordTypeID =:recordTypeID) AND (Program_Manager_U__c =: loogedInUserId OR Executive_Director_U__c =: loogedInUserId)';
        }else {
            //sSoql += ' WHERE Id IN (Select Project__c From Product_Details__c Where RecordTypeID =:recordTypeID AND Status__c =\'Active\') AND Status__c = \'Active\' ';
            //sSoql += ' WHERE Id IN (Select Projects__c From Asset Where RecordTypeID =:recordTypeID AND ProductFamily =\'Membership\') AND Status__c = \'Active\' ';
            sSoql += ' WHERE Id IN (Select Project_Name__c From Opportunity Where RecordTypeID =:recordTypeID) ';
        }
        
        integer intCampareVal=0;
        if(sortField != '') {
            sSoql += 'order by ' + sortField;            
            //if isAsc is equal to true then set 'asc' order otherwise set 'desc' order.
            if(isAsc) {
                sSoql += ' ASC NULLS LAST';
                //intCampareVal=0;
            } else {
                sSoql += ' DESC NULLS LAST';
                //intCampareVal=fndtnList.size()-1;
            }      
        }
        try {
            System.debug('Query string is'+sSoql);
            fndtnList = Database.query(sSoql);
            intCampareVal=0;
            if(userDetails.UserRole.Name == 'Business Development Manager' ) {  
                for(Project__c  pro : fndtnList ){
                    if(pro.Business_Development_Manager_U__c == loogedInUserId){
                        finalList.add(pro);
                    }
                    else{
                        tempfndtnList.add(pro); 
                    }
                }
                finalList.addAll(tempfndtnList);
                fndtnList = finalList;
            }
                for(integer i=0;i<=fndtnList.size()-1;i++){	
                    if(i==intCampareVal) {
                        projectListWrapper.add(new ProjectListWrapper(true, fndtnList[i], null));
                    } else {
                        projectListWrapper.add(new ProjectListWrapper(false, fndtnList[i], null));
                    }
                }
            
            system.debug(projectListWrapper.size()+' :::: '+Json.serialize(projectListWrapper)+'<===projectListWrapper:::@SK::::======>' + projectListWrapper.size());
            if(projectListWrapper.size() > 0) {
                return projectListWrapper;
            } 
        } catch(Exception ex) {
            return null;
        }
        return null;
    }
    /* wrapper class */  
    public class ProjectListWrapper {
        @AuraEnabled public boolean isChecked { get; set; }
        @AuraEnabled public  Project__c objProject { get; set; }
        @AuraEnabled public  Project__c objProjectForPM { get; set; }
        public ProjectListWrapper(boolean isChecked, Project__c objProject, Project__c objProjectForPM){
            this.isChecked = isChecked;
            this.objProject = objProject;
            this.objProjectForPM = objProjectForPM;
        }
    }    
}