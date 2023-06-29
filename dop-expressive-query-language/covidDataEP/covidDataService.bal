import ballerina/http;

listener http:Listener covidEP = new(9090);

type Country record {|
    string country;
    string continent;
    int population;
    int cases;
    int deaths;
|};


Country[] countries = [
    {country: "United States", continent: "North America", population: 331002651, cases: 1000000, deaths: 50000},
    {country: "China", continent: "Asia", population: 1439323776, cases: 900000, deaths: 10000},
    {country: "India", continent: "Asia", population: 1380004385, cases: 800000, deaths: 20000},
    {country: "Brazil", continent: "South America", population: 212559417, cases: 700000, deaths: 30000},
    {country: "Russia", continent: "Europe", population: 145934462, cases: 600000, deaths: 40000}
    // Add more countries here...
];

service / on covidEP {
   resource function get countries() returns Country[] => countries;
}