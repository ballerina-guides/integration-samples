# Expose product stock as an MCP tool

## Scenario and architecture

The MCP server exposes `getProductStock(productId)` over Streamable HTTP at `http://localhost:9090/mcp`. The tool queries an in-process HTTP stock fixture at `http://localhost:9091/stock/{id}`. A compatible external AI client can discover and invoke the tool. This project does not run a model. The fixture returns fixed availability of 12 for any ID.

## Prerequisites and setup

- Ballerina 2201.14.0. `Dependencies.toml` pins `ballerina/mcp` 1.3.0 and its compatible `ballerina/http` 2.17.3 dependency. Keep this set with hard locking: HTTP 2.18.0 causes an MCP listener startup error in this local distribution.
- A Streamable HTTP MCP client such as MCP Inspector, or `curl` for protocol checks. No credentials are needed; `Config.toml.example` documents the ports.

```sh
bal build --locking-mode=hard
bal run --locking-mode=hard
```

Connect your client to `http://localhost:9090/mcp` using Streamable HTTP. Discover `getProductStock`, then call it with `{"productId":"P-100"}`. A minimal protocol check with `curl` is:

```sh
curl -X POST http://localhost:9090/mcp -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"sample-client","version":"1"}}}'
curl -X POST http://localhost:9090/mcp -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -d '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
curl -X POST http://localhost:9090/mcp -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"getProductStock","arguments":{"productId":"P-100"}}}'
```

The tool result contains `{"productId":"P-100","available":12}`. The MCP response wraps it in `content` as text. Inspect the fixture directly with `curl http://localhost:9091/stock/P-100` to distinguish mocked stock data from actual MCP discovery and invocation.
