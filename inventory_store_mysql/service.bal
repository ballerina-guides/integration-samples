import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;

listener http:Listener helloEP = new(9090);

type Item record {
    int id?;
    string name;
    int quantity;
};

configurable string host = ?;
configurable int port = ?;
configurable string user = ?;
configurable string password = ?;
configurable string database = ?;

service /store on helloEP {
    final mysql:Client databaseClient;

    public function init() returns error? {
        self.databaseClient = check new (host = host, port = port, user = user, password = password, database = database);
    }

    resource function get .() returns Item[]|error {
        stream<Item, sql:Error?> itemStream = self.databaseClient->query(`SELECT * FROM inventory`);
        return from Item item in itemStream
            select item;
    }
    resource function post .(@http:Payload Item item) returns error? {
        _ = check self.databaseClient->execute(`
                    INSERT INTO inventory(name, quantity)
                    VALUES (${item.name}, ${item.quantity});`);
    }
}
