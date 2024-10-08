import ballerina/http;

final http:Client worldBankClient = check new ("http://api.worldbank.org/v2", 
                                               httpVersion = http:HTTP_1_1);

type PopulationByYear record {|
    string date;
    int? value;
    json...;
|};

type Population record {|
    int year;
    int population;
|};

type CountryPopulation record {|
    string country;
    Population[] population;
|};

service /population on new http:Listener(8080) {
    resource function get country/[string country]() returns CountryPopulation|error {

        [json, PopulationByYear[]] [_, populationData] = check worldBankClient->get(
                            string `/country/${country}/indicator/SP.POP.TOTL?format=json`);

        return {
            country,
            population: from PopulationByYear data in populationData
                            let int? population = data.value
                            where population is int
                            select {
                                year: check int:fromString(data.date),
                                population
                            }
        };
    }
}
