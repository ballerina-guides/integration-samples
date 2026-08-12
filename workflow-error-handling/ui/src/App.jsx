import React, { useEffect, useState } from 'react';

// Identity headers for the workflow management API: the roles filter which
// tasks this caller sees, and the user ID is recorded on decisions. The module
// does not authenticate callers — in a real application a backend or gateway
// sets these from the logged-in user.
const HEADERS = {
  'Content-Type': 'application/json',
  'x-user-id': 'admin',
  'x-user-roles': 'MANAGER,OPS',
};

async function api(path, options = {}) {
  const res = await fetch(`/workflow${path}`, { ...options, headers: { ...HEADERS, ...(options.headers || {}) } });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data?.error?.message || `HTTP ${res.status}`);
  }
  return data;
}

const boxStyle = { border: '1px solid #ccc', borderRadius: 8, padding: 16, marginBottom: 12, listStyle: 'none' };
const preStyle = { background: '#f6f6f6', padding: 8, margin: '4px 0', overflowX: 'auto' };

function Json({ value }) {
  if (value === null || value === undefined) {
    return <em>none</em>;
  }
  return <pre style={preStyle}>{JSON.stringify(value, null, 2)}</pre>;
}

// ── Workflows ────────────────────────────────────────────────────────────────

// The workflow input is not part of the list or detail responses; it is
// recorded in the first history event as base64-encoded JSON payloads.
function decodeStartInput(events) {
  try {
    const started = (events || []).find((e) => e.eventType === 'WORKFLOW_EXECUTION_STARTED');
    const payloads = started?.attributes?.input?.payloads || [];
    const decoded = payloads.map((p) => JSON.parse(atob(p.data)));
    return decoded.length === 1 ? decoded[0] : decoded.length ? decoded : null;
  } catch {
    return null;
  }
}

function WorkflowDetail({ workflow, onBack }) {
  const [status, setStatus] = useState(workflow.status);
  const [input, setInput] = useState(null);
  const [activities, setActivities] = useState([]);
  const [error, setError] = useState(null);

  const flatten = (nodes) => (nodes || []).flatMap((n) => [n, ...flatten(n.children)]);
  const id = encodeURIComponent(workflow.workflowId);

  const load = () => {
    Promise.all([
      api(`/workflows/${id}`),
      api(`/workflows/${id}/history`),
      api(`/workflows/${id}/activity-tree`),
    ])
      .then(([info, history, tree]) => {
        setStatus(info.status);
        setInput(decodeStartInput(history.events));
        setActivities(flatten(tree.nodes));
        setError(null);
      })
      .catch((e) => setError(e.message));
  };

  useEffect(() => {
    load();
    const intervalId = setInterval(load, 5000);
    return () => clearInterval(intervalId);
  }, [workflow.workflowId]);

  return (
    <div>
      <button onClick={onBack}>&larr; Back to workflows</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      <div style={boxStyle}>
        <strong>{workflow.workflowType}</strong> — {status}
        <p>ID: {workflow.workflowId}<br />Started: {workflow.startTime}</p>
        Input: <Json value={input} />
      </div>
      <h3>Activities</h3>
      {activities.length === 0 && <p>No activities recorded yet.</p>}
      <ul style={{ padding: 0 }}>
        {activities.map((a) => (
          <li key={a.id} style={boxStyle}>
            <strong>{a.name}</strong> — {a.status}
            <p>Started: {a.startTime || '-'}</p>
            {a.failure && <p style={{ color: 'red' }}>{a.failure.message}</p>}
            Input: <Json value={a.input} />
            Output: <Json value={a.output} />
          </li>
        ))}
      </ul>
    </div>
  );
}

function Workflows() {
  const [items, setItems] = useState([]);
  const [selected, setSelected] = useState(null);
  const [error, setError] = useState(null);

  const load = () => {
    api('/workflows?limit=30')
      .then((d) => { setItems(d.items || []); setError(null); })
      .catch((e) => setError(e.message));
  };

  useEffect(() => {
    load();
    const id = setInterval(load, 5000);
    return () => clearInterval(id);
  }, []);

  if (selected) {
    return <WorkflowDetail workflow={selected} onBack={() => setSelected(null)} />;
  }
  return (
    <div>
      {error && <p style={{ color: 'red' }}>Cannot reach the management API: {error}</p>}
      {items.length === 0 && !error && <p>No workflows yet. Start one and it will appear here.</p>}
      <ul style={{ padding: 0 }}>
        {items.map((w) => (
          <li key={w.workflowId} style={boxStyle}>
            <strong>{w.workflowType}</strong> — {w.status}
            <p>ID: {w.workflowId}<br />Started: {w.startTime}</p>
            <button onClick={() => setSelected(w)}>View details</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

// ── Human tasks ──────────────────────────────────────────────────────────────

function HumanTask({ task, onDone }) {
  const [comment, setComment] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(null);

  const decide = async (approved) => {
    setBusy(true);
    setError(null);
    try {
      await api(`/human-tasks/${encodeURIComponent(task.taskId)}/complete`, {
        method: 'POST',
        body: JSON.stringify({ result: { approved, comment } }),
      });
      onDone();
    } catch (e) {
      setError(e.message);
      setBusy(false);
    }
  };

  return (
    <li style={boxStyle}>
      <strong>{task.title || task.taskName}</strong>
      <p>{task.description}</p>
      <Json value={task.payload} />
      <input
        placeholder="Comment"
        value={comment}
        onChange={(e) => setComment(e.target.value)}
        style={{ width: '60%', marginRight: 8 }}
      />
      <button disabled={busy} onClick={() => decide(true)}>Approve</button>{' '}
      <button disabled={busy} onClick={() => decide(false)}>Reject</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </li>
  );
}

function HumanTasks() {
  const [tasks, setTasks] = useState([]);
  const [error, setError] = useState(null);

  const load = async () => {
    try {
      // The list endpoint returns summaries; fetch each task for its payload.
      const list = await api('/human-tasks?status=PENDING');
      const details = await Promise.all(
        (list.items || []).map((t) => api(`/human-tasks/${encodeURIComponent(t.taskId)}`)),
      );
      setTasks(details);
      setError(null);
    } catch (e) {
      setError(e.message);
    }
  };

  useEffect(() => {
    load();
    const id = setInterval(load, 5000);
    return () => clearInterval(id);
  }, []);

  return (
    <div>
      {error && <p style={{ color: 'red' }}>Cannot reach the management API: {error}</p>}
      {tasks.length === 0 && !error && <p>No pending tasks.</p>}
      <ul style={{ padding: 0 }}>
        {tasks.map((t) => <HumanTask key={t.taskId} task={t} onDone={load} />)}
      </ul>
    </div>
  );
}

// ── Failed activities (review) ───────────────────────────────────────────────

function FailedActivity({ task, onDone }) {
  const [inputJson, setInputJson] = useState(JSON.stringify(task.activityArgs || {}, null, 2));
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(null);

  const act = async (fn) => {
    setBusy(true);
    setError(null);
    try {
      await fn();
      onDone();
    } catch (e) {
      setError(e.message);
      setBusy(false);
    }
  };

  const id = encodeURIComponent(task.taskId);
  const retry = () => act(() => api(`/review-activities/${id}/proceed`, { method: 'POST' }));
  const retryWithInput = () => act(() => {
    const input = JSON.parse(inputJson);
    return api(`/review-activities/${id}/proceed-with-input`, { method: 'POST', body: JSON.stringify({ input }) });
  });
  const reject = () => act(() => api(`/review-activities/${id}/reject`, {
    method: 'POST',
    body: JSON.stringify({ feedback: 'Rejected by operator' }),
  }));

  return (
    <li style={boxStyle}>
      <strong>{task.activityName || task.taskName}</strong>
      <p>Workflow: {task.parentWorkflowId}</p>
      <p style={{ color: 'red' }}>{task.errorMessage}</p>
      <label>
        Activity input (edit to retry with corrected values):
        <textarea
          rows={6}
          value={inputJson}
          onChange={(e) => setInputJson(e.target.value)}
          style={{ width: '100%', fontFamily: 'monospace' }}
        />
      </label>
      <button disabled={busy} onClick={retry}>Retry</button>{' '}
      <button disabled={busy} onClick={retryWithInput}>Retry with changes</button>{' '}
      <button disabled={busy} onClick={reject}>Reject</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </li>
  );
}

function FailedActivities() {
  const [tasks, setTasks] = useState([]);
  const [error, setError] = useState(null);

  const load = async () => {
    try {
      // The list endpoint returns summaries; fetch each task for its error and input.
      const list = await api('/review-activities?status=PENDING');
      const details = await Promise.all(
        (list.items || []).map((t) => api(`/review-activities/${encodeURIComponent(t.taskId)}`)),
      );
      setTasks(details);
      setError(null);
    } catch (e) {
      setError(e.message);
    }
  };

  useEffect(() => {
    load();
    const id = setInterval(load, 5000);
    return () => clearInterval(id);
  }, []);

  return (
    <div>
      {error && <p style={{ color: 'red' }}>Cannot reach the management API: {error}</p>}
      {tasks.length === 0 && !error && <p>No failed activities waiting for review.</p>}
      <ul style={{ padding: 0 }}>
        {tasks.map((t) => <FailedActivity key={t.taskId} task={t} onDone={load} />)}
      </ul>
    </div>
  );
}

// ── App ──────────────────────────────────────────────────────────────────────

const TABS = {
  Workflows: <Workflows />,
  'Human Tasks': <HumanTasks />,
  'Failed Activities': <FailedActivities />,
};

export default function App() {
  const [tab, setTab] = useState('Workflows');

  return (
    <main style={{ fontFamily: 'sans-serif', maxWidth: 720, margin: '2rem auto' }}>
      <h1>Workflow dashboard</h1>
      <nav style={{ marginBottom: 16 }}>
        {Object.keys(TABS).map((name) => (
          <button
            key={name}
            onClick={() => setTab(name)}
            style={{ marginRight: 8, fontWeight: tab === name ? 'bold' : 'normal' }}
          >
            {name}
          </button>
        ))}
      </nav>
      {TABS[tab]}
    </main>
  );
}
