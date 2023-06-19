import ballerina/persist as _;

type User record {|
    readonly string id;
    string name;
    int age;
    Post[] posts;
|};

type Post record {|
    readonly string id;
    string title;
    string content;
    User author;
|};
