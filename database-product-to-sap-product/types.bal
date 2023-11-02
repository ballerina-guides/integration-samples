type SAPAuthConfig record {|
    string username;
    string password;
|};

type SAPProduct record {
    string Product;
    string ProductType;
    string ProductGroup;
    string BaseUnit;
    string GrossWeight;
    string NetWeight;
    string WeightUnit;
    string IndustrySector;
    record {
        ProductDescription[] results;
    } to_Description;
};

type ProductDescription record {
    string Product;
    string Language;
    string ProductDescription;
};
