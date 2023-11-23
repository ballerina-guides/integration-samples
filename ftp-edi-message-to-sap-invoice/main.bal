import ballerina/ftp;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerinax/edifact.d03a.finance.mINVOIC;

const SAP_REQUEST_PATH = "/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice";
const SAP_URL = "https://my401785.s4hana.cloud.sap/sap/opu/odata";
const HEADER_KEY_CSRF_TOKEN = "x-csrf-token";
const HEADER_FETCH_VALUE = "fetch";
const HEADER_KEY_ACCEPT = "Accept";
const HEADER_VALUE_ACCEPT = "Application/json";
const POSTING_DATE_QUALIFIER = "137";
const DOCUMENT_DATE_QUALIFIER = "315";
const SELLER_QUALIFIER = "SE";
const BUYER_QUALIFIER = "BY";
const KEY_INVOICING_PARTY = "invoicingParty";
const KEY_COUNTRY = "country";

final http:Client sapHttpClient = check getSAPHttpClient();

configurable ftp:ClientConfiguration ftpConfig = ?;
configurable SAPAuthConfig sapAuthConfig = ?;
configurable string ftpNewInvoicesPath = ?;

public function main() returns error? {
    string[]|error invoiceStrings = getEdiInvoices();
    if invoiceStrings is error {
        log:printError("Error while retrieving EDI invoices: " + invoiceStrings.message());
        return;
    }
    log:printInfo(string `Successfully retrieved EDI invoices from the FTP server`);
    foreach var invoiceString in invoiceStrings {
        mINVOIC:EDI_INVOIC_Invoice_message ediInvoice = check mINVOIC:fromEdiString(invoiceString);
        SAPInvoice|error sapInvoice = transformToSAPInvoice(ediInvoice);
        if sapInvoice is error {
            log:printError("Error while transforming to SAP invoice: " + sapInvoice.message());
            continue;
        }
        error? sapResponse = createSAPInvoice(sapInvoice);
        if sapResponse is error {
            log:printError("Error while creating SAP invoice: " + sapResponse.message());
        }
    }
}

isolated function getSAPHttpClient() returns http:Client|error {
    http:CredentialsConfig basicAuthHandler = {username: sapAuthConfig.username, password: sapAuthConfig.password};
    return new (url = SAP_URL, auth = basicAuthHandler, cookieConfig = {enabled: true});
}

isolated function getEdiInvoices() returns string[]|error {
    ftp:Client fileServer = check new ftp:Client(ftpConfig);
    ftp:FileInfo[] invoiceList = check fileServer->list(ftpNewInvoicesPath);
    return from ftp:FileInfo invoiceFile in invoiceList
        where invoiceFile.name.endsWith(".edi")
        let stream<byte[] & readonly, io:Error?> fileStream = check fileServer->get(invoiceFile.path)
        select check streamToString(fileStream);
}

isolated function transformToSAPInvoice(mINVOIC:EDI_INVOIC_Invoice_message ediInvoice) returns SAPInvoice|error {
    string? invoiceId = ediInvoice.BEGINNING_OF_MESSAGE?.DOCUMENT_MESSAGE_NAME?.Document_name_code;
    string? postingDate = ();
    string? documentDate = ();
    foreach var entry in ediInvoice.DATE_TIME_PERIOD {
        if entry.DATE_TIME_PERIOD.Date_or_time_or_period_function_code_qualifier == POSTING_DATE_QUALIFIER {
            postingDate = entry.DATE_TIME_PERIOD.Date_or_time_or_period_text;
        } else if entry.DATE_TIME_PERIOD.Date_or_time_or_period_function_code_qualifier == DOCUMENT_DATE_QUALIFIER {
            documentDate = entry.DATE_TIME_PERIOD.Date_or_time_or_period_text;
        }
    }
    map<string?>[] sellerDetails = from var entry in ediInvoice.Segment_group_2
        where entry.NAME_AND_ADDRESS?.Party_function_code_qualifier == SELLER_QUALIFIER
        limit 1
        select {
            invoicingParty: entry.NAME_AND_ADDRESS?.PARTY_IDENTIFICATION_DETAILS?.Party_identifier,
            country: entry.NAME_AND_ADDRESS?.Country_name_code
        };
    string? invoicingParty = sellerDetails[0][KEY_INVOICING_PARTY];
    string? country = sellerDetails[0][KEY_COUNTRY];
    (string?)[] buyerDetails = from var entry in ediInvoice.Segment_group_2
        where entry.NAME_AND_ADDRESS?.Party_function_code_qualifier == BUYER_QUALIFIER
        limit 1
        select entry.NAME_AND_ADDRESS?.PARTY_IDENTIFICATION_DETAILS?.Party_identifier;
    string? companyCode = buyerDetails[0];
    string? currency = ediInvoice.Segment_group_7[0].CURRENCIES?.CURRENCY_DETAILS?.Currency_usage_code_qualifier;
    string? invoiceGrossAmount = ediInvoice.Segment_group_5_[0].MONETARY_AMOUNT.MONETARY_AMOUNT.Monetary_amount;
    InvoiceItem[] items = from var entry in ediInvoice.Segment_group_26
        let string? invoiceItem = entry.LINE_ITEM.Line_item_identifier
        let string? quantityUnit = entry.QUANTITY[0]?.QUANTITY_DETAILS?.Measurement_unit_code
        let string? supplierInvoice = entry.Segment_group_3_[0].REFERENCE.REFERENCE.Reference_identifier
        where invoiceItem != () && quantityUnit != () && supplierInvoice != ()
        select {
            "SupplierInvoiceItem": <string>entry.LINE_ITEM.Line_item_identifier,
            "DocumentCurrency": <string>currency,
            "SupplierInvoiceItemAmount": <string>entry.Segment_group_27[0]?.MONETARY_AMOUNT?.MONETARY_AMOUNT?.Monetary_amount,
            "Quantity": entry.QUANTITY[0]?.QUANTITY_DETAILS?.Quantity,
            "QuantityUnit": <string>entry.QUANTITY[0]?.QUANTITY_DETAILS?.Measurement_unit_code,
            "SupplierInvoice": <string>entry.Segment_group_3_[0].REFERENCE.REFERENCE.Reference_identifier,
            "GLAccount": "12010000",
            "DebitCreditCode": "S"
        };
    if invoiceId == () || postingDate == () || documentDate == () || invoicingParty == () || country == ()
    || companyCode == () || currency == () || invoiceGrossAmount == () {
        return error(string `Error: Invalid EDI invoice`);
    }
    SAPInvoice sapInvoice = {
        CompanyCode: <string>companyCode,
        SupplierInvoiceIDByInvcgParty: <string>invoiceId,
        DocumentDate: documentDate,
        PostingDate: postingDate,
        DocumentCurrency: currency,
        InvoiceGrossAmount: invoiceGrossAmount,
        InvoicingParty: invoicingParty,
        SupplyingCountry: country,
        to_SupplierInvoiceItemGLAcct: {results: items}
    };
    return sapInvoice;
}

isolated function createSAPInvoice(SAPInvoice sapInvoice) returns error? {
    string csrfToken = check getCsrfToken();
    map<string|string[]> headerParams = {[HEADER_KEY_CSRF_TOKEN] : csrfToken, [HEADER_KEY_ACCEPT] : HEADER_VALUE_ACCEPT};
    http:Response|http:ClientError response = sapHttpClient->post(
        path = SAP_REQUEST_PATH,
        message = sapInvoice,
        headers = headerParams
        );
    if response is http:ClientError {
        log:printError("Error: " + response.message());
        return;
    }
    if response.statusCode == http:STATUS_CREATED {
        json responseBody = check response.getJsonPayload();
        string invoiceId = check responseBody.d.SupplierInvoice;
        log:printInfo("Successfully created an SAP invoice with id: " + invoiceId);
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

isolated function streamToString(stream<byte[] & readonly, io:Error?> inStream) returns string|error {
    byte[] contents = [];
    check from byte[] & readonly chunk in inStream
        do {
            contents.push(...chunk);
        };
    return string:fromBytes(contents);
}
