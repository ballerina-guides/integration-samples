import ballerina/persist as _;

type Book record {|
    readonly string id;
    string name;
    string author;
    string genre;
    float price;
    boolean availability;
|};