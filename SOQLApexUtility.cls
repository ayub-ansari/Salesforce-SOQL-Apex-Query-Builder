/**
DESCRIPTION: CONTAINS GENERIC METHODS USED IN SEVERAL PLACES IN THIS ORGANIZATION.
TEST CLASS: 
**/
public class SOQLApexUtility{

    public static List<Sobject> queryAnyObjectDynamically(QueryBuilder QUERYBUILDEROBJECT){   
        if(QUERYBUILDEROBJECT.objectAPIName != null){     
            Schema.DescribeSObjectResult objectInfo = Schema.getGlobalDescribe().get(QUERYBUILDEROBJECT.objectAPIName).getDescribe();
            if(objectInfo.isQueryable()){
                String query = 'SELECT Id ';
                query = makeQueryDynamically(QUERYBUILDEROBJECT, false, OBJECTINFO);    
                system.debug(query +'query___');  
                return Database.query(query);                
            } 
        }   
        return new List<SObject>();
    }
    
    public static String makeQueryDynamically(QueryBuilder QUERYBUILDEROBJECT, Boolean COUNTQUERY, Schema.DescribeSObjectResult OBJECTINFO){
        String query;
        if(countQuery == false){
            query = 'SELECT Id ';        
            Map<String, Schema.SObjectField> fieldsMap  = objectInfo.fields.getMap();
            if(QUERYBUILDEROBJECT.FIELDSNAME != null){
                for(String field : QUERYBUILDEROBJECT.FIELDSNAME.split(';')){ 
                    field = field.trim();  
                    if(field.contains('.') || field.contains('(') ){
                        query +=','+field;
                    }else{
                        if(fieldsMap.get(field).getDescribe().isAccessible()) {                
                            query +=','+field;
                        }
                    }
                }
            }
        }else{
            query = 'SELECT '+QUERYBUILDEROBJECT.FIELDSNAME;
        }
        query += ' FROM '+QUERYBUILDEROBJECT.OBJECTAPINAME;           
        
        //ADD FILTERS.. 
        if(QUERYBUILDEROBJECT.whereClause != null && QUERYBUILDEROBJECT.whereClause != ''){
            query += ' WHERE '+QUERYBUILDEROBJECT.whereClause;            
        }  
        
        //ADD ORDER BY
        if(QUERYBUILDEROBJECT.ORDERBY != null && QUERYBUILDEROBJECT.ORDERBY.trim()!=''){
            query += ' ORDER BY '+QUERYBUILDEROBJECT.ORDERBY;
        }       
        
        //ADD LIMIT OF ROWS..
        if(QUERYBUILDEROBJECT.maxRecordInQuery!= null){
            if(QUERYBUILDEROBJECT.maxRecordInQuery != 0){
                query += ' LIMIT '+QUERYBUILDEROBJECT.maxRecordInQuery;
            }else{
                //query += ' LIMIT '+numberOfRecords;
            }     
        } 
        
        //ADD OFFSET..
        if(QUERYBUILDEROBJECT.OFFSET != null){
            query += ' OFFSET '+QUERYBUILDEROBJECT.OFFSET; 
        }
        
        return query;        
    }
    
    public static String prepareSetForDynamicINClauseQuery(List<Id> recordIdsSet){
        if(recordIdsSet != null && !recordIdsSet.isEmpty()){
            return '(\''+String.join(recordIdsSet, '\',\'')+'\')';
        }else{
            return null;
        }
    }  
    
    public static void saveResults (List<Sobject> loacShare){
        Integer i = 0;
        
        Database.SaveResult[] lsr = Database.insert(loacShare, false);
        // Process the save results
        for(Database.SaveResult sr : lsr){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                system.debug('err -------->'+err.getMessage());
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default
                // access level are not allowed.
                // These sharing records are not required and thus an insert exception is
                // acceptable.
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                && err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level.
                    trigger.newMap.get(loacShare[i].Id).
                    addError(
                    'Unable to grant sharing access due to following exception: '
                    + err.getMessage());
                }
            }
            i++;
        }  
    }
    
    //WRAPPER CLASS TO BIND ALL SOQL PARAMTERS AND KEYWORDS...
    public class QueryBuilder{
        public String objectAPIName;
        public String fieldsName; //semi-colon separated
        public Integer maxRecordInQuery;
        public String whereClause;
        public String orderBy;
        public Integer offset;
    }
    
}
