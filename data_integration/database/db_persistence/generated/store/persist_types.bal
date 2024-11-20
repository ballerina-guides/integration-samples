// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

public type Book record {|
    readonly int id;
    string title;
    string author;
    string isbn;
    int price;
|};

public type BookOptionalized record {|
    int id?;
    string title?;
    string author?;
    string isbn?;
    int price?;
|};

public type BookTargetType typedesc<BookOptionalized>;

public type BookInsert Book;

public type BookUpdate record {|
    string title?;
    string author?;
    string isbn?;
    int price?;
|};

