type ShopifyCustomer record {
    string email;
    string first_name?;
    string last_name?;
    Address default_address?;
};

type Address record {
    int id;
    string address1;
    string address2;
    string city;
    string country;
    string zip;
};

type SalesforceCustomer record {|
    string Name;
    string Email__c;
    string Address__c;
|};

type Id record {|
    string Id;
|};
