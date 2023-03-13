## GraphQL API

This guide shows how to create a GraphQL API with Ballerina that communicates with a MySQL database.

The GraphQL API implements the following schema:

```graphql
type Query {
    album(id: String!, currency: Currency = USD): Album!
}

type Album {
    id: String!;
    title: String!;
    artist: String!;
    price: Float!;
    currency: Currency!;
}

enum Currency {
    USD,
    LKR,
    EUR,
    GBP
}
```

### Prerequisites

-   Run a MySQL server.
-   Run the following bal file to set up the `MUSIC_STORE` database used in the sample.

    > Note: Update database configurations in Line 6.

    ```ballerina
    import ballerina/sql;
    import ballerinax/mysql;
    import ballerinax/mysql.driver as _;

    public function main() returns sql:Error? {
        mysql:Client mysqlClient = check new (host = "localhost", port = 3306, user = "root",
        password = "Test@123");

        // Creates a database.
        _ = check mysqlClient->execute(`CREATE DATABASE MUSIC_STORE;`);

        // Creates `albums` table in the database.
        _ = check mysqlClient->execute(`CREATE TABLE MUSIC_STORE.albums (
                                                id VARCHAR(100) NOT NULL PRIMARY KEY,
                                                title VARCHAR(100),
                                                artist VARCHAR(100),
                                                price REAL
                                            );`);

        // Adds the records to the `albums` table.
        _ = check mysqlClient->execute(`INSERT INTO MUSIC_STORE.albums
                                            VALUES("A-123", "Lemonade", "Beyonce", 18.98);`);
        _ = check mysqlClient->execute(`INSERT INTO MUSIC_STORE.albums
                                            VALUES("A-321", "Renaissance", "Beyonce", 24.98);`);

        check mysqlClient.close();
    }
    ```

-   Run the following bal file to set up a dummy forex converter API used in the sample.

    ```ballerina
    import ballerina/http;

    service on new http:Listener(8080) {
        resource function get currencyConversion(string baseCurrency, string to) returns record {decimal rate;} {
            if baseCurrency == "USD" {
                match to {
                    "LKR" => {
                        return {rate: 370.00};
                    }
                    "EUR" => {
                        return {rate: 0.9};
                    }
                    "GBP" => {
                        return {rate: 0.8};
                    }
                }
            }
            return {rate: 1.0};
        }
    }
    ```

-   Add the following configurations to provide database connection information.

    ```toml
    user = "root"
    password = "Test@123"
    host = "localhost"
    port = 3306
    database = "MUSIC_STORE"
    apiEndpoint = "http://localhost:8080/"
    ```

-   Run the service by executing the following command.
    ```shell
    bal run
    ```
