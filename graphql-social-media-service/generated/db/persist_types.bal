// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

public type User record {|
    readonly string id;
    string name;
    int age;
|};

public type UserOptionalized record {|
    string id?;
    string name?;
    int age?;
|};

public type UserWithRelations record {|
    *UserOptionalized;
    PostOptionalized[] posts?;
|};

public type UserTargetType typedesc<UserWithRelations>;

public type UserInsert User;

public type UserUpdate record {|
    string name?;
    int age?;
|};

public type Post record {|
    readonly string id;
    string title;
    string content;
    string authorId;
|};

public type PostOptionalized record {|
    string id?;
    string title?;
    string content?;
    string authorId?;
|};

public type PostWithRelations record {|
    *PostOptionalized;
    UserOptionalized author?;
|};

public type PostTargetType typedesc<PostWithRelations>;

public type PostInsert Post;

public type PostUpdate record {|
    string title?;
    string content?;
    string authorId?;
|};

