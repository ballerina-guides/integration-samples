# Claim approval workflow with a human task

An insurance claim workflow that pauses for a manager's decision between two automated activities:

1. `verifyClaim` — checks the claim.
2. `approveClaim` — a **human task**; the workflow durably waits (for hours or days) until a manager approves or rejects the claim.
3. `makePayment` — pays the approved amount.

The manager completes the task through the module's built-in **management API**, using the shared [workflow-dashboard](../workflow-dashboard) app — a minimal single-page React dashboard with three tabs: **Workflows** (instances with input, activity inputs/outputs, and status), **Human Tasks** (Approve/Reject), and **Failed Activities**.

## Prerequisites

- [Ballerina](https://ballerina.io/downloads/) 2201.13.4 or greater
- [Temporal CLI](https://docs.temporal.io/cli) for the local development server
- Node.js 20+ (for the approval UI)

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
   VITE_TASK_QUEUE=CLAIM_APPROVAL_QUEUE npm run dev
   ```

4. Submit a claim:

   ```bash
   curl -X POST http://localhost:8080/claims \
        -H 'Content-Type: application/json' \
        -d '{"claimId": "CLM-001", "policyNo": "POL-1234", "amount": 750.0}'
   ```

5. Open <http://localhost:3000>. The **Workflows** tab lists the claim workflow — open its details to see the input and activity progress. Under **Human Tasks**, review the pending task and click **Approve** or **Reject**.

6. Check the result:

   ```bash
   curl http://localhost:8080/claims/<workflowId>
   ```

You can also complete the task with plain `curl` instead of the UI:

```bash
curl 'http://localhost:8234/workflow/human-tasks?status=PENDING' -H 'x-user-roles: MANAGER'

curl -X POST 'http://localhost:8234/workflow/human-tasks/<taskId>/complete' \
     -H 'Content-Type: application/json' -H 'x-user-roles: MANAGER' \
     -d '{"result": {"approved": true, "comment": "Looks good"}}'
```

## Related reading

- [Write a workflow with a human task](https://ballerina.io/learn/write-a-workflow-with-a-human-task/)
