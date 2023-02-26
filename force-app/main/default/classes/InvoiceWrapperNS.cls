public class InvoiceWrapperNS {
    public String id;
    public String recordtype;
    public Columns columns;
    
    public class Columns {
        public boolean custbody_cancelled;
        public Createdfrom createdfrom;
        public Priority custbody_priority;
    }
    
    public class Priority {
        public String name;
    }
    
    public class Createdfrom {
		public String name;	//Sales Order #SO18298
		public String internalid;	//2765504
	}
    

}