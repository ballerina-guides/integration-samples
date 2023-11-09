import test_edi.hmartOrder;
import ballerina/io;

public function main() returns error? {
    hmartOrder:SimpleOrder salesOrder = {header: {orderId: "ORDER_200", organization: "HMart", date: "17-05-2023"}};
    salesOrder.items.push({item: "A680", quantity: 15});
    salesOrder.items.push({item: "A530", quantity: 2});
    salesOrder.items.push({item: "A500", quantity: 4});

string orderEDI = check hmartOrder:toEdiString(salesOrder);
io:println (orderEDI);
}
