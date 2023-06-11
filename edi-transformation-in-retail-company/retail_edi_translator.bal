
import ballerina/io;
import retail_edi_translator.'order;
import retail_edi_translator.invoice;

public function main() returns error? {

    // Parse receive EDI text to construct order
    string ediText = check io:fileReadString("modules/order/resources/order-message.edi");
    'order:Order receivedOrderDetails = check 'order:fromEdiString(ediText);
    io:println("Supplier receives the EDI order and constructs the below order");
    io:println(receivedOrderDetails);

    // processs order logic
    invoice:Invoice invoiceDetails = processOrder(receivedOrderDetails);

    // Convert invoice to EDI
    string ediInvoiceText = check invoice:toEdiString(invoiceDetails);
    io:println("\nSupplier sends the below invoice in EDI format to the retailer");
    io:println(ediInvoiceText);

}

function processOrder('order:Order receivedOrderDetails) returns invoice:Invoice {
    // 1. Calculate total amount
    int amount = 0;
    foreach var item in receivedOrderDetails.items {
        if (item.itemType == "SHIRTS") {
            amount = amount + item.quantity * 500;
        } else if (item.itemType == "TROUSERS") {
            amount = amount + item.quantity * 2000;
        } else {
            io:println("Invalid item" + item.itemType);
        }
    }
    io:println("\nTotal amount is " + amount.toString());

    // 2. Construct invoice
    invoice:Invoice invoiceDetails = {};
    invoiceDetails.items = [];
    foreach var item in receivedOrderDetails.items {
        invoice:ItemsType invoiceItem = {code:"ITM", name:item.name, quantity:item.quantity, price:0};
        if (item.itemType == "SHIRTS") {
            invoiceItem.price = 500;
        } else if (item.itemType == "TROUSERS") {
            invoiceItem.price = 2000;
        } else {
            io:println("Invalid item" + item.itemType);
        }
        invoiceDetails.items.push(invoiceItem);
    }
    invoiceDetails.total = {code: "BILL", orderId: "123", date: "06-12-2023", amount: amount};
    return invoiceDetails;
}
