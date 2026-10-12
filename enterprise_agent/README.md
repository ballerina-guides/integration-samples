# Two-tool delivery agent

## Scenario and architecture

An AI agent answers a delivery question using exactly two Ballerina tools: `lookupOrder` and `lookupShipment`. Each tool calls an in-process HTTP backend fixture; the OpenAI model call is live. The order fixture maps `O-100` to `S-100`; the shipment fixture reports `In transit`, ETA `2026-10-15`. There is no RAG or persistent memory.

## Prerequisites and setup

- Ballerina 2201.14.0. The distribution is in `Ballerina.toml`; the AI and OpenAI provider versions are pinned in `Dependencies.toml`.
- An OpenAI account with API access and a valid key.

Copy `Config.toml.example` to `Config.toml`, insert the key, then run:

```sh
bal build
bal run
```

## Input and verification

The sample asks `When will order O-100 arrive?`. Inspect console lines `Tool: lookupOrder O-100` and `Tool: lookupShipment S-100` to confirm the model really used both tools. If either is absent, it did not complete the demonstrated two-backend lookup. The response should be consistent with `In transit` and `2026-10-15`; wording can vary. Direct mock checks are available at `http://localhost:9091/orders/O-100` and `http://localhost:9092/shipments/S-100`. No external enterprise backend is contacted.
