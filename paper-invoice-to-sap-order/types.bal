type ExtractedInvoice record {
    record {
        PaperInvoice[] extracted_data;
    } eden\-ai;
};

type PaperInvoice record {
    string invoice_number;
    record { string customer_name;} customer_information;
    record { string merchant_name;} merchant_information;
    record { string currency;} locale;
    InvoiceItem[] item_lines;
};

type InvoiceItem record {
    string description;
    float quantity;
    float amount;
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
