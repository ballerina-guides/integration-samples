import ballerina/http;

type Product record {|
    string id;
    string name;
    decimal price;
|};

type Stock record {|
    string productId;
    int available;
|};

// Local product and stock services make the integration runnable without accounts.
service /products on new http:Listener(9091) {
    resource function get [string id]() returns Product {
        return {id, name: "Travel mug", price: 18.50d};
    }
}

service /stock on new http:Listener(9092) {
    resource function get [string id]() returns Stock {
        return {productId: id, available: 12};
    }
}

service /catalog on new http:Listener(8080) {
    resource function get [string id]() returns json|error {
        http:Client products = check new ("http://localhost:9091");
        http:Client stock = check new ("http://localhost:9092");
        Product product = check products->/products/[id];
        Stock availability = check stock->/stock/[id];
        return {
            id: product.id,
            name: product.name,
            price: product.price,
            available: availability.available
        };
    }
}
