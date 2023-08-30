# Sync Hubspot Contacts with Google Contacts.
This sample creates a new contact on Google Contacts for each contact you have on Hubspot contacts.

## Use case
Manage your contacts across multiple platforms. By using this integration, you can automatically sync your contacts from Hubspot to Google Contacts.

![Flow diagram](/hubspot-contacts-to-google-contacts/docs/images/flow.png)

## Prerequisites
* Google account with access to [Google Contacts](https://contacts.google.com/)
* [Hubspot](https://www.hubspot.com/home-page) account

### Setting up a Google account
1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the 
access token and refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google People API scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token and access token.

### Setting up Hubspot developer account
1. Visit https://developers.hubspot.com and create a developer account.
2. Create a [private app](https://developers.hubspot.com/docs/api/private-apps) and obtain your access token.

## Configuration
Create a file called `Config.toml` at the root of the project.

### Config.toml 
```
gPeopleAccessToken = "<GOOGLE_CONTACTS_ACCESS_TOKEN>"
hubspotAccessToken = "<HUBSPOT_ACCESS_TOKEN>"
```

## Testing
Run the Ballerina project created by the integration template by executing `bal run` from the root. 
