import ballerinax/kafka;
import ballerina/http;

public type ProductPrice readonly & record {
    string Name;
    float UnitPrice;
};

service / on new http:Listener(9090) {
    private final kafka:Producer priceProducer;

    function init() returns error? {
        self.priceProducer = check new (kafka:DEFAULT_URL);
    }

    resource function post orders(@http:Payload anydata productPrice) returns http:Accepted|error {
        check self.priceProducer->send({
            topic: "foobar",
            value: productPrice
        });
        return http:ACCEPTED;
    }
}