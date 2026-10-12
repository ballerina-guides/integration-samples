# Classify a support message

## Scenario and architecture

The Ballerina program sends one support message to a live OpenAI model, binds the response to a `Classification` record, then checks that category and priority are allowed values. This is a model call, not a mock. Typed binding checks the shape of the response; it does not guarantee that the classification is factually or commercially correct.

## Prerequisites and setup

- Ballerina 2201.14.0. `Ballerina.toml` pins the distribution; `Dependencies.toml` pins `ballerina/ai` and `ballerinax/ai.openai` versions resolved for that distribution.
- An OpenAI account with API access and a valid key.

Copy `Config.toml.example` to `Config.toml`, replace the placeholder key, and keep the real file private. Then run:

```sh
bal build
bal run
```

## Input and verification

The input is `My order O-100 arrived damaged. Please replace it.` The program prints a record with `category` in `shipping|billing|product` and `priority` in `low|medium|high`. A plausible result is `{"category":"product","priority":"high"}`, but model output may vary. Verify the printed values are among the allowed values and review their meaning before routing a real ticket. Model, API, and binding errors are printed and returned rather than presented as a valid classification.
