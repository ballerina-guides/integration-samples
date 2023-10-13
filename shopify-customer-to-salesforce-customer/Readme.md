# Shopify new customer to Salesforce customer

This sample listens for notifications from Shopify on customer updates and creates or updates the corresponding customer in Salesforce.

## Use case

It is important to synchronize customer and sales data among ecommerce platforms and Salesforce. In Shopify, a popular ecommerce platform, customers can register by providing their email addresses. Then customers can update their details later at anytime. This sample listens for customer data updates in Shopify and create or update corresponding customer details in Salesforce.

## Prerequisites
* Salesforce account
* Shopify account

### Setting up the Salesforce account
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
5. Fill in details under the `Salesforce configuration` in the `Config.toml` with Salesforce access details.
6. Create a sample Account named `Avino` in Salesforce.
7. Create a new custom object in Salesforce named `Customer`, and following fields to it (A customer object is created as Salesforce built-in objects are created mainly for B2B use cases).
    *   Name - Text(80)
    *   Email - Email type

### Setting up the Shopify account
1. Create a new Shopify partner account from `https://www.shopify.com/partners`
2. Create a Shopify development store (`https://help.shopify.com/en/partners/dashboard/managing-stores/development-stores`)
3. In the development store, navigate to `Settings` -> `Notifications` -> `Webhooks` and create webhooks for `Customer creation` and `Customer update` events. Provide the URL `http://<host>:<port>/salesforce-bridge/customers` for both webhooks.

### Config.toml
```
# ==========================
# Salesforce configuration
# ==========================

[salesforceConfig]
baseUrl = "<salesforce-base-url>"

[salesforceConfig.auth]
clientId = "<salesforce-client-id>"
clientSecret = "<salesforce-client-secret>"
refreshToken = "<salesforce-refresh-token>"
refreshUrl = "<salesforce-refresh-url>"
```

## Testing

1. Navigate to the online store view of the development store and register a new customer by providing an email address. Validate the confirmation email sent to the provided email address.
2. Login to Salesforce and check the Customers records. New customer record with the given email will be created.
3. In the Shopify store, change the customer's first name and last name. Customer name of the corresponding customer will be updated in Salesforce.

