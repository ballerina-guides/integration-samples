import ballerinax/kafka;
import ballerina/io;
import wso2/orders.types;

listener kafka:Listener orderListener = new (kafka:DEFAULT_URL, {
    groupId: "email_group",
    topics: "inventory_updated_topic"
});

service on orderListener {
    private final kafka:Producer orderProducer;

    function init() returns error? {
        self.orderProducer = check new (kafka:DEFAULT_URL);
    }

    remote function onConsumerRecord(types:Order[] orders) returns error? {

        foreach types:Order 'order in orders {
            types:Customer customer = 'order.customer;
            io:println("Sending email to " + customer.email);
        }
    }
}
