import ballerina/file;
import ballerina/io;

final isolated table<UserData> userTable = table [];

isolated function storeUsers(UserData[] users) {
    foreach UserData user in users {
        lock {
            userTable.add(user.cloneReadOnly());
        }
    }
};

isolated function pickLatestUser() returns readonly & UserData {
    lock {
        return userTable.toArray()[userTable.length() - 1].cloneReadOnly();
    }
};

isolated function pickUserExecpet(string id) returns readonly & UserData|error {
    lock {
        foreach UserData user in userTable {
            if user.id != id {
                return user.cloneReadOnly();
            }
        }
    }
    return error("Unable to pick a user");
};

isolated function getAllUsers() returns readonly & UserData[] {
    lock {
        return userTable.toArray().cloneReadOnly();
    }
}

isolated function getJsonContentFromFile(string fileName) returns json|error {
    string path = check file:joinPath("tests", "resources", "expected-responses", string `${fileName}.json`);
    return io:fileReadJson(path);
}

isolated function getGraphQlDocumentFromFile(string fileName) returns string|error {
    string path = check file:joinPath("tests", "resources", "graphql-documents", string `${fileName}.graphql`);
    return io:fileReadString(path);
}
