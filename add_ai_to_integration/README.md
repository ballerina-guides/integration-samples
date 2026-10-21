# Extract order details with a direct LLM call

Send one order confirmation message to an OpenAI model and bind the response directly to an `OrderDetails` record, with no manual JSON parsing. The model call is live, not a mock. Typed binding checks the shape of the response; it does not guarantee the extracted values are correct.

## Prerequisites

- Ballerina 2201.14.0 (`bal version`). `ballerina/ai` and `ballerinax/ai.openai` versions are locked in `Dependencies.toml`.
- An OpenAI account with API access and a valid key.

## Run

Copy `Config.toml.example` to `Config.toml`, replace the placeholder key, and keep the real file private. Then run:

```sh
bal build
bal run
```

## Verify

The input is `Order O-204 confirmed: 2x Wireless Mouse, total $39.98.` The program logs an `OrderDetails` record such as `{"orderId":"O-204", "item":"Wireless Mouse", "amount":39.98}`; model output may vary slightly. Model, API, and binding errors fail the program with `check` rather than being presented as a valid result.
