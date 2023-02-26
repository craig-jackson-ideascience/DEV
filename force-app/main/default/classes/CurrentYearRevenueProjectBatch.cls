global class CurrentYearRevenueProjectBatch implements database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext bc){
		String query = '';
		Integer currentYear = system.today().year();
		Integer currentMonth = system.today().month();
		Integer currentDay = system.today().day();
		//This will calculate the current year revenue for all the projects on first day of new year
		if (currentMonth == 1 && currentDay == 1){
			query = 'Select Id, Current_Year_Revenue__c From Project__c ';
		} else{
			query = 'select id, Current_Year_Revenue__c From Project__c Where ID IN (Select Projects__c From Asset Where Status!=\'Invoice Cancelled\' AND Status != \'Associate Cancelled\' AND (PurchaseDate=THIS_YEAR OR InstallDate=THIS_YEAR) AND LastModifiedDate = Today)';
		}
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<Project__c> projectRecord){

		set<Id> setProjectId = new set<Id>();
		map<Id, List<Asset>> mapProId_lstAsset = new map<Id, List<Asset>>();

		for (Project__c prjctObj : projectRecord){
			setProjectId.add(prjctObj.Id);
		}

		FOR (Asset a : [Select Id, Price, Projects__c, Status, PurchaseDate, InstallDate
		                From Asset
		                Where Projects__c IN :setProjectId AND Status != 'Invoice Cancelled' AND Status != 'Associate Cancelled' AND (PurchaseDate = THIS_YEAR OR InstallDate = THIS_YEAR)]){
			if (!mapProId_lstAsset.containsKey(a.Projects__c)){
				mapProId_lstAsset.put(a.Projects__c, new List<Asset>{a});
			} else{
				mapProId_lstAsset.get(a.Projects__c).add(a);
			}
		}

		for (Project__c prjctObj : projectRecord){
			List<Project__c> lstProject = new List<Project__c>();
			Integer currentYear = system.today().year();
			prjctObj.Current_Year_Revenue__c = 0;
			//List<Asset> lstAsset = [Select Id,Price,Projects__c,Status,PurchaseDate,InstallDate From Asset Where Projects__c =:prjctObj.Id AND Status!='Invoice Cancelled' AND ((PurchaseDate != null AND CALENDAR_YEAR(PurchaseDate)=:currentYear) OR (InstallDate!=null AND CALENDAR_YEAR(InstallDate)=:currentYear))] ;
			//if(lstAsset.size()>0){
			if (mapProId_lstAsset.containsKey(prjctObj.Id)){
				for (Asset asstObj : mapProId_lstAsset.get(prjctObj.Id)){
					asstObj.price = asstObj.price == null ? 0:asstObj.price;
					system.debug('Asset price is' + asstObj.price);
					prjctObj.Current_Year_Revenue__c = prjctObj.Current_Year_Revenue__c == 0 ? asstObj.price : (prjctObj.Current_Year_Revenue__c + asstObj.price);
				}
			}
			lstProject.add(prjctObj);
			//}

			if (lstProject.size() > 0){
				Database.SaveResult[] saveResultList = Database.update(lstProject);
				for (Database.SaveResult dsr : saveResultList){
					if (!dsr.isSuccess()){
						system.debug(Logginglevel.ERROR, 'NOT SUCCESS!!' + dsr.getId());
					}
				}
			}
		}
	}

	global void finish(Database.BatchableContext bc){
		//Scheduling a Batch for next Year
	}
}