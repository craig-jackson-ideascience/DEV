public class CreateQuotePDFBefore90DaysOfOppCloseDate implements Schedulable, Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    public List<Quote> quoteList = new List<Quote>();
    public CreateQuotePDFBefore90DaysOfOppCloseDate(){
    }

    public CreateQuotePDFBefore90DaysOfOppCloseDate(List<Quote> quoteList){
        this.quoteList = quoteList;
    }

    public List<Quote> start(database.batchablecontext BC){
        String query = 'SELECT Id, Name, OpportunityId, Opportunity_RecordType__c FROM Quote ' + 
                        'WHERE Opportunity.Type = \'Renewal\' AND Opportunity.isClosed = false AND Opportunity.Opportunity_PO_Required__c = true ' + 
                        'AND Opportunity.RecordType.Name = \'Membership\' AND Opportunity.Days_to_Close__c <= 90 AND Id NOT IN (SELECT QuoteId FROM QuoteDocument)';
        return quoteList.isEmpty() ? Database.query(query) : quoteList;
    }

    public void execute(Database.BatchableContext BC, List<Quote> scope){
        Map<Id, Blob> quoteIdVsBlob = new Map<id, Blob>();
        Map<Id,Quote> quoteIdVSQuote = new Map<Id,Quote>(scope);
		
        if (!quoteIdVSQuote.isEmpty()){
            getQuoteAttachment(quoteIdVSQuote.keyset());
        }
    }

    public static void getQuoteAttachment(Set<Id> quoteIds){
        List<QuoteDocument> listQuoteDoc = new List<QuoteDocument>();
        //String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?';
        List<QuoteDocument> lstQuoteDoc = new List<QuoteDocument>();
        if (!quoteIds.isEmpty() && quoteIds.size() > 0){
            for (Id quoteId : quoteIds){
                String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?';
                quoteUrl += 'id=' + quoteId;
                quoteUrl += '&headerHeight=197&footerHeight=10';
                quoteUrl += '&summlid=' + Label.QuoteTemplateId;
                system.debug('quoteUrl' + quoteUrl);

                PageReference pageRef = new PageReference(quoteUrl);
                QuoteDocument quotedoc = new QuoteDocument();

                Blob quoteBlob;
                if (Test.isRunningTest()){
                    quoteBlob = Blob.valueOf('Create Pdf');
                    system.debug('quoteBlob' + quoteBlob);
                } else{
                    //Get the content of Pdf.
                    quoteBlob = pageRef.getContentAsPDF();
                    system.debug('quoteBlob' + quoteBlob);
                }

                //content assign to document
                quotedoc.Document = quoteBlob;

                //assign quote id where pdf should attach
                quotedoc.QuoteId = quoteId;
                listQuoteDoc.add(quotedoc);
            }
        }

        if (!listQuoteDoc.isEmpty()){
            insert listQuoteDoc;
        }
    }

    public void execute(SchedulableContext sc){
        CreateQuotePDFBefore90DaysOfOppCloseDate obj = new CreateQuotePDFBefore90DaysOfOppCloseDate();
        DataBase.executeBatch(obj, 50);
    }

    public void finish(Database.BatchableContext bc){
    }

}