# Claim processing workflow

A simple durable workflow written with the [`ballerina/workflow`](https://central.ballerina.io/ballerina/workflow/latest) module. An insurance claim goes through two activities:

1. `verifyClaim` — checks the claim against the policy.
2. `makePayment` — pays the approved amount.

Each activity result is recorded durably, so if the process crashes between the two steps, the workflow resumes from where it left off instead of starting over.

## Run the example

```bash
bal run
```

The included `Config.toml` uses the `IN_MEMORY` engine, so no external server is needed:

```toml
[ballerina.workflow]
mode = "IN_MEMORY"
```

To run against a durable [Temporal](https://temporal.io) engine instead, set `mode = "LOCAL"` in `Config.toml` and start a development server with:

```bash
temporal server start-dev
```

## Related reading

- [Write a workflow with Ballerina](https://ballerina.io/learn/write-a-workflow-with-ballerina/)
