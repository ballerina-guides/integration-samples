import ballerina/http;
import ballerina/log;
import ballerinax/salesforce;
import ballerinax/trigger.salesforce as sftrigger;

const CHANNEL_NAME = "/data/OpportunityChangeEvent";
const ENVIRONMENT = "Sandbox";
const SAP_REQUEST_PATH = "/purchaseorder/0001/PurchaseOrder";
const SAP_URL = "https://my401785.s4hana.cloud.sap/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/";
const HEADER_KEY_CSRF_TOKEN = "x-csrf-token";
const HEADER_FETCH_VALUE = "fetch";

final map<string> & readonly materialMap = {"01t6C000003ZkgEQAS": "E001"};

configurable SalesforceListenerConfig salesforceListenerConfig = ?;
configurable SalesforceClientConfig salesforceClientConfig = ?;
configurable SAPAuthConfig sapAuthConfig = ?;

final http:Client sapHttpClient = check getSAPHttpClient();

listener sftrigger:Listener sfdcEventListener = new ({
    username: salesforceListenerConfig.username,
    password: salesforceListenerConfig.password,
    channelName: CHANNEL_NAME,
    environment: ENVIRONMENT
});

final salesforce:ConnectionConfig & readonly sfConfig = {
    baseUrl: salesforceClientConfig.baseUrl,
    auth: {
        clientId: salesforceClientConfig.clientId,
        clientSecret: salesforceClientConfig.clientSecret,
        refreshToken: salesforceClientConfig.refreshToken,
        refreshUrl: salesforceClientConfig.refreshUrl
    }
};

service sftrigger:RecordService on sfdcEventListener {
    isolated remote function onCreate(sftrigger:EventData payload) returns error? {
        string opportunityId = (check payload.toJson().metadata.recordId).toString();
        log:printInfo(string `Recieved an opportunity create event for id: '${opportunityId}`);
        stream<SalesforceOpportunityItem, error?>|error retrievedStream = retrieveOpportunityItems(opportunityId);
        if retrievedStream is error {
            log:printError("Error while retrieving opportunity items: " + retrievedStream.message());
            return;
        }
        SAPPurchaseOrder|error sapOrder = transformOrderData(retrievedStream);
        if sapOrder is error {
            log:printError("Error while transforming order: " + sapOrder.message());
            return;
        }
        error? sapResponse = createSAPSalesOrder(sapOrder);
        if sapResponse is error {
            log:printError("Error while creating SAP order: " + sapResponse.message());
        }
    }

    isolated remote function onUpdate(sftrigger:EventData payload) returns error? {
        string opportunityId = (check payload.toJson().metadata.recordId).toString();
        log:printInfo(string `Recieved an opportunity update event for id: '${opportunityId}`);
        stream<SalesforceOpportunityItem, error?>|error retrievedStream = retrieveOpportunityItems(opportunityId);
        if retrievedStream is error {
            log:printError("Error while retrieving opportunity items: " + retrievedStream.message());
            return;
        }
        SAPPurchaseOrder|error sapOrder = transformOrderData(retrievedStream);
        if sapOrder is error {
            log:printError("Error while transforming order: " + sapOrder.message());
            return;
        }
        error? sapResponse = createSAPSalesOrder(sapOrder);
        if sapResponse is error {
            log:printError("Error while creating SAP order: " + sapResponse.message());
        }
    }

    isolated remote function onDelete(sftrigger:EventData payload) returns error? {
        return;
    }

    isolated remote function onRestore(sftrigger:EventData payload) returns error? {
        return;
    }
}

isolated function getSAPHttpClient() returns http:Client|error {
    http:CredentialsConfig basicAuthHandler = {username: sapAuthConfig.username, password: sapAuthConfig.password};
    return new (url = SAP_URL, auth = basicAuthHandler, cookieConfig = {enabled: true});
}

isolated function retrieveOpportunityItems(string opportunityId) returns stream<SalesforceOpportunityItem, error?>|error {
    salesforce:Client baseClient = check new (sfConfig);
    return baseClient->query(
            string `SELECT Product2Id, Name, Quantity, TotalPrice, CurrencyIsoCode FROM OpportunityLineItem 
            WHERE OpportunityId='${opportunityId}'`);
}

isolated function transformOrderData(stream<SalesforceOpportunityItem, error?> salesforceItems) returns SAPPurchaseOrder|error {
    string purchaseOrderType = "NB";
    string supplier = "17300096";
    string company = "1710";
    string group = "001";
    OrderItem[] orderItems = check from SalesforceOpportunityItem item in salesforceItems
        select
        {
            Plant: company,
            OrderQuantity: <int>item.Quantity,
            PurchaseOrderQuantityUnit: "kg",
            AccountAssignmentCategory: "U",
            Material: materialMap.get(item.Product2Id),
            NetPriceAmount: item.TotalPrice,
            DocumentCurrency: item.CurrencyIsoCode,
            TaxJurisdiction: "KY00000000"
        };
    return {
        PurchaseOrderType: purchaseOrderType,
        Supplier: supplier,
        PurchasingOrganization: company,
        PurchasingGroup: group,
        CompanyCode: company,
        _PurchaseOrderItem: orderItems
    };
}

isolated function createSAPSalesOrder(SAPPurchaseOrder sapPurchaseOrder) returns error? {
    string csrfToken = check getCsrfToken();
    map<string|string[]> headerParams = {[HEADER_KEY_CSRF_TOKEN] : csrfToken};
    http:Response|http:ClientError response = sapHttpClient->post(
        path = SAP_REQUEST_PATH,
        message = sapPurchaseOrder,
        headers = headerParams
        );
    if response is http:ClientError {
        log:printError(string `Error: ${response.message()}`);
        return;
    }
    if response.statusCode == http:STATUS_CREATED {
        json responseBody = check response.getJsonPayload();
        string purchaseOrderId = check responseBody.PurchaseOrder;
        log:printInfo(string `Successfully created an SAP purchase order with id: ${purchaseOrderId}`);
        return;
    }
    log:printError(string `Error:  ${check response.getTextPayload()}`);
}

isolated function getCsrfToken() returns string|error {
    http:Response|http:ClientError response = sapHttpClient->get(
        path = SAP_REQUEST_PATH,
        headers = {[HEADER_KEY_CSRF_TOKEN] : HEADER_FETCH_VALUE}
        );
    if response is http:ClientError {
        return response;
    }
    if response.statusCode == http:STATUS_OK {
        return (check response.getHeaders(HEADER_KEY_CSRF_TOKEN))[0];
    }
    return error(string `Error: ${response.statusCode}`);
}
