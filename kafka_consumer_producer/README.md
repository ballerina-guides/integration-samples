# React to an order event

A Ballerina Kafka listener consumes events from the `orders` topic and publishes a `fulfillment` event containing the order ID, product ID, and `READY_TO_PACK` status for each order. Kafka is a real broker running locally; no external account is required.

## Prerequisites

- Ballerina 2201.14.0 (`bal version`). The Kafka connector version is locked in `Dependencies.toml`.
- Docker Compose. The Kafka CLI inside the broker container is used below.

## Run

Copy `Config.toml.example` to `Config.toml` only if you change the defaults. Then run:

```sh
docker compose up -d
bal build
bal run
```

## Verify

In separate terminals, publish an order and inspect the output topic:

```sh
printf '%s\n' '{"orderId":"O-100","productId":"P-100","quantity":2}' | docker compose exec -T broker /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic orders
```

```sh
docker compose exec -T broker /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic fulfillment --from-beginning
```

Expect `{"orderId":"O-100","productId":"P-100","status":"READY_TO_PACK"}` and a `Published fulfillment for O-100` log. Stop the broker with `docker compose down`. Broker redelivery can duplicate messages; this sample does not promise exactly-once fulfillment.
