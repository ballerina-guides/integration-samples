# Google Sheets New Row to Salesforce Contact

This example creates new contacts in [Salesforce](https://www.salesforce.com/) using [Google Sheets](google.com/sheets/about/) and Salesforce integration.

## Use case
Google Sheets is a spreadsheet application included as part of the free, web-based Google Docs Editors suite offered by Google.

As most organizations maintain well-organized sales processes, it is important to enter contacts into Salesforce as soon as they are obtained by salespersons. As many of the salespersons are proficient in using spreadsheets, it's more convenient for them to add new contacts to the Google Sheets and do follow-ups.

The following sample demonstrates a scenario in which contact details are added to the Google Sheets, and it will periodically update Salesforce by adding the new contacts.

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
    *   Access and manage your data (API)
    *   Perform requests on your behalf at any time (refresh_token, offline_access)
    *   Provide access to your data via the Web (web)
4. Provide the client ID and client secret to obtain the refresh token and access token. For more information on obtaining OAuth2 credentials, go to [Salesforce documentation](https://help.salesforce.com/articleView?id=remoteaccess_authenticate_overview.htm).
5. Once you have obtained all configurations, add those to the `Config.toml` file.

### Setting up a Google Sheets account
1. Create a Google account and create a connected app by visiting [Google Cloud platform APIs and Services](https://console.cloud.google.com/apis/dashboard). 
2. Click `Library` from the left side menu.
3. In the search bar, enter Google Sheets.
4. Then select Google Sheets API and click the `Enable` button.
5. Complete the OAuth Consent Screen setup.
6. Click the `Credential` tab from the left sidebar. In the displaying window, click the `Create Credentials` button. Select OAuth client ID.
7. Fill in the required fields. Add https://developers.google.com/oauthplayground to the Redirect URI field.
8. Get `clientId` and `clientSecret`. Put it on the config(Config.toml) file.
9. Visit https://developers.google.com/oauthplayground/. Go to settings (Top right corner) -> Tick 'Use your own OAuth credentials' and insert Oauth ClientId and clientSecret. Click close.
10. Then, Complete Step 1 (Select and Authorize APIs)
11. Make sure you select https://www.googleapis.com/auth/drive & https://www.googleapis.com/auth/spreadsheets OAuth scopes.
12. Click `Authorize APIs` and You will be in Step 2.
13. Exchange Auth code for tokens.
14. Copy `Access token`. Put it on the `Config.toml` file.

## Configuration
Create a file called `Config.toml` at the root of the project.

### Config.toml 
```
[<ORG_NAME>.gsheet-new-row-to-sfdc-new-contact]
spreadsheetId = "<SPREADSHEET_ID>"
worksheetName = "<WORKSHEET_NAME>"
duplicateWorksheetName = "<DUPLICATE_WORKSHEET_NAME>"
sheetsAccessToken = "<GOOGLE_SHEETS_ACCESS_TOKEN>"
salesforceBaseUrl = "<SALESFORCE_BASE_URL>"
salesforceAccessToken = "<SALESFORCE_ACCESS_TOKEN>"
```

## Testing
1. Create a spreadsheet and add the sheet names and spreadsheet ids to the config file.
2. The user needs to add a new contact to the Google sheet.
3. Run the ballerina project.
