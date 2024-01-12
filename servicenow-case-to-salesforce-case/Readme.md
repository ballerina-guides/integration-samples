# ServiceNow case to Salesforce case

This sample fetches cases from [ServiceNow](https://www.servicenow.com/) for a given time period and adds those as support cases in [Salesforce](https://www.salesforce.com/) under the corresponding Salesforce account.

## Use case

ServiceNow is a widely used platform for reporting customer issues, which are attended by the support staff of organizations. However, sales staff should also be aware of support issues reported by their customers, especially if there are high-priority issues. Therefore, it is important to have a view of support issues in Salesforce, which is the main platform used by the sales staff.

This sample can be executed periodically to fetch all unsynced support issues from ServiceNow and add high-priority cases to Salesforce under the corresponding Salesforce account. `resources/syncdata` file contains the most recent data synchronization date. Only the issues added after this date will be considered by this sample.

## Prerequisites
* Salesforce account
* ServiceNow account

### Setting up the Salesforce account
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
5. Fill in details under the `Salesforce configuration` in the `Config.toml` with Salesforce access details.
6. Create a sample Account named `Avino` in Salesforce.
7. Create a new custom object in Salesforce named `Support Case`, and the following fields to it.
    *   Support Case ID - Text(80)
    *   Account - Master-Detail(Account)
    *   Created on - Text(100)
    *   Priority - Text(10)
    *   Summary - Long Text Area(10000)

### Setting up the ServiceNow account
1. If a ServiceNow account is available with the Customer Service Management plugin installed, step 2 can be skipped.
2. Create a new account in [ServiceNow Developer site](https://developer.servicenow.com) and obtain a Personal Development Instance (PDI) as mentioned [here](https://developer.servicenow.com/dev.do#!/learn/learning-plans/tokyo/new_to_servicenow/app_store_learnv2_buildmyfirstapp_tokyo_personal_developer_instances)
3. Activate the Customer Service Management plugin and assign the following roles to the user account.
    *   `sn_customerservice_agent`
    *   `sn_customerservice_manager`
    *   `csm_ws_integration`
4. Fill in the details under `ServiceNow configuration` in the `Config.toml` with ServiceNow account details.

### Config.toml
```
syncdata = "resources/syncdata"

# ==========================
# ServiceNow configuration
# ==========================

serviceNowInstance = "<servicenow-instance-id>"
serviceNowUsername = "<servicenow-username>"
serviceNowPassword = "<servicenow-password>"

# ==========================
# Salesforce configuration
# ==========================

[salesforceConfig]
baseUrl = "<salesforce-base-url>"

[salesforceConfig.auth]
clientId = "<salesforce-client-id>"
clientSecret = "<salesforce-client-secret>"
refreshToken = "<salesforce-refresh-token>"
refreshUrl = "<salesforce-refresh-url>"
```

## Testing

1. Create an account in ServiceNow and create a few support cases under that account.
2. Create an account with the same name in Salesforce.
3. Change the date in `resources/syncdata` file to some date before the creation of ServiceNow cases.
4. Run the sample using the `bal run` command.
5. Check the `Support Cases` section in the `Related` tab of the newly created account in Salesforce. Details of all support cases created in ServiceNow will appear under this section. 
