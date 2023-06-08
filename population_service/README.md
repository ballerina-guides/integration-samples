# Population Service

This sample allows retrieving population numbers for a country by year.

## Use case

Use the [World Bank Indicators API](https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation) to retrieve data for a country and return just the population data by year, either in JSON or XML format.

## Running

Start the service using the `bal run` command (within the [project root](/population_service/)).

```bash
population_service$ bal run
Compiling source
        demo/population_service:0.1.0

Running executable

```

Invoke the service specifying 
1. the country as a path parameter
2. format (`json` or `xml`) as a query parameter - defaults to `json` if unspecified

```bash
$ curl http://localhost:8080/population/country/US
{"country":"US", "population":[{"year":2021, "population":331893745}, ....
```

```bash
$ curl http://localhost:8080/population/country/US?format=xml
            <data>
                <country>US</country>
                <population>
                    <year>2021</year>
                    <population>331893745</population>
                </population><population>
                ...
```

## Testing

Use the `bal test` command to run some basic test cases that are in the [tests](/population_service/tests) folder.