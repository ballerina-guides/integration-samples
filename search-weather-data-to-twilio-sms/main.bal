import ballerina/http;
import ballerinax/twilio;

configurable string openweatherToken = ?;
configurable string lat = ?;
configurable string lon = ?;

configurable string twilioAccountSid = ?;
configurable string twilioAuthToken = ?;
configurable string twilioFrom = ?;
configurable string twilioTo = ?;

type Main record {
    decimal temp_max;
};

type Wind record {
    decimal speed;
};

type WeatherItem record {
    Main main;
    Wind wind;
    string dt_txt;
};

type City record {
    string name;
    string country;
};

type WeatherResponse record {
    WeatherItem[] list;
    City city;
};

decimal threasholdTemp = 75;
decimal threasholdWind = 10;

public function main() returns error? {
    http:Client openWeather = check new ("https://api.openweathermap.org");
    WeatherResponse weatherResp = check openWeather->/data/\2\.5/forecast.get(lat = lat, lon = lon, units = "imperial", appid = openweatherToken);

    string smsText = string `Weather Alert:${weatherResp.city.name},${weatherResp.city.country}${"\n"}${transform(weatherResp)}`;

    twilio:Client twilio = check new ({
        twilioAuth: {
            accountSId: twilioAccountSid,
            authToken: twilioAuthToken
        }
    });
    _ = check twilio->sendSms(twilioFrom, twilioTo, smsText);
}

function transform(WeatherResponse response) returns string => from var {main, wind, dt_txt} in response.list
    where main.temp_max > threasholdTemp && wind.speed > threasholdWind
    order by main.temp_max descending
    select string `${dt_txt} - T:${main.temp_max}|W:${wind.speed}${"\n"}`;

