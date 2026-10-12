# Filter and map customer data

The program reads `input.json` as a native `json` value, binds it to customer records, and uses a Ballerina query expression to filter inactive customers and map active customers into contact records. It then renders the same contacts as both native `json` and `xml` values.

Requires Ballerina 2201.14.0; `ballerina/io` ships with the distribution. No credentials or external service is needed. Run `bal build` and `bal run` from this directory, where `input.json` is located. Compare the printed `JSON:` value with `expected-output.json` and the `XML:` value with `expected-output.xml`. The `C-102` customer is excluded because `active` is false.
