type ShopifyOrder record {
    string confirmation_number;
    string currency;
    Customer customer;
    LineItem[] line_items;
};

type LineItem record {
    string price;
    int quantity;
    int product_id;
};

type Customer record {
    int id;
    DefaultAddress default_address;
};

type DefaultAddress record {
    string company;
    string country;
};

type SAPPurchaseOrder record {
    string PurchaseOrderType;
    string Supplier;
    string PurchasingOrganization;
    string PurchasingGroup;
    string CompanyCode;
    OrderItem[] _PurchaseOrderItem;
};

type OrderItem record {
    string Plant;
    int OrderQuantity;
    string PurchaseOrderQuantityUnit;
    string AccountAssignmentCategory;
    string Material;
    float NetPriceAmount;
    string DocumentCurrency;
    string TaxJurisdiction;
};

type SAPAuthConfig record {|
    string username;
    string password;
|};
