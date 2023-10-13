import ballerina/http;
import ballerina/log;
import ballerina/regex;
import ballerinax/salesforce as sf;

configurable sf:ConnectionConfig salesforceConfig = ?;
sf:Client salesforce = check new (salesforceConfig);

service /salesforce_bridge on new http:Listener(9090) {

    resource function post customers(@http:Payload ShopifyCustomer customerData) returns error? {
        log:printDebug("Updating customer record in Salesforce from Shopify customer data.\n" + customerData.toJsonString());
        string firstName = customerData.first_name ?: regex:split(customerData.email, "@")[0];
        string lastName = customerData.last_name ?: "";
        string address = "";
        Address? shopifyAddress = customerData.default_address;
        if shopifyAddress !is () {
            address = string `${shopifyAddress.address1}, ${shopifyAddress.address2}, ${shopifyAddress.city}, ${shopifyAddress.country}`;
        }
        SalesforceCustomer sfCustomer = {
            Name: string `${firstName} ${lastName}`,
            Email__c: customerData.email,
            Address__c: address
        };

        stream<Id, error?> customerQuery = check salesforce->query(
            string `SELECT Id FROM HmartCustomer__c WHERE Email__c = '${customerData.email}'`);
        record {|Id value;|}? existingCustomer = check customerQuery.next();
        check customerQuery.close();
        if existingCustomer is () {
            _ = check salesforce->create("HmartCustomer__c", sfCustomer);
        } else {
            check salesforce->update("HmartCustomer__c", existingCustomer.value.Id, sfCustomer);
        }
    }
}
