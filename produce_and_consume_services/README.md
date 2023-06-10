# Produce and consume services

This sample demonstrates an HTTP service that allows retrieving population numbers for a country by year. The population numbers are retrieved by calling the [World Bank Indicators API](https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation).

## Testing

Use the `bal test` command to run a test case included in the [tests](/produce_and_consume_services/tests) folder.

## Running

Start the service using the `bal run` command (within the [project root](/produce_and_consume_services/)).

```bash
population_service$ bal run
Compiling source
        demo/produce_and_consume_services:0.1.0

Running executable

```

Invoke the service specifying the country as a path parameter.

```bash
$ curl http://localhost:8080/population/country/US
{"country":"US", "population":[{"year":2021, "population":331893745}, ....
```
