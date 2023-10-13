import ballerina/url;
import ballerina/io;
import ballerina/time;
import ballerina/http;
import ballerina/mime;
import ballerina/log;
import ballerinax/salesforce as sf;

configurable string servicenowInstance = ?;
configurable string syncData = ?;
configurable string serviceNowUsername = ?;
configurable string serviceNowPassword = ?;
configurable sf:ConnectionConfig salesforceConfig = ?;

public function main() returns error? {
    
    string lastFetchString = check io:fileReadString(syncData);
    time:Civil lastFetch = check time:civilFromString(lastFetchString);
    string fetchFrom = string `'${lastFetch.year}-${lastFetch.month}-${lastFetch.day}','${lastFetch.hour}:${lastFetch.minute}:00'`;
    time:Civil now = time:utcToCivil(time:utcNow());
    string fetchTill = string `'${now.year}-${now.month}-${now.day}','${now.hour}:${now.minute}:00'`;
    string query = string `sys_created_onBETWEENjavascript:gs.dateGenerate(${fetchFrom})@javascript:gs.dateGenerate(${fetchTill})`;

    http:Client servicenow = check new(string `https://${servicenowInstance}.service-now.com/api/sn_customerservice`);
    string serviceNowCredentials = check mime:base64Encode(serviceNowUsername + ":" + serviceNowPassword, "UTF-8").ensureType();
    record {CaseData[] result;}|error caseResponse = servicenow->/case(
        headers = {"Authorization": "Basic " + serviceNowCredentials}, 
        sysparm_query = check url:encode(query, "UTF-8"));
    if caseResponse is error {
        log:printError("Error while fetching cases from ServiceNow: ", caseResponse);
        return;
    }
    CaseData[] cases = caseResponse.result;
    sf:Client salesforce = check new (salesforceConfig);
    foreach CaseData caseData in cases {
        stream<Id, error?> customerQuery = check salesforce->query(
            string `SELECT Id FROM Account WHERE Name = '${caseData.account.name}'`);
        record {|Id value;|}? existingCustomer = check customerQuery.next();
        check customerQuery.close();
        if existingCustomer is () {
            log:printInfo("Customer not found in Salesforce: " + caseData.account.name);
            continue;
        }
        SalesforceCase salesforceCase = {
            Name: caseData.number,
            Created_on__c: caseData.sys_created_on,
            Priority__c: caseData.priority,
            Account__c: existingCustomer.value.Id,
            Summary__c: caseData.case
        };
        sf:CreationResponse|error sfResult = salesforce->create("Support_Case__c", salesforceCase);
        if sfResult is error {
            log:printError("Error while creating case in Salesforce: ", sfResult);
            return;
        }
    }
    check io:fileWriteString(syncData, check time:civilToString(now));
    log:printInfo("Updated salesforce with cases from servicenow." +
        " Cases added: " + cases.length().toString() + 
        " Update Timestamp: " + check time:civilToString(now));
}
