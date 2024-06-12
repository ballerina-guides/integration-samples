import ballerina/http;
import ballerina/uuid;
import ballerinax/kafka;
import wso2/orders.types;

map<types:Order> ordersStore = {};

service / on new http:Listener(9090) {
    private final kafka:Producer orderProducer;

    function init() returns error? {
        self.orderProducer = check new (kafka:DEFAULT_URL);
    }

    resource function post 'order(@http:Payload types:OrderRequest recievedOrder) returns error? {
        string orderId = uuid:createType1AsString();
        types:Order 'order = {
            ...recievedOrder,
            id: orderId,
            status: types:CREATED
        };
        ordersStore[orderId] = 'order;
        check self.orderProducer->send({
            topic: "order_created_topic",
            value: 'order
        });
    }

    resource function get 'order() returns types:Order[] {
        return ordersStore.toArray();
    }
}

listener kafka:Listener orderListener = new (kafka:DEFAULT_URL, {
    groupId: "order_dispatch_group",
    topics: "inventory_updated_topic"
});

service on orderListener {
    private final kafka:Producer orderProducer;

    function init() returns error? {
        self.orderProducer = check new (kafka:DEFAULT_URL);
    }

    remote function onConsumerRecord(types:Order[] orders) returns error? {

        foreach types:Order 'order in orders {
            string id = 'order.id;
            ordersStore[id].status = types:DISPATCHED;
        }
    }
}
