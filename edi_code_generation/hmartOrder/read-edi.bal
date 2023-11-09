import ballerina/io;
import hmartOrder/SimpleOrder;

public function main() returns error? {
    string ediText = check io:fileReadString("resources/edi-sample.edi");
    SimpleOrder newOrder = check SimpleOrder:fromEdiString(ediText);
    io:println(newOrder.header.date);
}
