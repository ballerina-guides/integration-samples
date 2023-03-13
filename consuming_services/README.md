## Consuming Services

This guide elaborates on how to interact with services using the Ballerina clients. In this example, a client is used to interact with the GitHub API to get the details of the open pull requests in a repository. Then, another client is used to interact with the Google Sheets API to populate the open pull requests in a spreadsheet.  

### Prerequisites

1. Set up the Google Sheets API.

   - Create a [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp) if you do not have one.
   - Open the [Google API Console Credentials](https://console.developers.google.com/apis/credentials) page. Log in to your Google Account.
   - Click on **Select a Project** and click **NEW PROJECT**, to create a project.
   - Enter `SpreadsheetConnector` as the name of the project and click **CREATE**.
   - Click **OAuth consent screen** on the left menu.
   - Provide the application name as `SpreadsheetConnector` in the consent screen.
   - Click **Credentials** on the left menu.
   - Click on **Create Credentials** and select **OAuth client ID**.
   - Enter the following details in the **Create OAuth client ID** screen and click `Create`.
      - Application type: **Web application**
      - Name: `SpreadsheetConnector`
      - Authorized redirect URIs: `https://developers.google.com/oauthplayground`
   - A client ID and a client secret will be generated. Keep them saved.
   - Click **Library** on the left menu.
   - Search for `Google Sheets API` and click **Enable**.

2. Obtain access tokens to access Google Sheets.

   - Navigate to [Google OAuth 2.0 Playground](https://developers.google.com/oauthplayground/) and click **OAuth 2.0 Configuration** in the top right corner.
   - Click **Use your own OAuth credentials** and provide the client ID and client secret you obtained in the previous step. Then click on **Close**.
   - Under step 1, select **Google Sheets API v4** and select all the scopes under it.
   - Click **Authorize APIs** and select your Google account when you are asked and allow the scopes.
   - Under step 2, select **Google Sheets API v4** and click **Exchange authorization code for tokens**.
   - This will generate an access token. Keep it saved.

3. Create a new Google spreadsheet and add a sheet named `pull-requests`.

4. Obtain the spreadsheet ID. You can find the spreadsheet ID in a Google Sheets URL: `https://docs.google.com/spreadsheets/d/spreadsheetId/edit#gid=0`

5. Create a [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). This is optional if you are only interacting with a public repository. And in that case, you have to remove the `Authorization` header before making a request.

6. Populate the `Config.toml` file with the Google Sheets API access token, the spreadsheet ID, and the GitHub personal access token. Additionally, you can change the `repository` and `sheetName` values in the `Config.toml` file to interact with a different repository and a different sheet.
   ```toml
   sheetsAccessToken = "<Google Sheets API access token>"
   spreadSheetId = "<Google spreadsheet ID>"
   githubPAT = "<GitHub personal access token>"

   # Optional
   # repository = "ballerina-platform/ballerina-lang"
   # sheetName = "ballerina-lang-pulls"
   ```


