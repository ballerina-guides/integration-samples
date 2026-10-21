# Customers into contacts

Read `input.json` as a native `json` value, bind it to typed `Customer` records, and use a query expression to select the active customers and transform their email addresses into an XML contact list.

## Prerequisites

- Ballerina 2201.14.0 (`bal version`). `ballerina/io` and `ballerina/log` ship with the distribution. No credentials or external service is needed.

## Run

From this directory, where `input.json` is located, run:

```sh
bal build
bal run
```

## Verify

Compare the logged `XML:` value with `expected-output.xml`. Customer `C-102` is excluded because `active` is false.
