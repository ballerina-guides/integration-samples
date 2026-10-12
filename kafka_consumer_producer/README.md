# React to an order event

The Ballerina Kafka listener consumes an `orders` event and publishes a `fulfillment` event containing the order ID, product ID, and `READY_TO_PACK` status. Kafka is the actual broker; no external account is required.

Requires Ballerina 2201.14.0, Docker Compose, and a Kafka CLI (the one in the container is used below). `Dependencies.toml` produced by `bal build` pins the Kafka connector. Copy `Config.toml.example` to `Config.toml` if changing defaults.

```sh
docker compose up -d
bal build
bal run
```

In separate terminals, publish an order and inspect output:

```sh
printf '%s\n' '{"orderId":"O-100","productId":"P-100","quantity":2}' | docker compose exec -T broker /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic orders
```

```sh
docker compose exec -T broker /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic fulfillment --from-beginning
```

Expect `{"orderId":"O-100","productId":"P-100","status":"READY_TO_PACK"}` and a `Published fulfillment for O-100` log. Stop with `docker compose down`. Broker redelivery can duplicate messages; this sample does not promise exactly-once fulfillment.
