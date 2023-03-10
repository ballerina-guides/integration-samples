import ballerina/io;

type InvoiceItem record {
    string id;
    decimal price;
    boolean taxable;
};

type Customer record {
    string id;
    string name;
};

type Invoice record {
    string id;
    Customer customer;
    InvoiceItem[] items;
};

public function main() returns error?{
    json invoiceData = check io:fileReadJson("./invoice.json");

    // Enjoy lax static typing here!
    // Fails at runtime if the key is not present or the value is not a string.
    string id = check invoiceData.id;
    io:println("Invoice id: ", id);

    // Fails at runtime if the key is not present.
    json items = check invoiceData.items;
    io:println("Invoice items: ", items);

    // Converts to the domain type.
    // Fails at runtime if the json value does not match the type.
    Invoice invoice = check invoiceData.fromJsonWithType();

    // Enjoy type-safe handling of json values.
    id = invoice.id;
    InvoiceItem[] invoiceItems = invoice.items;
    io:println("Invoice items: ", invoiceItems);
}
