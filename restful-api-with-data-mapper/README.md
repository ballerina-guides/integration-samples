## RESTful API with Data Mapper

This guide elaborates on developing a RESTful API with a data mapper. In addition to the data mapper, this sample also uses a Google Sheets connector to interact with the Google Sheets API. The data mapper is used to combine two records and map them to a new record, which is then used to populate a Google spreadsheet.

### Prerequisites

1. Set up the Google Sheets API.

   - Create a [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp) if you do not have one.
   - Open the [Google API Console Credentials](https://console.developers.google.com/apis/credentials) page. Log in to your Google Account.
   - Click on **Select a Project** and click **NEW PROJECT**, to create a project.
   - Enter `DataMapperConnector` as the name of the project and click **CREATE**.
   - Click **OAuth consent screen** on the left menu.
   - Provide the application name as `DataMapperConnector` in the consent screen.
   - Click **Credentials** on the left menu.
   - Click on **Create Credentials** and select **OAuth client ID**.
   - Enter the following details in the **Create OAuth client ID** screen and click `Create`.
      - Application type: **Web application**
      - Name: `DataMapperConnector`
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

3. Create a new Google spreadsheet and add a sheet named `enrollments`.

4. Obtain the spreadsheet ID. You can find the spreadsheet ID in a Google Sheets URL: `https://docs.google.com/spreadsheets/d/spreadsheetId/edit#gid=0`

5. Add a `Config.toml` file with the Google Sheets API access token, and the spreadsheet ID. Additionally, you can change the `sheetName` value in the `Config.toml` file to interact with a different sheet.
   ```toml
   sheetsAccessToken = "<Google Sheets API access token>"
   spreadSheetId = "<Google spreadsheet ID>"

   # Optional
   # sheetName = "student-enrollments"
   ```


