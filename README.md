# Salesforce-Apex-Query-Builder
Dynamically constructs the SOQL based on salesforce best practices and enforce object level and field level security.

Here is the example:

Let's suppose, you need to make a query like [SELECT Id, Name FROM Account] then you need to follow the below given steps:

1. Create an instance of apex class:
SOQLApexUtility.QueryBuilder queryObject = new SOQLApexUtility.QueryBuilder();
2. Build the query:
queryObject.objectAPIName = 'Account';//API NAME OF OBJECT
queryObject.fieldsName = 'Type;Name;RecordTypeId'; //SEMI-COLON SEPARATED FIELD'S API NAME
queryObject.whereClause = 'Type = \''+'Customer'+'\'';
3. Go for query:
List<Account> accList = (List<Account>)SOQLApexUtility.queryAnyObjectDynamically(queryObject);

# Example using a method:

public static List<Object> returnRecentAccount(Set<String> targetAccountIDs){
    String targetAccountIDs = SOQLApexUtility.prepareSetForDynamicINClauseQuery(new List<String>(accountIds.keySet()));
    SOQLApexUtility.QueryBuilder queryObject = new SOQLApexUtility.QueryBuilder();
    queryObject.objectAPIName = 'Account';//API NAME OF OBJECT
    queryObject.fieldsName = 'Type;Name;RecordTypeId'; //SEMI-COLON SEPARATED FIELD'S API NAME
    queryObject.whereClause = 'Id IN '+targetAccountIDs+' AND Type = \''+'Customer'+'\'';
    List<Account> accList = (List<Account>)SOQLApexUtility.queryAnyObjectDynamically(queryObject);
  }
