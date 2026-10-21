import ballerina/http;

// Local fixtures for the order and shipment systems used by the agent tools.
// Replace the URLs in main.bal to connect to real enterprise backends.
service /orders on new http:Listener(9091) {
    resource function get [string id]() returns json {
        return {orderId: id, shipmentId: "S-100", item: "Travel mug"};
    }
}

service /shipments on new http:Listener(9092) {
    resource function get [string id]() returns json {
        return {shipmentId: id, status: "In transit", eta: "2026-10-15"};
    }
}
