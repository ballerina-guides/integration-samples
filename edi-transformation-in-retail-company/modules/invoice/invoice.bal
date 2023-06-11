import ballerina/io;
import ballerina/edi;

public type Total record {|
   string code?;
   string orderId;
   string date;
   int amount;
|};

public type ItemsType record {|
   string code?;
   string name;
   int quantity;
   int price;
|};

# Description
#
# + items - Field Description  
# + total - Field Description
public type Invoice record {|
   ItemsType[] items = [];
   Total? total?;
|};

function getInvoiceSchema() returns json|error {
    return io:fileReadJson("modules/invoice/resources/invoice-schema.json");
}

public function fromEdiString(string ediText) returns Invoice|error {
    edi:EdiSchema ediSchema = check edi:getSchema(check getInvoiceSchema());
    json dataJson = check edi:fromEdiString(ediText, ediSchema);
    return dataJson.cloneWithType();
}

public function toEdiString(Invoice data) returns string|error {
    edi:EdiSchema ediSchema = check edi:getSchema(check getInvoiceSchema());
    return edi:toEdiString(data, ediSchema);    
}