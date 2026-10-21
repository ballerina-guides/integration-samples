import ballerina/http;

// Local stock fixture used by the MCP tool. Replace the URL in main.bal to
// connect to a real inventory system.
service /stock on new http:Listener(9091) {
    resource function get [string id]() returns Stock {
        return {productId: id, available: 12};
    }
}
