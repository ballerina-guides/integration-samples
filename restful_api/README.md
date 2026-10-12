# Combine product and stock services

`GET /catalog/{id}` reads the local product service on 9091 and stock service on 9092, then returns one JSON response. Both backends are in-process fixture services; replace them with real enterprise endpoints for a production integration.

Requires Ballerina 2201.14.0. The only dependencies are distribution modules `ballerina/http`; no extra connector version is needed. `Config.toml.example` documents the empty configuration. Run `bal build`, then `bal run`. In another terminal run:

```sh
curl http://localhost:8080/catalog/P-100
```

Expected result: `{"id":"P-100","name":"Travel mug","price":18.50,"available":12}` (JSON number formatting may omit the final zero). Verify the two fixtures separately at `http://localhost:9091/products/P-100` and `http://localhost:9092/stock/P-100`. The `id` is echoed by both mocks, while product name, price, and stock are fixed fixture values.
