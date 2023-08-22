# Send Welcome Emails using MS Outlook to New Shopify Customers

## Use case
Each new customer in Shopify created within the last five minutes period will receive welcome emails 
from a Microsoft Outlook account. The attachment for the email is extracted from a Microsoft OneDrive account.

![Flow diagram](/shopify-new-customers-to-outlook-mail/docs/images/flow.png)

## Prerequisites
* Shopify account
* Microsoft Outlook account
* Microsoft OneDrive account

### Setting up a Shopify account
1. Visit [Shopify](https://www.shopify.com) and create a Shopify account.
2. Obtain tokens by following [this guide](https://help.shopify.com/en/manual/apps/custom-apps)

### Setting up a Microsoft Outlook account
1. Visit [Microsoft Outlook](https://outlook.live.com/owa/) and sign up for a Microsoft Outlook account
2. Obtain tokens by following [this guide](https://docs.microsoft.com/en-us/graph/auth-v2-user#authentication-and-authorization-steps) 

### Setting up a Microsoft OneDrive account
1. Visit [Microsoft OneDrive](https://www.microsoft.com/en-ww/microsoft-365/onedrive/online-cloud-storage) and signup for a Microsoft OneDrive account
2. Obtain tokens by following [this guide](https://docs.microsoft.com/en-us/graph/auth-v2-user#authentication-and-authorization-steps)

## Configuration
Create a file called `Config.toml` at the root of the project.

### Config.toml 
```toml
shopifyServiceUrl = "<SHOPIFY_SERVICE_URL>"
xShopifyAccessToken = "<SHOPIFY_ACCESS_TOKEN>"

outlookAccessToken = "<OUTLOOK_ACCESS_TOKEN>"

oneDriveAccessToken = "<ONE_DRIVE_ACCESS_TOKEN>"
flyerFilePath = "<ONE_DRIVE_FILE_PATH>"
```

### Template Configuration
1. Obtain the `shopifyServiceUrl`. 
2. The `shopifyServiceUrl` is `https://{store_name}.myshopify.com`. Replace the `{store_name}` with the name of the Shopify store.
3. Obtain the relevant OAuth access tokens for `Shopify`, `Microsoft OneDrive` and `Microsoft Outlook` configurations.
4. Once you obtained all configurations, Create the `Config.toml` file in the root directory.
5. Replace the necessary fields in the `Config.toml` file with your data.

## Testing
Run the Ballerina project created by the integration template by executing `bal run` from the root.

All new customers in the Shopify store within the past five minutes will receive a welcome email from the Microsoft Outlook account.
