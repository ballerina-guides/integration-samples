# Daily GitHub PR summary as an email in Gmail

This sample sends a summary of open PRs every day as an email.

## Use case

This `schedule-based integration` will send a daily email with a summary of GitHub PRs of the configured GitHub repo.

## Prerequisites

* GitHub account
* Gmail account

### Setting up Google account tokens

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**.
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use
   [OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the
   access token and refresh token).
5. Click **Create**. Your client ID and client secret appear.
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google Calendar scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token.

### Setting up GitHub PAT

1. Follow the instructions in [Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to generate a PAT

## Configuration

Create a file called `Config.toml` at the root of the project.

### Config.toml

```
gmailRefreshToken= "<REFRESH_TOKEN>"
gmailClientId= "<CLIENT_ID>"
gmailClientSecret= "<CLIENT_SECRET>"
gmailRecipient= "<RECIPIENT>"

githubPAT = "<GITHIB_PAT>"
githubOrg = "<GITHUB_ORG>"
githubRepo = "<GITHUB_REPO>"
```

## Testing

- Run the program by executing `bal run` from the root. 

## Deployment

- Schedule a daily cron job to execute it daily at the required time.