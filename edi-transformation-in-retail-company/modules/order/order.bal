import ballerina/io;
import ballerina/edi;

public type Retailer record {|
   string code?;
   string orderId;
   string organization;
   string date;
|};

public type ItemsType record {|
   string code?;
   string itemType;
   string name;
   int quantity;
|};

public type Order record {|
   Retailer? header?;
   ItemsType[] items = [];
|};

function getOrderSchema() returns json|error {
    return io:fileReadJson("modules/order/resources/order-schema.json");
}

public function fromEdiString(string ediText) returns Order|error {
    edi:EdiSchema ediSchema = check edi:getSchema(check getOrderSchema());
    json dataJson = check edi:fromEdiString(ediText, ediSchema);
    return dataJson.cloneWithType();
}

public function toEdiString(Order data) returns string|error {
    edi:EdiSchema ediSchema = check edi:getSchema(check getOrderSchema());
    return edi:toEdiString(data, ediSchema);    
}