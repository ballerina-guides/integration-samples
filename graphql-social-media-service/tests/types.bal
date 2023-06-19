type UserData record {
    string id;
    string name;
    int age;
};

type UsersResponse record {|
    record {
        UserData[] users;
    } data;
|};

type PostData record {
    string id;
    string title;
    string content;
};

type UserPostResponse record {|
    record {
        PostData[] posts;
    } data;
|};
