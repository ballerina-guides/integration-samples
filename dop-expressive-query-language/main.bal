import ballerina/io;
import ballerina/http;

type Country record {|
    string country;
    string continent;
    int population;
    int cases;
    int deaths;
|};

http:Client covidClient = check new ("http://localhost:9090");

public function main() returns error? {
    // Perform data transformation using Ballerina's query language
    json summary = from var {country, continent, population, cases, deaths} in <Country[]>check covidClient->/countries
        where population >= 100000 && deaths >= 100
        let decimal caseFatalityRatio = (<decimal>deaths / <decimal>cases * 100).round(4)
        group by continent
        limit 3
        select {continent, countries: [country], population: sum(population), caseFatalityRatio: avg(caseFatalityRatio)};

    io:println(summary);
}