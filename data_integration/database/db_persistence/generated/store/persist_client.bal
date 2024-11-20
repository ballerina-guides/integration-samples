// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/persist;
import ballerina/jballerina.java;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/persist.sql as psql;

const BOOK = "books";

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final mysql:Client dbClient;

    private final map<psql:SQLClient> persistClients;

    private final record {|psql:SQLMetadata...;|} & readonly metadata = {
        [BOOK] : {
            entityName: "Book",
            tableName: "Book",
            fieldMetadata: {
                id: {columnName: "id"},
                title: {columnName: "title"},
                author: {columnName: "author"},
                isbn: {columnName: "isbn"},
                price: {columnName: "price"}
            },
            keyFields: ["id"]
        }
    };

    public isolated function init() returns persist:Error? {
        mysql:Client|error dbClient = new (host = host, user = user, password = password, database = database, port = port, options = connectionOptions);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {[BOOK] : check new (dbClient, self.metadata.get(BOOK))};
    }

    isolated resource function get books(BookTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get books/[int id](BookTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post books(BookInsert[] data) returns int[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(BOOK);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from BookInsert inserted in data
            select inserted.id;
    }

    isolated resource function put books/[int id](BookUpdate value) returns Book|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(BOOK);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/books/[id].get();
    }

    isolated resource function delete books/[int id]() returns Book|persist:Error {
        Book result = check self->/books/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(BOOK);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

