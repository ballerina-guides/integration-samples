# Azure CosmosDB Data as REST API
This sample exposes Azure CosmosDB data as REST API through CRUD operations (Create, Read, Update and Delete).

## Prerequisites
* [Create a Microsoft Account with Azure Subscription](https://docs.microsoft.com/en-us/learn/modules/create-an-azure-account/)
* [Create an Azure Cosmos DB account](https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-manage-database-account/)
* Create a container and set partition key as `id`.
* Obtain tokens
    1. Go to your Azure Cosmos DB account and click **Keys**.
    2. Copy the URI and PRIMARY KEY in the **Read-write Keys** tab.


## Configuration
Create a file called `Config.toml` at the root of the project.

### Config.toml 
```
baseUrl = "<BASE_URL>"
containerId = "<CONTAINER_ID>"
databaseId = "<DATABASE_ID>"
primaryKeyOrResourceToken = "<TOKEN>"
```

## Run the template
Run the Ballerina project created by the service template by executing `bal run` from the root.

Once successfully executed, listener will run on port 8090. Then you could invoke the service using the following curl commands.

* To insert an employee
```
$ curl -v -X POST http://localhost:8090/employees -d '{"empId": "1", firstName" : "Foo", "email": "a@a.com", "designation": "SE"}'
```
* To get an employee
```
$ curl -v -X GET http://localhost:8090/employees/1
```
* To update an employee detail
```
$ curl -v -X PUT http://localhost:8090/employees -d '{"empId": "1", firstName" : "Foo", "email": "a@a.com", "designation": "SSE"}'
```
* To delete an employee
```
$ curl -v -X DELETE http://localhost:8090/employees/1
```
