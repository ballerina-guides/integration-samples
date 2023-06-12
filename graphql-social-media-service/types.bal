import graphql_social_media.db;

import ballerina/graphql;

type SocialMediaService distinct service object {
    *graphql:Service;

    // Query Type
    resource function get users() returns User[]|error;
    resource function get user(string id) returns User|error;
    resource function get posts(string? id) returns Post[]|error;

    // Mutation Type
    remote function createUser(NewUser user) returns User|error;
    remote function deleteUser(graphql:Context context, string id) returns User|error;
    remote function createPost(graphql:Context context, NewPost newPost) returns Post|error;
    remote function deletePost(graphql:Context context, string id) returns Post|error;

    // Subscription Type
    resource function subscribe newPosts() returns stream<Post, error?>|error;
};

# Represents the User type in the GraphQL schema.
isolated service class User {
    private final readonly & db:User userData;

    isolated function init(db:User userData) {
        self.userData = userData.cloneReadOnly();
    }

    # The `id` of the User
    # + return - The `id` of the User
    isolated resource function get id() returns string => self.userData.id;

    # The `name` of the User
    # + return - The `name` of the User
    isolated resource function get name() returns string => self.userData.name;

    # The `age` of the User
    # + return - The `age` of the User
    isolated resource function get age() returns int => self.userData.age;

    # The `posts` posted by the User
    # + return - The `posts` posted by the User
    isolated resource function get posts() returns Post[]|error {
        db:Post[]? posts = check getPosts(self.userData.id);
        if posts is () {
            return [];
        }
        return from db:Post postData in posts
            select new Post(postData);
    }
}

# Represents the Post type in the GraphQL schema.
isolated service class Post {
    private final readonly & db:Post postData;

    isolated function init(db:Post postData) {
        self.postData = postData.cloneReadOnly();
    }

    # The `id` of the Post
    # + return - The `id` of the Post
    isolated resource function get id() returns string => self.postData.id;

    # The `title` of the Post
    # + return - The `title` of the Post
    isolated resource function get title() returns string => self.postData.title;

    # The `content` of the Post
    # + return - The `content` of the Post
    isolated resource function get content() returns string => self.postData.content;

    # The `author` of the Post
    # + return - The `User` posted the Post
    isolated resource function get author() returns User|error {
        db:User user = check getUser(self.postData.authorId);
        return new User(user);
    }
}

# Represents the NewUser type in the GraphQL schema.
public type NewUser readonly & record {
    # The `name` of the User
    string name;
    # The `age` of the User
    int age;
};

# Represents the NewPost type in the GraphQL schema.
public type NewPost readonly & record {|
    # The `title` of the Post
    string title;
    # The `content` of the Post
    string content;
|};
