import ballerina/io;

public function main() returns error? {
    string ediText = check io:fileReadString("resources/edi-sample.edi");
    SimpleOrder newOrder = check hmartOrder:fromEdiString(ediText);
    io:println(newOrder.header.date);
}
