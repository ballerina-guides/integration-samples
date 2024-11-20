# Extract Paper Invoice Data and Create SAP Order

This sample extracts data from a physical invoice using Optical character recognition (OCR) with [Eden AI](edenai.co) APIs and creates an order in [SAP S/4HANA](https://www.sap.com/products/erp/s4hana.html), an ERP system. 

## Use Case

It is common to have physical documents and digital ERP systems running parallely in an organization. This integration streamlines the process of creating an order in SAP S/4HANA based on the data extracted from a physical invoice. This saves time and effort for the employees and reduces the chances of human error.

## Prerequisites

Before setting up this integration, you'll need an SAP S/4HANA account with permissions to products.

### Setting up an Eden AI account

1. Create an Eden AI account.

2. Generate an API token and save it for later use, as specified in the Configuration section.

### Setting up an SAP Account

1. If you don't have an SAP account, create one and ensure you have the necessary permissions to create products.

2. Obtain your SAP API credentials, including the username and password required for authenticating with the SAP client.

3. Configure your project settings and credentials by creating a `Config.toml` file, following the template provided in the Configuration section.

## Configuration

Create a file called `Config.toml` at the root of the project with the following content:

```toml
[<ORG_NAME>.sapAuthConfig]
username = "<SAP_COMMUNICATION_USERNAME>"
password = "<SAP_COMMUNICATION_USER_PASSWORD>"

[<ORG_NAME>.paper_invoice_to_sap_order]
```

## Testing
1. Run `bal run -- -CinvoiceUrl=<URL_FOR_THE_INVOICE_IMAGE` to start the integration. Here we are passing the URL of the invoice image as a command-line argument.
2. Check SAP S/4HANA system for the newly created products.
