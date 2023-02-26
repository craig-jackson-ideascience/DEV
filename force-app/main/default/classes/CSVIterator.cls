public with sharing class CSVIterator implements Iterator<string>, Iterable<string>{
    private String m_CSVData;
    private String m_introValue;
    
    public CSVIterator(String fileData, String introValue)
    {       
        m_CSVData = fileData;
        m_introValue = introValue;
    }
    public Boolean hasNext()
    {
        return m_CSVData.length() > 1 ? true : false;
    }
    public String next()
    {       
        string row;
        if( m_CSVData.indexOf(m_introValue) < 0){
            row = m_CSVData.subString(0, m_CSVData.length() );
            m_CSVData = '';
        }else{
            row = m_CSVData.subString(0, m_CSVData.indexOf(m_introValue));
            m_CSVData = m_CSVData.subString(m_CSVData.indexOf(m_introValue) + m_introValue.length(),m_CSVData.length()); 
        }        
        System.debug('row :' +row);
        System.debug('m_CSVData :' +m_CSVData);
        return row;
    }
    public Iterator<string> Iterator()
    {
        return this;
    }
}