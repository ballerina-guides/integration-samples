# Two-tool delivery agent

An AI agent answers a delivery question using two Ballerina tools, `lookupOrder` and `lookupShipment`. Each tool calls an HTTP backend; the OpenAI model call is live. There is no RAG or persistent memory.

The `mock_backend` directory contains local fixtures for the order (`http://localhost:9091/orders/{id}`) and shipment (`http://localhost:9092/shipments/{id}`) systems. The order fixture links every order to shipment `S-100`; the shipment fixture reports `In transit` with ETA `2026-10-15`. Replace the URLs in `main.bal` to use real systems.

## Prerequisites

- Ballerina 2201.14.0 (`bal version`). `ballerina/ai` and `ballerinax/ai.openai` versions are locked in `Dependencies.toml`.
- An OpenAI account with API access and a valid key.

## Run

Start the mock backend in a separate terminal and leave it running:

```sh
bal run mock_backend/mock_backend.bal
```

Copy `Config.toml.example` to `Config.toml`, insert the key, and keep the real file private. Then run the agent:

```sh
bal build
bal run
```

## Verify

The sample asks `When will order O-100 arrive?`. The logged answer should mention the travel mug, `In transit`, and `2026-10-15`; wording can vary. Check the fixtures directly with `curl http://localhost:9091/orders/O-100` and `curl http://localhost:9092/shipments/S-100`. If the mock backend is not running, the tools return connection errors and the agent cannot answer with shipment details.
