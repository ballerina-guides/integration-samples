import ballerina/io;
import edi_code_generation.hmartOrder;

public function read_edi() returns error? {
     string ediText = check io:fileReadString("resources/edi-sample.edi");
     hmartOrder:SimpleOrder myOrder = check hmartOrder:fromEdiString(ediText);
     // SimpleOrder order = check hmartOrder:fromEdiString(ediText);
     io:println(myOrder?.header?.date);
 }