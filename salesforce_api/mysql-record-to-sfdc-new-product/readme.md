Example to create a new product in the Salesforce using MySQL and Salesforce integration.

## Use case
MySQL is an open-source relational database management system which can be easily used for data storing and retrieving applications. 

Organizations maintain details about products in various data stores such as ERP systems, databases, etc. These data stores could be updated by different business units. It is important to keep Salesforce up to date about organizations current product line up, so that sales staff can effectively promote and sell valid products.

Following sample demonstrates a scenario of creating products in Salesforce with product details fetched from a MySQL database.

## Prerequisites
* Salesforce account
* MySQL Client

### Setting up Salesforce account
1. Visit [Salesforce](https://www.salesforce.com/) and create a Salesforce Account.
2. Create a connected app and obtain the following credentials:
    *   Base URL (Endpoint)
    *   Access Token
    *   Client ID
    *   Client Secret
    *   Refresh Token
    *   Refresh Token URL
3. When you are setting up the connected app, select the following scopes under Selected OAuth Scopes:
    *   Access and manage your data (api)
    *   Perform requests on your behalf at any time (refresh_token, offline_access)
    *   Provide access to your data via the Web (web)
4. Provide the client ID and client secret to obtain the refresh token and access token. For more information on obtaining OAuth2 credentials, go to [Salesforce documentation](https://help.salesforce.com/articleView?id=remoteaccess_authenticate_overview.htm).
5. Once you obtained all configurations, Replace "" in the `Conf.toml` file with your data.

### Config.toml 
```
[<ORG_NAME>.mysql_record_to_sfdc_new_product]
salesforceBaseUrl = "<SALESFORCE_BASE_URL>"
port = <PORT>
host = "<DATABASE_HOST>'
user = "<USERNAME>'
password = "<PASSWORD>"
database = "<DATABASE_NAME>"

[<ORG_NAME>.mysql_record_to_sfdc_new_product.salesforceOAuthConfig]
clientId = "<SALESFORCE_CLIENT_ID>"
clientSecret = "<SALESFORCE_CLIENT_SECRET>"
refreshToken = "<SALESFORCE_REFRESH_TOKEN>"
refreshUrl = "<SALESFORCE_REFRESH_URL>"
```
> Here   
    * SALESFORCE_REFRESH_URL : https://login.salesforce.com/services/oauth2/token

## Configuration
Create a file called `Config.toml` at the root of the project and include all the required configurations in the config file.


## Testing
1. Make sure the database is running and accessible.

2. Run the sample using `bal Run`

When the ballerina program is executed, it will create a new product in the Salesforce for all the new entries and change the processed column to True so that it won't be processed again.