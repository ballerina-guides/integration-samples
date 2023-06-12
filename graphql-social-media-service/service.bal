import graphql_social_media.db;

import ballerina/graphql;
import ballerina/io;
import ballerina/uuid;

const POST_TOPIC = "post-created";

configurable record {int port;} serviceConfigs = ?;

@graphql:ServiceConfig {
    contextInit: contextInit,
    cors: {
        allowOrigins: ["*"]
    },
    graphiql: {
        enabled: true
    }
}
service SocialMediaService "/social-media" on new graphql:Listener(serviceConfigs.port) {

    isolated function init() returns error? {
        io:println(string `💃 Server ready at http://localhost:${serviceConfigs.port}/social-media`);
    }

    # Returns the list of users.
    # + return - List of users
    resource function get users() returns User[]|error {
        stream<db:User, error?> users = getUsers();
        return from db:User user in users
            select new (user);
    }

    # Returns the user with the given ID.
    # + id - ID of the user
    # + return - User with the given ID
    resource function get user(string id) returns User|error {
        db:User userData = check getUser(id);
        return new (userData);
    }

    # Returns the list of posts from a user.
    # + id - ID of the user
    # + return - List of posts
    resource function get posts(string? id) returns Post[]|error {
        db:Post[] posts = check getPosts(id);
        return from db:Post post in posts
            select new (post);
    }

    # Creates a new user.
    # + user - User to be created
    # + return - Created user
    remote function createUser(NewUser user) returns User|error {
        string id = uuid:createType1AsString();
        db:User userData = check createUser({id, name: user.name, age: user.age});
        return new (userData);
    }

    # Deletes a user. Only the user can delete their own account. Will return an authentication/authorization error if the user cannot be authenticated/authorized.
    # + context - GraphQL context
    # + id - ID of the user
    # + return - Deleted user
    remote function deleteUser(graphql:Context context, string id) returns User|error {
        string token = check authenticate(context);
        check authorize(token, id);

        db:User user = check deleteUser(id);
        return new (user);
    }

    # Creates a new post. Can return authentication error if the user is not authenticated.
    # + context - GraphQL context
    # + newPost - Post to be created
    # + return - Created post
    remote function createPost(graphql:Context context, NewPost newPost) returns Post|error {
        string authorId = check authenticate(context);

        string id = uuid:createType1AsString();
        db:Post postData = check createPost({
            id,
            authorId,
            title: newPost.title,
            content: newPost.content
        });

        // Publish the post to Kafka
        check publishPost(postData);

        return new (postData);
    }

    # Deletes a post with the given ID. Can return authentication/authorization errors if the user cannot be authenticated/authorized.
    # + context - GraphQL context
    # + id - ID of the post
    # + return - Deleted post
    remote function deletePost(graphql:Context context, string id) returns Post|error {
        string token = check authenticate(context);
        db:Post post = check getPost(id);
        check authorize(token, post.authorId);

        db:Post postData = check deletePost(id);
        return new (postData);
    }

    # Subscribe to new posts.
    # + return - Stream of new posts
    resource function subscribe newPosts() returns stream<Post, error?>|error {
        string id = uuid:createType1AsString();
        PostStreamGenerator postStreamGenerator = check new (id);
        stream<Post> postStream = new (postStreamGenerator);
        return postStream;
    }
}
