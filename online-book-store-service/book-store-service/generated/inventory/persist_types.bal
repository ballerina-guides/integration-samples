// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

public type Book record {|
    readonly string id;
    string name;
    string author;
    string genre;
    float price;
    boolean availability;
|};

public type BookOptionalized record {|
    string id?;
    string name?;
    string author?;
    string genre?;
    float price?;
    boolean availability?;
|};

public type BookTargetType typedesc<BookOptionalized>;

public type BookInsert Book;

public type BookUpdate record {|
    string name?;
    string author?;
    string genre?;
    float price?;
    boolean availability?;
|};

