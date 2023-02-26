public class EventWrapper{
    public cls_Events Events{get;set;}
    public class cls_Events {
        public String EventName{get;set;}
        public Date EventStartDate{get;set;}
        public Date EventEndDate{get;set;}
        public list<String> ProductName;

    }
    public cls_Projects Projects{get;set;}
        public class cls_Projects{
        public list<String> ProjectName;
        public list<String>EventName;
        
        }
    
    }