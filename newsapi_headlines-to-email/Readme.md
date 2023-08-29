# Fetch BBC Top Headlines and Send as Email to Recipient.

## Use case
This sample sends an email with BBC's top headlines to a designated email address.

## Pre-requisites
* News API Account

### Setup News API Configurations
1. Visit [News API](https://newsapi.org/register) and create a News API Account.
2. Create an account in News API and obtain the API Key.

## Configuration
Create a file called `Config.toml` at the root of the project.

### Config.toml 

```
[<ORG_NAME>.newsapi_headlines_to_email]
emailAddress = "<EMAIL_ADDRESS>"

[<ORG_NAME>.newsapi_headlines_to_email.apiKeyConfig]
apiKey = "<NEWSAPI_API_KEY>"
```

## Testing
Run the Ballerina project by executing `bal run` from the root.

Once successfully executed, BBC's top headlines are fetched and sent as an email to the recipient.
  