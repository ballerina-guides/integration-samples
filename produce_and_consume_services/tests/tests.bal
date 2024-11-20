import ballerina/http;
import ballerina/test;

final http:Client cl = check new ("http://localhost:8080/population/country");

@test:Config
function testDataJson() returns error? {
    CountryPopulation cp = check cl->/US;
    test:assertEquals(cp.country, "US");
    Population[] population = cp.population;
    test:assertEquals(population[0], {year: 2021, population: 331893745});
}
