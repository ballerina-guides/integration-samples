import ballerina/http;
import ballerina/log;

const SAP_REQUEST_PATH = "/purchaseorder/0001/PurchaseOrder";
const SAP_URL = "https://my401785.s4hana.cloud.sap/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/";
const HTTP_STATUS_OK = 200;
const HTTP_STATUS_CREATED = 201;
const HEADER_KEY_CSRF_TOKEN = "x-csrf-token";
const HEADER_FETCH_VALUE = "fetch";

final map<string> & readonly supplierMap = {"7336631533890": "17300096"};
final map<string> & readonly organizationMap = {"US Steel Corp": "1710"};
final map<string> & readonly groupMap = {"US Steel Corp": "001"};
final map<string> & readonly plantMap = {"US Steel Corp": "1710"};
final map<string> & readonly materialMap = {"8882299109698": "E001"};
final map<string> & readonly taxJurisdictionMap = {"United States": "KY00000000"};

final http:Client sapHttpClient = check getSAPHttpClient();

configurable SAPAuthConfig sapAuthConfig = ?;

service /sap\-bridge on new http:Listener(9090) {
    isolated resource function post orders(ShopifyOrder shopifyOrder) {
        log:printInfo("Received order with confirmation number: " + shopifyOrder.confirmation_number);
        SAPPurchaseOrder|error sapOrder = transformCustomerData(shopifyOrder);
        if sapOrder is error {
            log:printError("Error while transforming order: " + sapOrder.message());
            return;
        }
        error? sapResponse = createSAPSalesOrder(sapOrder);
        if sapResponse is error {
            log:printError("Error while creating SAP order: " + sapResponse.message());
        }
    }
}

isolated function getSAPHttpClient() returns http:Client|error {
    http:CredentialsConfig basicAuthHandler = {username: sapAuthConfig.username, password: sapAuthConfig.password};
    return new (url = SAP_URL, auth = basicAuthHandler, cookieConfig = {enabled: true});
}

isolated function transformCustomerData(ShopifyOrder shopifyOrder) returns SAPPurchaseOrder|error {
    string purchaseOrderType = "NB";
    string supplier = supplierMap.get(shopifyOrder.customer.id.toString());
    string company = shopifyOrder.customer.default_address.company;
    string organization = organizationMap.get(company);
    string group = groupMap.get(company);
    string companyCode = organizationMap.get(company);
    string plant = organizationMap.get(company);
    string currency = shopifyOrder.currency;
    string taxJurisdiction = taxJurisdictionMap.get(shopifyOrder.customer.default_address.country);

    OrderItem[] orderItems = from LineItem lineItem in shopifyOrder.line_items
        select
        {
            Plant: plant,
            OrderQuantity: lineItem.quantity,
            PurchaseOrderQuantityUnit: "kg",
            AccountAssignmentCategory: "U",
            Material: materialMap.get(lineItem.product_id.toString()),
            NetPriceAmount: check float:fromString(lineItem.price),
            DocumentCurrency: currency,
            TaxJurisdiction: taxJurisdiction
        };
    return {
        PurchaseOrderType: purchaseOrderType,
        Supplier: supplier,
        PurchasingOrganization: organization,
        PurchasingGroup: group,
        CompanyCode: companyCode,
        _PurchaseOrderItem: orderItems
    };
}

isolated function createSAPSalesOrder(SAPPurchaseOrder sapOrder) returns error? {
    string csrfToken = check getCsrfToken();
    map<string|string[]> headerParams = {[HEADER_KEY_CSRF_TOKEN] : csrfToken};
    http:Response|http:ClientError response = sapHttpClient->post(
        path = SAP_REQUEST_PATH,
        message = sapOrder,
        headers = headerParams
        );
    if response is http:Response {
        if response.statusCode == HTTP_STATUS_CREATED {
            json responseBody = check response.getJsonPayload();
            string purchaseOrderId = check responseBody.PurchaseOrder;
            log:printInfo("Successfully created an SAP purchase order with id: " + purchaseOrderId);
            return;
        }
        log:printError("Error: " + check response.getTextPayload());
        return;
    }
    log:printError("Error: " + response.message());
}

isolated function getCsrfToken() returns string|error {
    http:Response|http:ClientError response = sapHttpClient->get(
        path = SAP_REQUEST_PATH,
        headers = {[HEADER_KEY_CSRF_TOKEN] : HEADER_FETCH_VALUE}
        );
    if response is http:Response {
        if response.statusCode == HTTP_STATUS_OK {
            return (check response.getHeaders(HEADER_KEY_CSRF_TOKEN))[0];
        }
        return error(string `Error: ${response.statusCode}`);
    }
    return response;
}
