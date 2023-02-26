global class CurrentYearSpendOnAccountBatch implements database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext bc){
		String query = '';
		Integer currentYear = system.today().year();
		Integer currentMonth = system.today().month();
		Integer currentDay = system.today().day();
		set<id> AccountIds = new set<Id>();
		String customLabelValue = System.Label.Individual_No_Account;
		system.debug('customLabelValue-->' + customLabelValue);
		if (currentMonth == 12 && currentDay == 31){
			currentYear += 1;
			for (Asset objAsset : [SELECT Id, AccountId
			                       FROM Asset
			                       WHERE Status != 'Invoice Cancelled' AND Status != 'Associate Cancelled' AND ((PurchaseDate != null AND CALENDAR_YEAR(PurchaseDate) = :currentYear) OR (InstallDate != null AND CALENDAR_YEAR(InstallDate) = :currentYear)) AND AccountId != :customLabelValue]){
				AccountIds.add(objAsset.AccountId);
			}

			query = 'select id, Current_Year_Spend__c From Account Where Id IN:AccountIds';
		} else{
			for (Asset objAsset : [Select id, AccountId
			                       from Asset
			                       where LastModifiedDate = Today AND AccountId != :customLabelValue]){
				AccountIds.add(objAsset.AccountId);
			}
			query = 'select id, Current_Year_Spend__c from Account Where Id IN :AccountIds';
		}
		//Modified Query by Pratik D for updating Accounts only whose Purchase History is modified
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<Account> AcountRecord){
		system.debug('AcountRecord-->' + AcountRecord);
		set<id> AccountIds = new set<Id>();
		map<Id, Account> mapAccount = new map<Id, Account>();
		for (Account objAccount : AcountRecord){
			objAccount.Current_Year_Spend__c = 0;
			AccountIds.add(objAccount.id);
			mapAccount.put(objAccount.Id, objAccount);
		}
		Integer currentYear = system.today().year();

		List<Asset> lstAsset = [SELECT id, AccountId, Price
		                        FROM Asset
		                        WHERE Status != 'Invoice Cancelled' AND Status != 'Associate Cancelled' AND ((PurchaseDate != null AND CALENDAR_YEAR(PurchaseDate) = :currentYear) OR (InstallDate != null AND CALENDAR_YEAR(InstallDate) = :currentYear)) AND AccountId IN :AccountIds];
		for (Asset objAsset : lstAsset){
			Account objAccount = mapAccount.get(objAsset.AccountId);
			if (objAccount != null){
				system.debug('objAccount.Current_Year_Spend__c-->' + objAccount.Current_Year_Spend__c);
				objAsset.price = objAsset.price == null ? 0:objAsset.price;
				objAccount.Current_Year_Spend__c = objAccount.Current_Year_Spend__c == 0 ? objAsset.price : (objAccount.Current_Year_Spend__c + objAsset.price);
				system.debug('Current_Year_Spend__c-->' + objAccount.Current_Year_Spend__c);
			}
		}

		if (AcountRecord.size() > 0){
			system.debug('mapAccount.values()-->' + mapAccount.values());
			Database.SaveResult[] saveResultList = Database.update(mapAccount.values());
			for (Database.SaveResult dsr : saveResultList){
				if (!dsr.isSuccess()){
					system.debug(Logginglevel.ERROR, 'NOT SUCCESS!!' + dsr.getId());
				}
			}
		}
	}

	global void finish(Database.BatchableContext bc){
		//Scheduling a Batch for next Year
	}
}