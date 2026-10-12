# Purchase approval workflow

Submit a purchase request, wait durably for a manager's decision, then process approved purchases. This uses the Ballerina workflow library and a local Temporal server. `processPurchase` only logs and returns a mock PO reference; no purchasing system is called. The management API exposes pending human tasks. Its unauthenticated local configuration must not be exposed publicly.

Requires Ballerina 2201.14.0 and Temporal CLI. The workflow library dependency version is pinned in `Dependencies.toml` after `bal build`. Copy `Config.toml.example` to `Config.toml`. Start `temporal server start-dev`, then in this directory run `bal build` and `bal run`.

Submit input:

```sh
curl -X POST http://localhost:8080/purchases -H 'Content-Type: application/json' -d '{"requestId":"R-100","item":"Travel mugs","amount":150.0}'
```

Save the returned `workflowId`; status initially says `PENDING_APPROVAL`. Poll `curl http://localhost:8080/purchases/<workflowId>`; it stays `RUNNING` while awaiting a person. List tasks with `curl 'http://localhost:8234/workflow/human-tasks?status=PENDING' -H 'x-user-roles: MANAGER'`. Use its `taskId` to approve:

```sh
curl -X POST 'http://localhost:8234/workflow/human-tasks/<taskId>/complete' -H 'Content-Type: application/json' -H 'x-user-id: alice' -H 'x-user-roles: MANAGER' -d '{"result":{"approved":true,"comment":"Within budget"}}'
```

Poll the purchase URL again. Expect `COMPLETED` and `Purchase R-100 processed: PO-R-100`; the service logs `Processing approved purchase R-100`. To verify recovery, stop `bal run` after the task appears, restart it with the same Temporal server, approve, and confirm the same workflow completes. The workflow engine records progress, but retries do not guarantee exactly-once effects in external systems. This mock activity has no external side effect.
