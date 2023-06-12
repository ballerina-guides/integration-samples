import ballerina/io;
import ballerina/http;


type Prediction record {
    float minTemp;
    float maxTemp;
    string condition;
    int chanceOfRain;
};

configurable string apiKey = ?;
public function main() returns error? {
    string city = "Colombo";

    http:Client weatherClient = check new ("http://api.weatherapi.com/v1");
    WeatherResponse res = check weatherClient->/forecast\.json(key = apiKey, q = city, days = 2, aqi = "no", alerts = "no");
    
    DayConditions forecast = res.forecast.forecastday[1].day;

    Prediction prediction = transform(forecast);
    io:println(prediction);
}


function transform(DayConditions day) returns Prediction {
    return {
        chanceOfRain: day.daily_chance_of_rain,
        condition: day.condition.text,
        maxTemp: day.maxtemp_c,
        minTemp: day.mintemp_c
    };
}