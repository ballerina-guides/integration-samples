import ballerinax/kafka;
import wso2/orders.types;

listener kafka:Listener orderListener = new (kafka:DEFAULT_URL, {
    groupId: "inventory_group",
    topics: "payment_completed_topic"
});

map<int> inventory = {
    "Item1": 10,
    "Item2": 10,
    "Item3": 10
};

service on orderListener {
    private final kafka:Producer orderProducer;

    function init() returns error? {
        self.orderProducer = check new (kafka:DEFAULT_URL);
    }

    remote function onConsumerRecord(types:Order[] orders) returns error? {

        foreach types:Order 'order in orders {
            types:Item[] items = 'order.items;
            foreach types:Item item in items {
                int newQuantity = inventory.get(item.id) - item.quantity;
                inventory[item.id] = newQuantity;
            }

            check self.orderProducer->send({
                topic: "inventory_updated_topic",
                value: 'order
            });
        }
    }
}

