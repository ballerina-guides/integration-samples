# Sync Google Drive files to Microsoft OneDrive.
This sample syncs all files in a Google Drive folder to a Microsoft OneDrive folder.

## Use case
Keep your files in sync between Google Drive and Microsoft OneDrive. By using this integration, you can automatically sync all files in a Google Drive folder to a Microsoft OneDrive folder.

![Flow diagram](/gdrive-files-to-microsoft-onedrive-files/docs/images/flow.png)

## Prerequisites
* Google account with access to [Google Drive](https://www.google.com/drive/)
* Microsoft account with access to [OneDrive](https://www.microsoft.com/en-us/microsoft-365/onedrive/online-cloud-storage)

### Setting up a Google Drive account
1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the 
access token and refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google Drive scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token and access token.
8. You could get the `gDriveFolderId` from the folder URL.
    - The folder ID will be the URL segment following `/folders/`

### Setting up a Microsoft OneDrive account
1. Before you run the following steps, create an account in [OneDrive](https://onedrive.live.com). Next, sign into [Azure Portal - App Registrations](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade). You can use your personal, work or school account to register.
2. In the App registrations page, click **New registration** and enter a meaningful name in the name field.
3. In the **Supported account types** section, select **Accounts** in any organizational directory under personal Microsoft accounts (e.g., Skype, Xbox, Outlook.com). Click **Register** to create the application.
4. Copy the Application (client) ID (`<CLIENT_ID>`). This is the unique identifier for your app.
5. In the application's list of pages (under the **Manage** tab in the left-hand side menu), select **Authentication**.
    Under **Platform configurations**, click **Add a platform**.
6. Under **Configure platforms**, click **Web** located under **Web applications**.
7. Under the **Redirect URIs text box**, register the https://login.microsoftonline.com/common/oauth2/nativeclient URL.
   Under **Implicit grant**, select **Access tokens**.
   Click **Configure**.
8. Under **Certificates & Secrets**, create a new client secret (`<CLIENT_SECRET>`). This requires providing a description and a period of expiry. Next, click **Add**.
9. Next, you need to obtain an access token and a refresh token to invoke the Microsoft Graph API.
First, in a new browser, enter the below URL by replacing the `<CLIENT_ID>` with the application ID. Here you can use `Files.ReadWrite` or `Files.ReadWrite.All` according to your preference. `Files.ReadWrite` will allow you to access only your files and `Files.ReadWrite.All` will allow you to access all files you can access.
    ```
    https://login.microsoftonline.com/common/oauth2/v2.0/authorize?response_type=code&client_id=<CLIENT_ID>&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&scope=Files.ReadWrite offline_access
    ```
10. This will prompt you to enter the username and password for signing into the Azure Portal App.
11. Once the username and password pair is entered, this will give a URL in the browser address bar as shown below.
    `https://login.microsoftonline.com/common/oauth2/nativeclient?code=xxxxxxxxxxxxxxxxxxxxxxxxxxx`
12. Copy the code parameter (`xxxxxxxxxxxxxxxxxxxxxxxxxxx` in the above example) and in a new terminal, enter the following cURL command by replacing the `<CODE>` with the code received from the above step. The `<CLIENT_ID>` and `<CLIENT_SECRET>` parameters are the same as above.
    ```
    curl -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Host:login.microsoftonline.com" -d "client_id=<CLIENT_ID>&client_secret=<CLIENT_SECRET>&grant_type=authorization_code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&code=<CODE>&scope=Files.ReadWrite offline_access" https://login.microsoftonline.com/common/oauth2/v2.0/token
    ```
    The above cURL command will provide the refresh token.
13. You could provide the `oneDrivePath` from the root. If the folder is a child of the root, the path should be given as `/CHILD_NAME`

**Note:**
If you want to sync new files and the latest updates of existing OneDrive files, you need to give `filesOverridable` as `true` and if you only want to sync new files, you need to give `filesOverridable` as `false`; 

## Configuration
Create a file called `Config.toml` at the root of the project.

### Config.toml 
```
gDriveAccessToken = "<GOOGLE_DRIVE_ACCESS_TOKEN>"
gDriveFolderId = "<GOOGLE_DRIVE_FOLDER_ID>"

oneDriveRefreshToken = "<ONE_DRIVE_ACCESS_TOKEN>"
oneDrivePath = "<ONE_DRIVE_PATH>"

filesOverridable = false
```

## Testing
Run the Ballerina project created by the integration template by executing `bal run` from the root. 
