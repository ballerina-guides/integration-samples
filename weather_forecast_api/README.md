# Weather Forecast with Ballerina
This sample demonstrates how to use Ballerina to talk to an external API and transform the response to a different format to suit the use case. We'll be using the [weatherapi](https://www.weatherapi.com/) to get the weather forecast for a given location.

## Obtaining the API Key
* Weather API Key - You can obtain a free API key from [weatherapi](https://www.weatherapi.com/my/)

## Configuring the API Key
* Create a file named `Config.toml` in the root directory of the project and add the following content.
```toml
apiKey = "xxx"
```

## Running the Sample
Execute the following command to run this sample.
```bash
bal run
```