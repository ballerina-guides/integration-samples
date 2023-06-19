import graphql_social_media.db;

import ballerina/graphql;

isolated function authenticate(graphql:Context context) returns string|error {
    string token = check getToken(context);
    _ = check authenticateUserToken(token);
    return token;
}

isolated function authenticateUserToken(string token) returns error? {
    // Get the user from the token
    db:User|error user = getUser(token);
    if user is error {
        return error("Not authenticated", user);
    }
}

isolated function authorize(string token, string id) returns error? {
    if token != id {
        return error("Not authorized");
    }
}
