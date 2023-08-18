Example to create new contacts in the Salesforce pricebook using google sheets and Salesforce integration.

## Use case
Google Sheets is a spreadsheet application included as part of the free, web-based Google Docs Editors suite offered by Google.

As most organizations maintain well-organized sales processes, it is important to enter contacts into Salesforce as soon as they are obtained by salespersons. As many of the salespersons are proficient in using spreadsheets, it's much more convenient for salespersons to add new contacts to the google sheets and do follow-ups.

The following sample demonstrates a scenario in which contact details are added to the google sheets and it will periodically update the Salesforce leads by adding the new contacts.

## Prerequisites
* Salesforce account
* Google Cloud Platform account

### Setting up a Salesforce account
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

### Setting up Google Sheets account
1. Create a Google account and create a connected app by visiting [Google Cloud platform APIs and Services](https://console.cloud.google.com/apis/dashboard). 
2. Click `Library` from the left side menu.
3. In the search bar enter Google Sheets.
4. Then select Google Sheets API and click the `Enable` button.
5. Complete OAuth Consent Screen setup.
6. Click `Credential` tab from left sidebar. In the displaying window click `Create Credentials` button. Select OAuth client ID.
7. Fill the required fields. Add https://developers.google.com/oauthplayground to the Redirect URI field.
8. Get `clientId` and `clientSecret`. Put it on the config(Config.toml) file.
9. Visit https://developers.google.com/oauthplayground/. Go to settings (Top right corner) -> Tick 'Use your own OAuth credentials' and insert Oauth ClientId and clientSecret. Click close.
10. Then, Complete Step1 (Select and Authorize API's)
11. Make sure you select https://www.googleapis.com/auth/drive & https://www.googleapis.com/auth/spreadsheets Oauth scopes.
12. Click `Authorize API's` and You will be in Step 2.
13. Exchange Auth code for tokens.
14. Copy `Access token` and `Refresh token`. Put it on the config(`Config.toml`) file.
15. Obtain the relevant `Refresh URL` (For example: https://www.googleapis.com/oauth2/v3/token) for the Google Sheets API and include it in the `Config.toml` file.

## Configuration
Create a file called `Config.toml` at the root of the project.

### Config.toml 
```
[<ORG_NAME>.gsheet-new-row-to-sfdc-new-contact]
spreadsheetId = "<SPREADSHEET_ID>"
worksheetName = "<WORKSHEET_NAME>"
duplicateWorksheetName = "<DUPLICATE_WORKSHEET_NAME>"
salesforceBaseUrl = "<SALESFORCE_BASE_URL>"

[<ORG_NAME>.gsheet-new-row-to-sfdc-new-contact.salesforceOAuthConfig]
clientId = "<SALESFORCE_CLIENT_ID>"
clientSecret = "<SALESFORCE_CLIENT_SECRET>"
refreshToken = "<SALESFORCE_REFRESH_TOKEN>"
refreshUrl = "<SALESFORCE_REFRESH_URL>"

[<ORG_NAME>.gsheet-new-row-to-sfdc-new-contact.salesforceOAuthConfig]
clientId = "<CLIENT_ID>"
clientSecret = "<CLIENT_SECRET>"
refreshToken = "<REFRESH_TOKEN>"
refreshUrl = "<REFRESH_URL>"


```
> Here   
    * SALESFORCE_REFRESH_URL : https://login.salesforce.com/services/oauth2/token


## Testing
1. Create a spreadsheet and add the sheet names and spreadsheet ids to the config file.
2. The user needs to add a new contact to the Google sheet.
3. Run the ballerina project.
