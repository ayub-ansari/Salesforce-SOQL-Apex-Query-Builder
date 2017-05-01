public with sharing class ApexSOQLExample{
  
  public static List<Object> returnRecentAccount(Set<String> targetAccountIDs){
    String targetAccountIDs = SOQLApexUtility.prepareSetForDynamicINClauseQuery(new List<String>(accountIds.keySet()));
    SOQLApexUtility.QueryBuilder queryObject = new SOQLApexUtility.QueryBuilder();
    queryObject.objectAPIName = 'Account';//API NAME OF OBJECT
    queryObject.fieldsName = 'Type;Name;RecordTypedI'; //SEMI-COLON SEPARATED FIELD'S API NAME
    queryObject.whereClause = 'Id IN '+targetAccountIDs+' AND Type = \''+'Customer'+'\'';
    List<Account> accList = (List<Account>)SOQLApexUtility.queryAnyObjectDynamically(queryObject);
  }
}
