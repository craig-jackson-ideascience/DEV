/**
 * Created by cloudroutesolutions on 21/01/21.
 */

public with sharing class ChartjsData {
    public List<string> labels {get;set;}
    public List<chartjsDataset> datasets;
    public String message;
    public String reportLink;
    public Decimal totalRevenue;

    public class chartjsDataset{
        public string label;
        public List<String> fillColor;
        public string strokeColor;
        public string pointColor;
        public string pointStrokeColor;
        public string pointHighlightFill;
        public string pointHighlightStroke;
        public List<long> data;
        public List<long> dataDougnutVal;
        public List<Decimal> datainPercent;
        public List<String> dataLabelBar;
        public Boolean showCustomValue;
        public Integer stepSize;
        public Map<String,Double> listOfPercentData;
        public Double sumOfdata;
        public Map<String, Decimal> mapOfXLabelVsStack;
        public List<Decimal> cumulativeArray;
        public Map<String, Integer> mapOfActiveMembers;
    }
}