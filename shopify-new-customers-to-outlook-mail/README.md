# Send Welcome Emails using MS Outlook to New Shopify Customers
This sample sends an email via Microsoft Outlook to every customer created on Shopify within the previous 5 minutes. The email sent also contains an attachment downloaded from Microsoft OneDrive.

## Use case
Send welcome emails to your customers on Shopify using Microsoft Outlook. By using this integration, you can automatically send the initial greeting email to newly created Shopify customers. 

![Flow diagram](/shopify-new-customers-to-outlook-mail/docs/images/flow.png)

## Prerequisites
* [Shopify](https://www.shopify.com/) account
* [Microsoft Outlook](https://outlook.live.com/) account
* [Microsoft OneDrive](https://www.microsoft.com/en-us/microsoft-365/onedrive/online-cloud-storage) account

### Setting up a Shopify account
1. Visit [Shopify](https://www.shopify.com) and create a Shopify account.
2. Obtain tokens by following [this guide](https://help.shopify.com/en/manual/apps/custom-apps)
3. The `shopifyServiceUrl` is `https://{store_name}.myshopify.com`. Replace the `{store_name}` with the name of the Shopify store.


### Setting up a Microsoft Outlook account
1. Visit [Microsoft Outlook](https://outlook.live.com/owa/) and sign up for a Microsoft Outlook account
2. Obtain tokens by following [this guide](https://docs.microsoft.com/en-us/graph/auth-v2-user#authentication-and-authorization-steps) 

### Setting up a Microsoft OneDrive account
1. Visit [Microsoft OneDrive](https://www.microsoft.com/en-ww/microsoft-365/onedrive/online-cloud-storage) and signup for a Microsoft OneDrive account
2. Obtain tokens by following [this guide](https://docs.microsoft.com/en-us/graph/auth-v2-user#authentication-and-authorization-steps)
3. You could provide the `flyerFilePath` from the root. If the file is in the root directory, the path should be given as `/CHILD_NAME.ext`

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

## Testing
Run the Ballerina project created by the integration template by executing `bal run` from the root.
