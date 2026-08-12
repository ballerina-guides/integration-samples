# Workflow dashboard

A minimal single-page React app for the [`ballerina/workflow`](https://central.ballerina.io/ballerina/workflow/latest) **management API**, shared by the workflow samples in this repository ([workflow-human-task](../workflow-human-task), [workflow-error-handling](../workflow-error-handling)). It has three tabs:

- **Workflows** — the workflow instances; each detail view shows the workflow input and every activity with its input, output, started time, and status.
- **Human Tasks** — pending human tasks, with Approve/Reject.
- **Failed Activities** — failed activities waiting for review, with Retry / Retry with changes / Reject.

Listings are namespace-wide, so items from other integrations sharing the same Temporal server also show up. Items that the current integration's worker does not serve — a different task queue, or a workflow type without an active worker — are hidden by default; tick **Show inactive integrations** to list them grayed out, labeled with the reason (the integration is not active), and with their actions disabled.

## Run

Point the dashboard at a running sample by passing that sample's task queue (the `taskQueue` value in its `Config.toml`):

```bash
npm install

# For workflow-human-task:
VITE_TASK_QUEUE=CLAIM_APPROVAL_QUEUE npm run dev

# For workflow-error-handling:
VITE_TASK_QUEUE=CLAIM_PAYOUT_QUEUE npm run dev
```

Then open <http://localhost:3000>. The dev server proxies `/workflow` to the management API at `http://localhost:8234` (see `vite.config.js`).

The identity headers (`x-user-id`, `x-user-roles`) are hardcoded in `src/App.jsx` for simplicity — the workflow module uses them to filter tasks by role and record who decided; it does not authenticate callers. In a real application, a backend or gateway sets them from the logged-in user.
