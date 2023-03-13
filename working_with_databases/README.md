## Working with Databases

This elaborates on how to create an HTTP RESTful API using Ballerina that can be used to perform basic CRUD operations on a database.

### Prerequisites

- Run the following bal file to set up the `MUSIC_STORE` database used in the sample.
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

- Add `Config.toml` file with the required configurations to connect to the database.
    ```toml
    [working_with_databases]
    host="localhost"
    port=3306
    user=""
    password=""
    database="MUSIC_STORE"
    ```