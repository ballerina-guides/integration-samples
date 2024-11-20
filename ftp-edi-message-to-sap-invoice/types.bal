type SAPInvoice record {
    string CompanyCode;
    string SupplierInvoiceIDByInvcgParty;
    string DocumentDate;
    string PostingDate;
    string DocumentCurrency;
    string InvoiceGrossAmount;
    string InvoicingParty;
    string SupplyingCountry;
    record {
        InvoiceItem[] results;
    } to_SupplierInvoiceItemGLAcct;
};

type InvoiceItem record {
    string SupplierInvoiceItem;
    string DocumentCurrency;
    string SupplierInvoice;
    string GLAccount;
    string SupplierInvoiceItemAmount;
    string DebitCreditCode;
    string Quantity;
    string QuantityUnit;
};

type SAPAuthConfig record {|
    string username;
    string password;
|};
