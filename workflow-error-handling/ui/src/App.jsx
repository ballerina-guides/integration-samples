import React, { useEffect, useState } from 'react';

// Identity headers used by the workflow management API for role-based access.
// In a real application these come from your login/identity provider.
const HEADERS = {
  'Content-Type': 'application/json',
  'x-user-id': 'olivia',
  'x-user-roles': 'OPS',
};

async function api(path, options = {}) {
  const res = await fetch(`/workflow${path}`, { ...options, headers: { ...HEADERS, ...(options.headers || {}) } });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data?.error?.message || `HTTP ${res.status}`);
  }
  return data;
}

function ReviewTask({ task, onDone }) {
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
    <li style={{ border: '1px solid #ccc', borderRadius: 8, padding: 16, marginBottom: 12, listStyle: 'none' }}>
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

export default function App() {
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
    <main style={{ fontFamily: 'sans-serif', maxWidth: 720, margin: '2rem auto' }}>
      <h1>Failed activities waiting for review</h1>
      {error && <p style={{ color: 'red' }}>Cannot reach the management API: {error}</p>}
      {tasks.length === 0 && !error && <p>No failed activities. Submit a payout with a bad account number and it will appear here.</p>}
      <ul style={{ padding: 0 }}>
        {tasks.map((t) => <ReviewTask key={t.taskId} task={t} onDone={load} />)}
      </ul>
    </main>
  );
}
