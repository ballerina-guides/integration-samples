import graphql_social_media.db;

final db:Client dbClient = check new ();

type UserWithPosts record {|
    *db:User;
    db:Post[] posts;
|};

isolated function getUsers() returns stream<db:User, error?> {
    return dbClient->/users;
}

isolated function getUser(string id) returns db:User|error {
    return dbClient->/users/[id];
}

isolated function createUser(db:User user) returns db:User|error {
    string[] ids = check dbClient->/users.post([user]);
    if ids.length() != 1 {
        return error ("Failed to create user");
    }
    return getUser(ids[0]);
}

isolated function deleteUser(string id) returns db:User|error {
    return dbClient->/users/[id].delete;
}

isolated function getPosts(string? authorId) returns db:Post[]|error {
    if authorId is () {
        stream<db:Post, error?> posts = dbClient->/posts;
        return from db:Post post in posts select post;
    }
    UserWithPosts user = check dbClient->/users/[authorId];
    return user.posts;
}

isolated function getPost(string id) returns db:Post|error {
    return dbClient->/posts/[id];
}

isolated function createPost(db:Post post) returns db:Post|error {
    string[] ids = check dbClient->/posts.post([post]);
    if ids.length() != 1 {
        return error ("Failed to create post");
    }
    string postId = ids[0];
    return dbClient->/posts/[postId];
}

isolated function deletePost(string id) returns db:Post|error {
    return dbClient->/posts/[id].delete;
}
