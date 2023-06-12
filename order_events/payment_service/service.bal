import ballerinax/kafka;
import wso2/orders.types;

listener kafka:Listener orderListener = new (kafka:DEFAULT_URL, {
    groupId: "payment_group",
    topics: "order_created_topic"
});

service on orderListener {
    private final kafka:Producer orderProducer;

    function init() returns error? {
        self.orderProducer = check new (kafka:DEFAULT_URL);
    }

    remote function onConsumerRecord(types:Order[] orders) returns error? {

        foreach types:Order 'order in orders {
            types:PaymentDetails paymentDetails = 'order.paymentDetails;
            if (isPaymentValid(paymentDetails)) {
                processPayment(paymentDetails);
                check self.orderProducer->send({
                    topic: "payment_completed_topic",
                    value: 'order
                });
            } else {
                check self.orderProducer->send({
                    topic: "payment_failed_topic",
                    value: 'order
                });
            }
        }
    }
}


function isPaymentValid(types:PaymentDetails paymentDetails) returns boolean {
    //TODO : Implement payment validation logic
    return true;
}

function processPayment(types:PaymentDetails paymentDetails) {
    //TODO : Implement payment gateway logic
}
