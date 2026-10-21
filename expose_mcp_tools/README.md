# Expose product stock as an MCP tool

An MCP server exposes `getProductStock(productId)` over Streamable HTTP at `http://localhost:9090/mcp`. The tool queries a stock fixture at `http://localhost:9091/stock/{id}`, defined in `mock_backend.bal` and started with the same program. The fixture returns an availability of 12 for any ID. A compatible AI client can discover and invoke the tool; this project does not run a model.

## Prerequisites

- Ballerina 2201.14.0 (`bal version`). `Dependencies.toml` locks `ballerina/mcp` 1.3.0 and its compatible `ballerina/http` 2.17.3 dependency. Build with `--locking-mode=hard` to keep this set: `ballerina/http` 2.18.0 causes an MCP listener startup error.
- A Streamable HTTP MCP client such as MCP Inspector, or `curl` for protocol checks. No credentials are needed; `Config.toml.example` documents the ports.

## Run

```sh
bal build --locking-mode=hard
bal run --locking-mode=hard
```

## Verify

Connect your client to `http://localhost:9090/mcp` using Streamable HTTP. Discover `getProductStock`, then call it with `{"productId":"P-100"}`. A minimal protocol check with `curl` is:

```sh
curl -X POST http://localhost:9090/mcp -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"sample-client","version":"1"}}}'
curl -X POST http://localhost:9090/mcp -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -d '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
curl -X POST http://localhost:9090/mcp -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"getProductStock","arguments":{"productId":"P-100"}}}'
```

The tool result contains `{"productId":"P-100", "available":12}`, wrapped as text in the MCP response `content`. Check the fixture directly with `curl http://localhost:9091/stock/P-100`.
