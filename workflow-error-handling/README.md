# Workflow error handling and replaying failed activities

A claim payout workflow that shows the two ways to recover from activity failures with the [`ballerina/workflow`](https://central.ballerina.io/ballerina/workflow/latest) module:

1. `convertCurrency` — fails transiently (simulated flaky service) and recovers with an **automatic retry policy** (`retryPolicy = {maxRetries: 3, ...}`).
2. `depositPayout` — fails on a malformed account number and waits for **manual review** (`retryPolicy = "OPS"`); an operator retries it as-is, retries it with corrected input, or rejects it.
3. `notifyCustomer` — runs only after the deposit succeeds.

Because every completed activity result is stored durably, replaying the failed activity never re-executes the earlier steps — each activity behaves as its own store-and-forward stage.

The operator reviews failures through the module's built-in **management API**, using the shared [workflow-dashboard](../workflow-dashboard) app — a minimal single-page React dashboard with three tabs: **Workflows** (instances with input, activity inputs/outputs, and status), **Human Tasks**, and **Failed Activities** (Retry / Retry with changes / Reject).

## Prerequisites

- [Ballerina](https://ballerina.io/downloads/) 2201.13.4 or greater
- [Temporal CLI](https://docs.temporal.io/cli) for the local development server
- Node.js 20+ (for the review UI)

## Run the example

1. Start a local Temporal development server:

   ```bash
   temporal server start-dev
   ```

2. Run the Ballerina service from this directory:

   ```bash
   bal run
   ```

   `Config.toml` enables the management API on `http://localhost:8234/workflow/`.

3. Start the shared dashboard, pointing it at this sample's task queue:

   ```bash
   cd ../workflow-dashboard
   npm install
   VITE_TASK_QUEUE=CLAIM_PAYOUT_QUEUE npm run dev
   ```

4. Submit a payout with a **bad account number** (note the missing `ACC-` prefix):

   ```bash
   curl -X POST http://localhost:8080/payouts \
        -H 'Content-Type: application/json' \
        -d '{"claimId": "CLM-001", "accountNo": "12345", "amount": 750.0, "currency": "USD"}'
   ```

   Watch the service logs: `convertCurrency` fails twice and succeeds on the third automatic retry. `depositPayout` then fails and suspends the workflow for review.

5. Open <http://localhost:3000>. The **Workflows** tab lists the payout workflow — open its details to see the workflow input and each activity's input, output, and status, including the failed `depositPayout` attempt. Under **Failed Activities**, fix the `accountNo` to `ACC-12345` in the input box and click **Retry with changes**. The workflow resumes from the failed activity and completes.

6. Check the result:

   ```bash
   curl http://localhost:8080/payouts/<workflowId>
   ```

You can also review failures with plain `curl` instead of the UI:

```bash
curl 'http://localhost:8234/workflow/review-activities?status=PENDING' -H 'x-user-roles: OPS'

curl -X POST 'http://localhost:8234/workflow/review-activities/<taskId>/proceed-with-input' \
     -H 'Content-Type: application/json' -H 'x-user-roles: OPS' \
     -d '{"input": {"accountNo": "ACC-12345", "amount": 225000.0}}'
```

## Related reading

- [Handle errors and replay failed activities in workflows](https://ballerina.io/learn/handle-errors-and-replay-failed-activities-in-workflows/)
