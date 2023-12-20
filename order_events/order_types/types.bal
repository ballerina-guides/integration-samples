public type OrderRequest record {|
    Customer customer;
    Item[] items;
    PaymentDetails paymentDetails;
|};

public type Order record {|
    *OrderRequest;
    string id;
    OrderStatus status;
|};

public type Customer record {|
    string name;
    string email;
    string phoneNumber;
|};

public type Item record {|
    string id;
    int quantity;
|};

public enum OrderStatus {
    CREATED,
    PAYMENT_COMPLETED,
    PAYMENT_FAILED,
    DISPATCHED
};

public type PaymentDetails record {|
    string name;
    string cardNumber;
    string expiryDate;
    string cvv;
|};
