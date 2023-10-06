# Search for weather data and send Twilio SMS

This sample search weather data for severe weather conditions and sends a Twilio SMS to a specified number.

## Use case

This `search-based integration` will search the weather forecast data for the given location with the specified temperature and wind threshold and sends a Twilio SMS to a specified number.

## Prerequisites

* Openweather account
* Twilio account

### Setting up Openweather tokens

Visit [How to start using professional collections](https://openweathermap.org/appid) and create a token for API usage

### Setting up Twilio tokens

Visit [Twilio help center](https://support.twilio.com/hc/en-us/articles/223136107-How-does-Twilio-s-Free-Trial-work-) and create tokens for usage

## Configuration

Create a file called `Config.toml` at the root of the project.

### Config.toml

```
openweatherToken="<OPENWEATHER_TOKEN>"
lat="<LATITUDE>"
lon="<LONGTUDE>"

twilioAccountSid="<TWILIO_ACCOUNT_SID>"
twilioAuthToken="<TWILIO_AUTH_TOKEN>"
twilioFrom = "<TWILIO_FROM_NUMBER>"
twilioTo = "<TWILIO_TO_NUMBER>"
```

## Testing

- Run the program by executing `bal run` from the root. 


## Deployment

- Schedule a daily cron job to execute it daily at the required time.