# GitHub new issues assignments to Trello card and Twilio SMS

This sample creates a card in the Trello board and sends an SMS for each new issue assigned in GitHub.

## Use case

Manage your issues with the help of SMS and Trello. By using this `multi-step integration`, you can automatically add a card to Trello containing information about the new issue, and it will send an SMS notification as well.

## Prerequisites

* GitHub account
* Twilio account
* Trello account

### Setting up GitHub webhook

*Create a webhook in GitHub, [Creating webhooks](https://docs.github.com/en/webhooks-and-events/webhooks/creating-webhooks)
*Provide the public URL of the started service as the Payload URL (Add a trailing / to the URL if it is not present).
*Provide `application/json` for the content type.
*Select the list of events you need to subscribe to and click on Add webhook.

### Setting up Twilio tokens

Visit [Twilio help center](https://support.twilio.com/hc/en-us/articles/223136107-How-does-Twilio-s-Free-Trial-work-) and create tokens for usage 

### Setting up Trello tokens

1. Create a [Trello](https://trello.com) account
2. Obtain tokens
    - Use [this](https://developer.atlassian.com/cloud/trello/guides/rest-api/api-introduction/#authentication-and-authorization) guide to obtain the API key and generate a token related to your account.

## Configuration

Create a file called `Config.toml` at the root of the project.

### Config.toml

```
githubUser="<GITHUB_USER>"

twilioAccountSid = "<TWILIO_ACCOUNT_SID>"
twilioAuthToken = "<TWILIO_AUTH_TOKEN>"
twilioFrom = "<TWILIO_FROM_NUMBER>"
twilioTo = "<TWILIO_TO_NUMBER>"

trelloApiKey = "<TRELLO_API_KEY>"
trelloApiToken = "<TRELLO_API_TOKEN>"
trelloListId = "<TRELLO_LIST_ID>"
```

## Testing

- Run the program by executing `bal run` from the root.
- Assign an issue to the user. 
