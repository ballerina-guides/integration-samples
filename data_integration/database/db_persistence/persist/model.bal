import ballerina/persist as _;

public type Book record {|
    readonly int id;
    string title;
    string author;
    string isbn;
    int price;
|};
