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

@test:Config
function testDataXml() returns error? {
    xml cp = check cl->/US(params = {"format": "xml"});
    test:assertEquals((cp/<country>).data(), "US");
    xml:Element population = check (cp/<population>)[0].ensureType();
    test:assertEquals((population/<year>).data(), "2021");
    test:assertEquals((population/<population>).data(), "331893745");
}
