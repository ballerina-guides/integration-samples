import ballerina/persist as _;

public type Product record {|
    readonly string id;
    string description;
    string 'type;
    string baseUnit;
    string group;
    float grossWeight;
    float netWeight;
    string industry;
    string weightUnit;
|};
