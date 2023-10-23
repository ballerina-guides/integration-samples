# Shopify to SAP Integration for Automated SAP Sales Order Creation

This project facilitates integration between [Shopify](https://admin.shopify.com/), a popular e-commerce platform, and [SAP S/4HANA](https://www.sap.com/products/erp/s4hana.html), an ERP system. It automates the process of creating SAP sales orders whenever new orders are placed in your Shopify store.

## Use Case

Shopify is a widely-used e-commerce platform that allows businesses to manage online sales and customer transactions. On the other hand, SAP S/4HANA is an enterprise resource planning system that helps organizations manage their business operations effectively.

In e-commerce, order management is a critical aspect of the business. This integration streamlines the process by automatically generating SAP sales orders when new orders are placed in Shopify.

Shopify notifies when a new order is created through a webhook to an HTTP service endpoint. This integration listens to the webhook and triggers the creation of an SAP sales order through the SAP API. 

## Prerequisites

Before setting up this integration, you'll need the following:

- Shopify store with admin access
- SAP S/4HANA account with permissions to create sales orders

### Setting up a Shopify Store

1. Create a new Shopify partner account from https://www.shopify.com/partners.

2. Create a Shopify development store (https://help.shopify.com/en/partners/dashboard/managing-stores/development-stores)

3. In the development store, navigate to Settings -> Notifications -> Webhooks and create webhooks for Order creation event. Provide the URL http://<host>:<port>/sap_bridge/orders for both webhooks.

### Setting up an SAP Account

1. If you don't have an SAP account, create one and ensure you have the necessary permissions to create sales orders.

2. Obtain your SAP API credentials, including the username and password required for authenticating with the SAP client.

3. Configure your project settings and credentials by creating a `Config.toml` file, following the template provided in the Configuration section.

## Configuration

Create a file called `Config.toml` at the root of the project with the following content:

```toml
[<ORG_NAME>.sapAuthConfig]
username = "<SAP_COMMUNICATION_USERNAME>"
password = "<SAP_COMMUNICATION_USER_PASSWORD>"
```

## Testing
1. Navigate to the online store view of the development store and register a new customer and a product.
2. Create a new order with the registered customer and the product.
3. Check the SAP S/4HANA system for the newly created sales order.
