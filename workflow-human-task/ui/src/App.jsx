import React, { useEffect, useState } from 'react';

// Identity headers for the workflow management API: the role filters which
// tasks this caller sees, and the user ID is recorded on decisions. The module
// does not authenticate callers — in a real application a backend or gateway
// sets these from the logged-in user.
const HEADERS = {
  'Content-Type': 'application/json',
  'x-user-id': 'alice',
  'x-user-roles': 'MANAGER',
};

async function api(path, options = {}) {
  const res = await fetch(`/workflow${path}`, { ...options, headers: { ...HEADERS, ...(options.headers || {}) } });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data?.error?.message || `HTTP ${res.status}`);
  }
  return data;
}

function Task({ task, onDone }) {
  const [comment, setComment] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(null);
  const payload = task.payload || {};

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
    <li style={{ border: '1px solid #ccc', borderRadius: 8, padding: 16, marginBottom: 12, listStyle: 'none' }}>
      <strong>{task.title || task.taskName}</strong>
      <p>{task.description}</p>
      <pre style={{ background: '#f6f6f6', padding: 8 }}>{JSON.stringify(payload, null, 2)}</pre>
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

export default function App() {
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
    <main style={{ fontFamily: 'sans-serif', maxWidth: 720, margin: '2rem auto' }}>
      <h1>Pending claim approvals</h1>
      {error && <p style={{ color: 'red' }}>Cannot reach the management API: {error}</p>}
      {tasks.length === 0 && !error && <p>No pending tasks. Submit a claim and it will appear here.</p>}
      <ul style={{ padding: 0 }}>
        {tasks.map((t) => <Task key={t.taskId} task={t} onDone={load} />)}
      </ul>
    </main>
  );
}
