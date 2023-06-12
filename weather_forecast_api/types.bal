
type WeatherResponse record {
    ForecastList forecast;
};

type ForecastList record {
    Forecast[] forecastday;
};

type Forecast record {
    string date;
    DayConditions day;
};

type DayConditions record {
    Condition condition;
    float mintemp_c;
    float maxtemp_c;
    int daily_chance_of_rain;
};


type Condition record {
    string text;
};
