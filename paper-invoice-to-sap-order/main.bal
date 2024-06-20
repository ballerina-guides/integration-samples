import ballerina/http;
import ballerina/log;

const OCR_REQUEST_PATH = "/invoice_parser";
const OCR_URL = "https://api.edenai.run/v2/ocr";
const SAP_REQUEST_PATH = "/purchaseorder/0001/PurchaseOrder";
const SAP_URL = "https://my401785.s4hana.cloud.sap/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/";
const CONTENT_TYPE = "Content-Type";
const APPLICATION_JSON = "application/json";
const HEADER_KEY_CSRF_TOKEN = "x-csrf-token";
const HEADER_FETCH_VALUE = "fetch";

final map<string> & readonly supplierMap = {"ABC COMPANY": "17300096"};
final map<string> & readonly organizationMap = {"SAM K. SMITH": "1710"};
final map<string> & readonly groupMap = {"SAM K. SMITH": "001"};
final map<string> & readonly plantMap = {"SAM K. SMITH": "1710"};
final map<string> & readonly materialMap = {"Cement": "E001", "Steel Rod": "E002"};

final http:Client ocrHttpClient = check getOCRHttpClient();
final http:Client sapHttpClient = check getSAPHttpClient();

configurable string ocrToken = ?;
configurable SAPAuthConfig sapAuthConfig = ?;
configurable string invoiceUrl = ?;

public function main() {
    PaperInvoice|error invoiceResponse = readPaperInvoice();
    if invoiceResponse is error {
        log:printError("Error while reading paper invoice: " + invoiceResponse.message());
        return;
    }
    log:printInfo("Received order with invoice number: " + invoiceResponse.invoice_number);
    SAPPurchaseOrder|error sapOrder = transformOrderData(invoiceResponse);
    if sapOrder is error {
        log:printError("Error while transforming order: " + sapOrder.message());
        return;
    }
    error? sapResponse = createSAPSalesOrder(sapOrder);
    if sapResponse is error {
        log:printError("Error while creating SAP order: " + sapResponse.message());
    }
}

isolated function getOCRHttpClient() returns http:Client|error {
    http:BearerTokenConfig tokenAuthHandler = {token: ocrToken};
    return new (url = OCR_URL, auth = tokenAuthHandler, cookieConfig = {enabled: true});
}

isolated function getSAPHttpClient() returns http:Client|error {
    http:CredentialsConfig basicAuthHandler = {username: sapAuthConfig.username, password: sapAuthConfig.password};
    return new (url = SAP_URL, auth = basicAuthHandler, cookieConfig = {enabled: true});
}

isolated function readPaperInvoice() returns PaperInvoice|error {
    ExtractedInvoice|http:Error response = ocrHttpClient->post(
        path = OCR_REQUEST_PATH,
        message = {
        show_original_response: "false",
        fallback_providers: "",
        providers: "mindee,google",
        language: "en",
        file_url: invoiceUrl
    },
        headers = {[CONTENT_TYPE] : APPLICATION_JSON},
        targetType = ExtractedInvoice
    );
    if response is http:Error {
        return response;
    }
    return response.eden\-ai.extracted_data[0];
}

isolated function transformOrderData(PaperInvoice paperInvoice) returns SAPPurchaseOrder|error {
    string purchaseOrderType = "NB";
    string supplier = supplierMap.get(paperInvoice.merchant_information.merchant_name);
    string customerName = paperInvoice.customer_information.customer_name;
    string organization = organizationMap.get(customerName);
    string group = groupMap.get(customerName);
    string companyCode = organizationMap.get(customerName);
    string plant = plantMap.get(customerName);
    string currency = paperInvoice.locale.currency;
    string taxJurisdiction = "KY00000000";
    OrderItem[] orderItems = from InvoiceItem lineItem in paperInvoice.item_lines
        select
        {
            Plant: plant,
            OrderQuantity: <int>lineItem.quantity,
            PurchaseOrderQuantityUnit: "kg",
            AccountAssignmentCategory: "U",
            Material: materialMap.get(lineItem.description),
            NetPriceAmount: lineItem.amount,
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
    if response is http:ClientError {
        log:printError("Error: " + response.message());
        return;
    }
    if response.statusCode == http:STATUS_CREATED {
        json responseBody = check response.getJsonPayload();
        string purchaseOrderId = check responseBody.PurchaseOrder;
        log:printInfo("Successfully created an SAP purchase order with id: " + purchaseOrderId);
        return;
    }
    log:printError("Error: " + check response.getTextPayload());
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
