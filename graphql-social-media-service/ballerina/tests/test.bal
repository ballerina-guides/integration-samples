import ballerina/graphql;
import ballerina/test;
import ballerina/websocket;

string serviceUrl = string `http://localhost:${serviceConfigs.port}/graphql`;
final graphql:Client graphqlClient = check new (serviceUrl);

@test:Config
isolated function testCreateUserMutation() returns error? {
    string document = check getGraphQlDocumentFromFile("create-users-mutation");
    json response = check graphqlClient->execute(document);
    json expectedResponse = check getJsonContentFromFile("create-users-mutation");
    test:assertEquals(response, expectedResponse);
}

@test:Config {
    dependsOn: [testCreateUserMutation]
}
isolated function testUsersQuery() returns error? {
    string document = check getGraphQlDocumentFromFile("users-query");
    UsersResponse response = check graphqlClient->execute(document);
    test:assertTrue(response.data.users.length() >= 3);
    storeUsers(response.data.users);
}

@test:Config {
    dependsOn: [testUsersQuery]
}
isolated function testUserQuery() returns error? {
    string document = check getGraphQlDocumentFromFile("user-query");
    readonly & UserData user = pickLatestUser();
    map<json> variables = {id: user.id};
    json response = check graphqlClient->execute(document, variables);
    json expectedResponse = {data: {user: {name: user.name, age: user.age}}};
    test:assertEquals(response, expectedResponse);
}

@test:Config {
    dependsOn: [testUsersQuery]
}
isolated function testCreatePostMutation() returns error? {
    string document = check getGraphQlDocumentFromFile("create-post-mutation");
    map<json> variables = {title: "Post title", content: "Post content"};
    readonly & UserData user = pickLatestUser();
    map<string> headers = {Authorization: user.id};
    json response = check graphqlClient->execute(document, variables, headers = headers);
    json expectedResponse = {data: {createPost: {author: user.toJson(), title: "Post title", content: "Post content"}}};
    test:assertEquals(response, expectedResponse);
}

@test:Config {
    dependsOn: [testCreatePostMutation]
}
isolated function testPostQuery() returns error? {
    string document = check getGraphQlDocumentFromFile("posts-query");
    readonly & UserData user = pickLatestUser();
    map<json> variables = {id: user.id};
    json response = check graphqlClient->execute(document, variables);
    json expectedResponse = check getJsonContentFromFile("posts-query");
    test:assertEquals(response, expectedResponse);
}

@test:Config {
    dependsOn: [testPostQuery]
}
isolated function testDeletePostMutation() returns error? {
    string document = check getGraphQlDocumentFromFile("posts-query-with-post-id");
    readonly & UserData user = pickLatestUser();
    map<json> variables = {userId: user.id};
    UserPostResponse response = check graphqlClient->execute(document, variables);
    PostData[] userPosts = response.data.posts;
    test:assertTrue(userPosts.length() >= 1);

    PostData firstPost = userPosts[0];
    document = check getGraphQlDocumentFromFile("delete-post-mutation");
    variables = {postId: firstPost.id};
    map<string> headers = {Authorization: user.id};
    json acturalResponse = check graphqlClient->execute(document, variables, headers = headers);
    json expectedResponse = {data: {deletePost: firstPost.toJson()}};
    test:assertEquals(acturalResponse, expectedResponse);
}

@test:Config {
    dependsOn: [testCreatePostMutation]
}
isolated function testPostSubscription() returns error? {
    worker publisher returns error? {
        string document = check getGraphQlDocumentFromFile("create-post-mutation");
        foreach int i in 0 ..< 5 {
            string title = string `Post title ${i}`;
            string content = string `Post content ${i}`;
            map<json> variables = {title, content};
            readonly & UserData user = pickLatestUser();
            map<string> headers = {Authorization: user.id};
            json response = check graphqlClient->execute(document, variables, headers = headers);
            json expectedResponse = {data: {createPost: {author: user.toJson(), title, content}}};
            test:assertEquals(response, expectedResponse);
        }
    }

    string document = check getGraphQlDocumentFromFile("post-subscription");
    string url = string `ws://localhost:${serviceConfigs.port}/graphql`;
    websocket:ClientConfiguration config = {subProtocols: [GRAPHQL_TRANSPORT_WS]};
    websocket:Client wsClient = check new (url, config);
    check initiateGraphqlWsConnection(wsClient);
    check sendSubscriptionMessage(wsClient, document);

    foreach int i in 0 ..< 6 {
        json payload = check readNextMessagePayload(wsClient);
        // There could be posts with different title and content check types of few posts instead
        test:assertTrue(payload.data.newPosts.title is string);
        test:assertTrue(payload.data.newPosts.content is string);
    }
    check sendComplateMessage(wsClient);
}

@test:Config {
    dependsOn: [testCreateUserMutation]
}
isolated function testAuthenticationFailure() returns error? {
    string document = check getGraphQlDocumentFromFile("create-post-mutation");
    map<json> variables = {title: "Post title", content: "Post content"};
    json response = check graphqlClient->execute(document, variables);
    json expectedResponse = check getJsonContentFromFile("authentication-failure-create-post-mutation");
    test:assertEquals(response, expectedResponse);

    document = check getGraphQlDocumentFromFile("delete-user-mutation");
    readonly & UserData user = pickLatestUser();
    response = check graphqlClient->execute(document, {id: user.id});
    expectedResponse = check getJsonContentFromFile("authentication-failure-delete-user-mutation");
    test:assertEquals(response, expectedResponse);

    document = check getGraphQlDocumentFromFile("delete-post-mutation");
    map<string> headers = {Authorization: ""};
    response = check graphqlClient->execute(document, {postId: ""}, headers = headers);
    expectedResponse = check getJsonContentFromFile("authentication-failure-delete-post-mutation");
    test:assertEquals(response, expectedResponse);
}

@test:Config {
    dependsOn: [testCreateUserMutation]
}
isolated function testAuthorizationFailure() returns error? {
    readonly & UserData user = pickLatestUser();
    string document = check getGraphQlDocumentFromFile("delete-user-mutation");
    readonly & UserData differentUser = check pickUserExecpet(user.id);
    map<string> headers = {Authorization: differentUser.id};
    json response = check graphqlClient->execute(document, {id: user.id}, headers = headers);
    json expectedResponse = check getJsonContentFromFile("authorization-failure-delete-user-mutation");
    test:assertEquals(response, expectedResponse);
}

@test:Config {
    dependsOn: [testDeletePostMutation, testPostSubscription, testAuthorizationFailure]
}
isolated function testDeleteUserMutation() returns error? {
    readonly & UserData[] users = getAllUsers();
    string document = check getGraphQlDocumentFromFile("delete-user-mutation");
    foreach UserData user in users {
        map<json> variables = {id: user.id};
        map<string> headers = {Authorization: user.id};
        // The Post table should have `ON DELETE CASCADE` constraint
        json response = check graphqlClient->execute(document, variables, headers = headers);
        json expectedResponse = {data: {deleteUser: user.toJson()}};
        test:assertEquals(response, expectedResponse);
    }
}
