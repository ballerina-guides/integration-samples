import ballerina/http;

final http:Client worldBankClient = check new ("http://api.worldbank.org/v2", 
                                               httpVersion = http:HTTP_1_1);
type Population record {|
    int year;
    int population;
|};

type CountryPopulation record {|
    string country;
    Population[] population;
|};

enum Format {
    JSON = "json",
    XML = "xml"
}

service /population on new http:Listener(8080) {
    resource function get country/[string country](Format format = JSON) 
            returns CountryPopulation|xml|error {

        json[] payload = check worldBankClient->get(
                            string `/country/${country}/indicator/SP.POP.TOTL?format=json`);
        json[] populationData = check payload[1].ensureType();

        [int, int][] populationByYear = from json data in populationData
                                            let string year = check data.date,
                                                int? population = check data.value
                                            where population is int
                                            select [check int:fromString(year), population];

        if format == JSON {
            return {
                country,
                population: from var [year, population] in populationByYear
                                select {
                                    year, 
                                    population
                                }
            };
        }

        return <xml> xml `
            <data>
                <country>${country}</country>
                ${from var [year, population] in populationByYear
                        select xml `<population>
                                        <year>${year}</year>
                                        <population>${population}</population>
                                    </population>`}
            </data>
        `;
    }
}
