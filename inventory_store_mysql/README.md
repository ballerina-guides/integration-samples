# Inventory Management with Ballerina and MySQL
This guide walks you through the process of building an inventory management system with Ballerina and MySQL.

## Setting up MySQL Database
You can either setup a MySQL database locally, use a database hosted in cloud remotely to try this sample out. We will be using a MySQL docker image for simplicitiy. 

Run the following command to start the database
```
docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -v "./db/init.sql:/docker-entrypoint-initdb.d/init.sql" -d mysql:latest
```

## Setting Configurables
In Ballerina, you can make your code configurable in different environments. These fields are marked as configurables in the code.

```ballerina
configurable string host = ?;
configurable int port = ?;
configurable string user = ?;
configurable string password = ?;
configurable string database = ?;
```

We need to provide the values for these fields in `Config.toml` file. If you are using the docker setup as mentioned above, you don't have to change the values, otherwise you need to change the values accordingly.

```toml
host="localhost"
port=3306
user="root"
password="root"
database="storedb"
```

## Running the Sample
Now we can run the ballerina package using following command.

```bash
bal run
```

## Testing the Sample
You can invoke the following curl command to add an item to the store.

```bash
curl --location 'http://localhost:9090/store' \
--header 'Content-Type: application/json' \
--data '{
    "name" : "Item1",
    "quantity" : 11
}'

```

You can invoke the following curl command to get the list of items in the store.

```bash
curl --location 'http://localhost:9090/store'
```