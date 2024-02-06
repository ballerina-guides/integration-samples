# Salesforce to SAP Integration for Automated Sales Order Creation

This sample integrates [Salesforce](https://www.salesforce.com/) and [SAP S/4HANA](https://www.sap.com/products/erp/s4hana.html) to create SAP sales orders when new opportunities are created in Salesforce. 

## Use Case

Salesforce is a cloud-based CRM platform that allows organizations to manage their sales, marketing, and customer service. SAP S/4HANA is an ERP system that helps organizations manage their business operations.

In many organizations, the process of creating sales orders in SAP often involves manual data entry and potential errors. Furthermore, it is important to create sales orders as soon as an opportunity is created. This integration simplifies the process by automatically generating SAP sales orders when Salesforce opportunities are created. This helps in reducing manual work and ensures data accuracy.

The integration listens for new opportunity creation events in Salesforce. When a new opportunity is created, it triggers the creation of an SAP sales order through the SAP API.

## Prerequisites

Before setting up this integration, you'll need the following:

- Salesforce account
- SAP account with access to create sales orders

## Setup

### Setting up a Salesforce account
1. Visit [Salesforce](https://www.salesforce.com/) and create a Salesforce Account. Your Salesforce account username and password will be needed for initializing the listener.
2. From the Salesforce Lightning UI, create a connected app. For this you should go to Setup > App Manager > New Connected App as mentioned in [this documentation](https://help.salesforce.com/s/articleView?id=sf.cg_task_admin_connected_apps.htm&type=5).
3. Once you have created the app, go to View > Manage Consumer Details (You may have to re-authenticate to enter this page) and click on the `Generate` button to get the `Consumer Id` and the `Consumer Secret`.
4. Obtain a `Refresh Token` and a `Refresh URL` by following the steps mentioned in [this documentation](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_refresh_token_flow.htm&type=5).
5. In SAP S/4HANA cloud portal, open the app `Maintain Communication Users` and create a new user. The user name and the password will be needed for authenticating the SAP client.
6. Configure your project settings and credentials by creating a `Config.toml` file, following the template provided in the [Configuration](#configuration) section.

## Configuration

Create a file called `Config.toml` at the root of the project with the following content:

```toml
[<ORG_NAME>.salesforceListenerConfig]
username="<SALESFORCE_USERNAME>"
password="<SALESFORCE_PASSWORD><SALESFORCE_CONSUMER_SECRET>"

[salesforceClientConfig]
baseUrl="https://<YOUR_INSTANCE>.my.salesforce.com"
clientId="<SALESFORCE_CONSUMER_ID>"
clientSecret="<SALESFORCE_CONSUMER_SECRET>"
refreshToken="<REFRESH_TOKEN>"
refreshUrl="<REFRESH_URL>"

[<ORG_NAME>.sapAuthConfig]
username="<SAP_COMMUNICATION_USERNAME>"
password="<SAP_COMMUNICATION_USER_PASSWORD>"
```

## Testing
Run the Ballerina project created by the integration template by executing `bal run` from the root.
