# Filter and map customer data

The program filters inactive customer records and maps active customers into contact records using a Ballerina query expression. Input and expected output are included as JSON fixtures; the matching values are embedded in `working_with_data.bal` for a zero-setup run.

Requires Ballerina 2201.14.0; `ballerina/io` ships with the distribution. No credentials or external service is needed. Run `bal build` and `bal run`. Compare the printed one-contact array with `expected-output.json`. The `C-102` customer is excluded because `active` is false.
