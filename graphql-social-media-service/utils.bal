import ballerina/graphql;
import ballerina/http;

isolated function initContext(http:RequestContext requestCntext, http:Request reqest) returns graphql:Context|error {
    graphql:Context context = new;
    string|error authorizationHeader = reqest.getHeader("Authorization");
    string token = authorizationHeader is string ? authorizationHeader : "";
    context.set("token", token);
    return context;
}

isolated function getToken(graphql:Context context) returns string|error {
    return context.get("token").ensureType();
}
