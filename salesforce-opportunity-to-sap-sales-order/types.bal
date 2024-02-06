type SalesforceListenerConfig record {|
    string username;
    string password;
|};

type SalesforceClientConfig record {|
    string baseUrl;
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl;
|};

type SalesforceOpportunityItem record {
    string Product2Id;
    float Quantity;
    float TotalPrice;
    string CurrencyIsoCode;
};

type SAPAuthConfig record {|
    string username;
    string password;
|};

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
