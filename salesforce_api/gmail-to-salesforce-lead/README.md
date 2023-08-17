# Example to create leads obtained via email on Salesforce using the OpenAI API.

## Use case
The following sample demonstrates a scenario in which customer leads obtained through email are automatically pushed to Salesforce. The required details for the lead (name, company, designation etc.) are inferred using the content of the email and the OpenAI chat API.

When the user receives an email pertaining to a lead, they will mark that thread with a specific label (e.g. `"Lead"`). This Ballerina program will run continuously in background, polling the email server every 10 minutes for threads marked with this label. If an email is found, it's content will be read and used to infer the following details
* First name
* Last name
* Phone number
* Email address
* Company name
* Designation

Once these detailed have been inferred, a new lead will be generated on Salesforce.

## Prerequisites
* An email account configured to use Gmail
* An account on the Google Cloud Platform
* An OpenAI acccount with API usage enabled
* A Salesforce account

>Note: The following steps will require you to generate keys for the Gmail, OpenAI and Salesforce APIs. These keys will have to be securely stored in the `Config.toml` file in the project directory under the relevant fields. To see a template of this file, please see the [`Config.toml.example`] file (./Config.toml.example).

### Configuring your email account to use Gmail
> Note: If you already have a Gmail account (ending with `@gmail.com`) or your acccount is on the Google workspace, you do not need to follow the steps below. Essentially, if you can access your email via `www.gmail.com`, the following is not necessary.
1. Visit [Gmail](https://gmail.com) and create a new account or log into an existing account.
2. Enter `Accounts` tab under settings and click on `Add a mail account`.
3. Provide the necessary authentication details to your email account.
4. After adding a mail account, you should be able to see all new emails received to your email via the Gmail interface.

### Obtaining the Gmail API keys
1. Create a new [Google Cloud Platfrom project](https://console.cloud.google.com). 
2. Find and click `APIs & Services` --> `Library` from the navigation menu.
3. In the searchbox enter `"Gmail"`.
4. Then select Gmail API and click `Enable` button.
5. Complete OAuth consent screen setup.
6. Click the `Credential` tab from left sidebar. In the displaying window click on the `Create Credentials` button Select OAuth client ID.
7. Fill the required fields. Add `"https://developers.google.com/oauthplayground"` to the Redirect URI field.
8. Get `clientId` and `clientSecret` and enter them on the `Config.toml` file.
9. Visit https://developers.google.com/oauthplayground/. Go to settings (Top right corner) -> Tick 'Use your own OAuth credentials' and insert Oauth ClientId and clientSecret. Click close.
10. Then, Complete Step1 (Select and Authorize API's)
11. Make sure you select the `"https://www.googleapis/auth/gmail.modify"` and `"https://www.googleapis/auth/gmail.labels` Oauth scopes. These two scopes will allow the program to read emails including adding/removing labels.
12. Click `Authorize API's` and You will be in Step 2.
13. Exchange Auth code for tokens.
14. Copy `Refresh token` and enter it on the `Config.toml` file.
15. Obtain the relevant `Refresh URL` (For example: https://www.googleapis.com/oauth2/v3/token) for the Gmail API and include it in the `Config.toml` file.

### Obtaining an OpenAI key
1. Create an [OpenAI account](https://platform.openai.com).
2. If you are eligible for a tree trial of the OpenAI API, use that. Otherwise, set up your [billing information](https://platform.openai.com/account/billing/overview).
3. Obtain your [API key](https://platform.openai.com/account/api-keys) and include it in the `Config.toml` file.

### Setting up the Salesforce account
1. Visit [Salesforce](https://www.salesforce.com/) and create a Salesforce account.
2. Create a connected app and obtain the following credentials:
    *   Base URL (Endpoint)
    *   Client ID
    *   Client Secret
    *   Refresh Token
    *   Refresh Token URL
3. When you are setting up the connected app, select the following scopes under Selected OAuth Scopes:
    *   Access and manage your data (api)
    *   Perform requests on your behalf at any time (refresh_token, offline_access)
    *   Provide access to your data via the Web (web)
4. Provide the client ID and client secret to obtain the refresh token and access token. For more information on obtaining OAuth2 credentials, go to [Salesforce documentation](https://help.salesforce.com/articleView?id=remoteaccess_authenticate_overview.htm).
5. Once you obtained all configurations, include them in the `Config.toml` file.


## Usage

### Using labels
In Gmail, we can use label to mark email under several categories. These labels can be manually added to email threads by the user or can be automatically added based on user-provided rules as well. For this sample, we will use a custom label to mark emails pertaining to a lead generation as `"Lead"`.

1. Log into your gmail account.
2. Create a new label named `"Lead"` from the `Labels` tab under `Settings`
3. Whenever you receive an email pertaining to a lead generation, add the newly created label to it by clicking on the Labels icon above the thread.

### Running the project
Execute the ballerina project by executing `bal run` in the project directory.
