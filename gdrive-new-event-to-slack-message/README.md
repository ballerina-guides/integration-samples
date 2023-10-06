# Google Drive new file upload Event to Slack message

This sample sends a message to the Slack channel for each new file upload in Google Drive.

## Use case

Whenever a particular event appears in Google Drive, you will receive a notification in Slack by using this `trigger-based` integration. You have the flexibility to select the event type and the recipients of the notification. 

## Prerequisites

* Google account
* Slack account with admin access to the workspace

### Setting up the Google account tokens 

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**.
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use
   [OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the
   access token and refresh token).
5. Click **Create**. Your client ID and client secret appear.
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google Calendar scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token.

### Setting up Slack tokens

1. Visit https://api.slack.com/apps 
2. Click `Create New App` and select the `From scratch` option.
3. Create the app by providing an `App name` and selecting the workspace on where to send the notifications. 
4. In the `Add features and functionality` section, Click `Permissions`.
5. Go to the `Scopes` section and add necessary OAuth scopes in `User Token Scopes` section. (`channels:history`, `channels:read`, `channels:write`, `chat:write`, `emoji:read`, `files:read`, `files:write`, `groups:read`, `reactions:read`, `users:read`, `users:read.email`)
6. Go back to the `Basic Information` section of your Slack App. Then go to the `Install your app section` and install the app to the workspace by clicking the `Install to Workspace` button.
7. Get your User OAuth token from the `OAuth & Permissions` section of your Slack App

### Callback URL

- The callback URL will be http://<IP_OF_SERVER>:8090
- If you are running locally, use ngrok with the command `ngrok http 8090` and use the generated URL.

## Configuration

Create a file called `Config.toml` at the root of the project.

### Config.toml

```
slackToken="<SLACK_TOKEN>"

[driveListenerConfig]
refreshUrl="<REFRESH_URL>"
refreshToken="<REFRESJ_TOKEN>"
clientId="<CLIENT_ID>"
clientSecret="<CLIENT_SECRET>"
callbackURL="<CALLBACK_URL>"
```

## Testing

- Run the program by executing `bal run` from the root. 
- Then, upload a file to Google Drive, and it will send a notification to Slack.