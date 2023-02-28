import ballerina/http;
import ballerinax/azure_cosmosdb as cosmosdb;

configurable string baseUrl = ?;
configurable string containerId = ?;
configurable string databaseId = ?;
configurable string primaryKeyOrResourceToken = ?;

type Employee record {|
    string empId;
    string firstName;
    string? lastName?;
    string email;
    string designation;
|};

final cosmosdb:DataPlaneClient cosmosDB = check new ({
    baseUrl,
    primaryKeyOrResourceToken
});

service / on new http:Listener(8090) {
    isolated resource function get employees/[string empId]() returns Employee|error {
        return cosmosDB->getDocument(databaseId, containerId, empId, empId);
    }

    isolated resource function post employees(@http:Payload Employee employee) returns error? {
        string empId = employee.empId;
        _ = check cosmosDB->createDocument(databaseId, containerId, empId, employee, empId);
    }

    isolated resource function put employees(@http:Payload Employee employee) returns error? {
        string empId = employee.empId;
        _ = check cosmosDB->replaceDocument(databaseId, containerId, empId, employee, empId);
    }

    isolated resource function delete employees/[string empId]() returns error? {
        _ = check cosmosDB->deleteDocument(databaseId, containerId, empId, empId);
    }
}
