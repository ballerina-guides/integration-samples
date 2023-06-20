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

# Represents a user in the GraphQL schema.
isolated service class User {
    private final readonly & db:User userData;

    isolated function init(db:User userData) {
        self.userData = userData.cloneReadOnly();
    }

    # The user's ID.
    # + return - The `id` of the User
    isolated resource function get id() returns string => self.userData.id;

    # The user's name.
    # + return - The `name` of the User
    isolated resource function get name() returns string => self.userData.name;

    # The user's age.
    # + return - The `age` of the User
    isolated resource function get age() returns int => self.userData.age;

    # Posts made by the user.
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

# Represents a post in the GraphQL schema.
isolated service class Post {
    private final readonly & db:Post postData;

    isolated function init(db:Post postData) {
        self.postData = postData.cloneReadOnly();
    }

    # The post's ID.
    # + return - The `id` of the Post
    isolated resource function get id() returns string => self.postData.id;

    # The post's title.
    # + return - The `title` of the Post
    isolated resource function get title() returns string => self.postData.title;

    # The post's content.
    # + return - The `content` of the Post
    isolated resource function get content() returns string => self.postData.content;

    # The post's author.
    # + return - The `User` posted the Post
    isolated resource function get author() returns User|error {
        db:User user = check getUser(self.postData.authorId);
        return new User(user);
    }
}

# Represents the input for creating a new user in the GraphQL schema.
public type NewUser readonly & record {
    # The user's name.
    string name;
    # The user's age.
    int age;
};

# Represents the input for creating a new post in the GraphQL schema.
public type NewPost readonly & record {|
    # The post's title.
    string title;
    # The post's content.
    string content;
|};
