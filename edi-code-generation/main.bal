import ballerina/io;

public function main(string[] args) returns error? {

    if args[0] is "read" {
        check read_edi();
    } else if args[0] is "write"  {
        check write_edi();
    }
}

public function read_edi() returns error? {
    string ediText = check io:fileReadString("resources/edi-sample.edi");
    SimpleOrder myOrder = check fromEdiString(ediText);
    io:println("Order date: " + (myOrder?.header?.date ?: ""));
}

public function write_edi() returns error? {
    SimpleOrder salesOrder = {header: {orderId: "ORDER_200", organization: "HMart", date: "17-05-2023"}};
    salesOrder.items.push({item: "A680", quantity: 15});
    salesOrder.items.push({item: "A530", quantity: 2});
    salesOrder.items.push({item: "A500", quantity: 4});

    string orderEDI = check toEdiString(salesOrder);
    io:println("EDI message: \n" + orderEDI);
}
