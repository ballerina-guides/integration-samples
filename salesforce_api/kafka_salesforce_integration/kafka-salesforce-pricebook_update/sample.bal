import ballerinax/kafka;
import ballerinax/salesforce as sfdc;

configurable string salesforceAccessToken = ?;
configurable string salesforceBaseUrl = ?;
public type ProductPrice readonly & record {|
    string name;
    float unitPrice;
|};

public type ProductPriceUpdate readonly & record {|
    float UnitPrice;
|};

listener kafka:Listener orderListener = new (kafka:DEFAULT_URL, {
    groupId: "order-group-id",
    topics: "foobar"
});

const string PRICEBOOKID = "";

final sfdc:Client sfdcClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        token: salesforceAccessToken
    }
});

service on orderListener {
    isolated remote function onConsumerRecord(ProductPrice[] prices) returns error? {
        foreach ProductPrice {name, unitPrice} in prices {
            stream<record{},error?> retrievedStream = check sfdcClient->query(
                string `SELECT Id FROM PricebookEntry 
                    WHERE Pricebook2Id = '${PRICEBOOKID}' AND 
                    Name = '${name}'`);
            record{}[] retrieved = check from record{} entry in retrievedStream select entry;
            anydata pricebookEntryId = retrieved[0]["Id"];
            if pricebookEntryId is string {
                ProductPriceUpdate updatedPrice = {UnitPrice: unitPrice};
                check sfdcClient->update("PricebookEntry", pricebookEntryId, updatedPrice);
            }
        }
    }
}
