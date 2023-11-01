type SAPAuthConfig record {|
    string username;
    string password;
|};

type ProductFromDatabase record {|
    string id;
    string description;
    string 'type;
    string baseUnit;
    string group;
    float grossWeight;
    float netWeight;
    string industry;
    string weightUnit;
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
