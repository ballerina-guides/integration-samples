import ballerina/http;
import ballerina/log;
import ballerina/regex;
import ballerina/time;
import ballerinax/quickbooks.online as quickbooks;
import ballerinax/ronin;

// Clientary configuration parameters
configurable http:CredentialsConfig clientaryAuthConfig = ?;
configurable string clientaryServiceUrl = ?;

// Quickbooks configuration parameters
configurable http:BearerTokenConfig quickbooksAuthConfig = ?;
configurable string quickbooksServiceUrl = ?;
configurable string quickbooksRealmId = ?;

final ronin:Client clientary = check new ({auth: clientaryAuthConfig}, clientaryServiceUrl);
final quickbooks:Client quickbooks = check new ({auth: quickbooksAuthConfig}, quickbooksServiceUrl);

type LineItems record {|
    string 'Description;
    decimal Amount;
    string DetailType;
    SalesItemLineDetail SalesItemLineDetail;
|};

type SalesItemLineDetail record {|
    int Qty;
    string UnitPrice;
|};

type QuickbooksCustomer record {|
    string Id;
    string DisplayName;
    json...;
|};

public function main() returns error? {
    string yesterdayMidnight = regex:split(time:utcToString(time:utcNow()), "T")[0].concat("T00:00:00Z");
    ronin:Invoices response = check clientary->listInvoices(updatedSince = yesterdayMidnight);

    // Obtain Clientary invoices
    ronin:Invoice[] invoices = response?.invoices ?: [];
    if invoices.length() == 0 {
        log:printError("Clientary invoices are empty!");
        return;
    }

    // Obtain the Quickbooks customer array list
    QuickbooksCustomer[] customerArray = check getQuickbooksCustomerArray();

    // Iterate through the Clientary invoices and create Quickbooks invoices
    foreach ronin:Invoice invoice in invoices {
        // Obtain the Clientary customer ID related to the invoice
        int? client_id = invoice?.client_id;
        if client_id is () {
            log:printInfo(string `Client ID is empty for Clientary invoice ID ${invoice?.id ?: "Nil"}!`);
            continue;
        }

        // Obtain the Clientary invoice items
        ronin:InvoiceItem[] invoice_items = invoice?.invoice_items ?: [];
        if invoice_items.length() == 0 {
            log:printError(string `Invoice items are empty for Clientary invoice ID ${invoice?.id ?: "Nil"}!`);
            continue;
        }

        // Create the Quickbooks invoice
        quickbooks:InvoiceCreateObject invoiceCreateObject = check clientaryInvoiceToQuickBooksInvoice(invoice, customerArray);
        _ = check quickbooks->createOrUpdateInvoice(quickbooksRealmId, invoiceCreateObject);
        log:printInfo(string `Quickbooks invoice created successfully for Clientary invoice ID ${invoice?.id ?: "Nil"}!`);
    }
}

isolated function clientaryInvoiceToQuickBooksInvoice(ronin:Invoice invoice, QuickbooksCustomer[] customerArray) returns quickbooks:InvoiceCreateObject|error =>
{
    CustomerRef: {
        value: check getQBCustomerIdForClientaryClientId(invoice.id, invoice.client_id, customerArray)
    },
    Line: from var invoiceItem in invoice.invoice_items ?: []
        let int quantity = invoiceItem.quantity ?: 0
        let decimal quantityInDecimal = check decimal:fromString(quantity.toString())
        let string|float price = invoiceItem.price ?: "0.0"
        let decimal priceInDecimal = check decimal:fromString(price.toString())
        select {
            DetailType: "SalesItemLineDetail",
            Amount: priceInDecimal * quantityInDecimal,
            Description: invoiceItem.title ?: "",
            SalesItemLineDetail: {
                Qty: invoiceItem.quantity ?: 0,
                UnitPrice: invoiceItem.price ?: ""
            }
        }
};

isolated function getQuickbooksCustomerArray() returns QuickbooksCustomer[]|error {
    string query = "select * from Customer";
    json queryResponse = check quickbooks->queryEntity(quickbooksRealmId, query);

    map<json> queryResponseMap = check queryResponse.cloneWithType();
    json queryResponseObject = queryResponseMap.hasKey("QueryResponse") ? queryResponseMap.get("QueryResponse") : ();
    if queryResponseObject is () {
        return error("QueryResponse object is unavailable in Quickbooks query response!");
    }

    map<json> queryResponseObjectMap = check queryResponseObject.cloneWithType();
    json customers = queryResponseObjectMap.hasKey("Customer") ? queryResponseObjectMap.get("Customer") : ();
    if customers is () {
        return error("Customer object is unavailable in Quickbooks query response!");
    }

    QuickbooksCustomer[] customerArray = check customers.cloneWithType();
    if customerArray.length() == 0 {
        return error("Quickbooks customer array is empty!");
    }
    return customerArray;
}

isolated function getQuickbooksCustomerId(QuickbooksCustomer[] customerArray, string customerName) returns string|error {
    string? customerId = ();
    foreach QuickbooksCustomer customer in customerArray {
        if customer.DisplayName == customerName {
            customerId = customer.Id;
            break;
        }
    }
    if customerId is () {
        return error(string `Customer ${customerName} unavailable in Quickbooks`);
    }
    return customerId;
}

isolated function getQBCustomerIdForClientaryClientId(int? clientaryInvoiceId, int? clientaryClientId, QuickbooksCustomer[] customerArray) returns string|error {
    // Obtain the Clientary customer name for the given customer ID
    ronin:ClientObject clientObject = check clientary->getClient(clientaryClientId.toString());
    string customerName = clientObject?.name ?: "";

    // Obtain the Quickbooks customer ID from the Clientary customer name
    string|error customerId = getQuickbooksCustomerId(customerArray, customerName);
    if customerId is error {
        return error(string `${customerId.message()} for Clientary invoice ID ${clientaryInvoiceId ?: "Nil"}!`);
    }
    return customerId;
}

