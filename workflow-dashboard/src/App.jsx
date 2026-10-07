import React, { useEffect, useState } from 'react';

// Identity headers for the workflow management API: the roles filter which
// tasks this caller sees, and the user ID is recorded on decisions. The module
// does not authenticate callers — in a real application a backend or gateway
// sets these from the logged-in user.
const HEADERS = {
  'Content-Type': 'application/json',
  'x-user-id': 'admin',
  'x-user-roles': 'MANAGER,OPS,CLAIMS_ADMIN,OPS_LEAD',
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
const preStyle = { background: '#f6f6f6', padding: 8, margin: '4px 0', overflowX: 'auto', fontSize: 12 };
const rowStyle = { border: '1px solid #ccc', borderRadius: 6, padding: '8px 12px', marginBottom: 6, listStyle: 'none' };
const metaStyle = { color: '#666', fontSize: 13, margin: '2px 0' };
// Listings are namespace-wide, so items from other integrations sharing the
// same Temporal server also show up. Items that this integration's worker
// does not serve — a different task queue, or a workflow type without an
// active worker — are hidden by default. The "Show inactive integrations"
// filter lists them grayed out with their actions disabled.
const inactiveStyle = { ...boxStyle, opacity: 0.5 };
const inactiveRowStyle = { ...rowStyle, opacity: 0.5 };

// This integration's task queue, passed as an environment variable when
// starting the dashboard (matches `taskQueue` in the sample's Config.toml),
// e.g. VITE_TASK_QUEUE=CLAIM_APPROVAL_QUEUE npm run dev
const MY_TASK_QUEUE = import.meta.env.VITE_TASK_QUEUE || null;

function hasActiveWorker(item, type, activeTypes) {
  if (MY_TASK_QUEUE && item.taskQueue && item.taskQueue !== MY_TASK_QUEUE) {
    return false;
  }
  return activeTypes.has(type);
}

function Json({ value }) {
  if (value === null || value === undefined) {
    return <em>none</em>;
  }
  return <pre style={preStyle}>{JSON.stringify(value, null, 2)}</pre>;
}

// Workflow type of a task, e.g. "workflow-claimPayoutWorkflow.depositPayout" → "claimPayoutWorkflow".
function taskWorkflowType(task) {
  const type = task.parentWorkflowType || (task.taskName || '').split('.')[0];
  return type.replace(/^workflow-/, '');
}

const list = (v) => (v && v.length ? v.join(', ') : null);

// A task names who may decide it (userRoles / users, minus the exclusions) and who
// administers it (administratorRoles / administratorUsers). The server answers both
// questions for the calling identity in canComplete and canAdminister.
function Audience({ task }) {
  return (
    <p style={metaStyle}>
      {list(task.userRoles) && <>Roles: {list(task.userRoles)} </>}
      {list(task.users) && <>Users: {list(task.users)} </>}
      {list(task.excludedRoles) && <>Excluded roles: {list(task.excludedRoles)} </>}
      {list(task.excludedUsers) && <>Excluded users: {list(task.excludedUsers)} </>}
      {(list(task.administratorRoles) || list(task.administratorUsers)) && (
        <>Administered by: {[list(task.administratorRoles), list(task.administratorUsers)].filter(Boolean).join(', ')} </>
      )}
      {task.kind === 'HUMAN_TASK' && task.canAdminister && <strong>you administer this task</strong>}
      {task.kind === 'HUMAN_TASK' && !task.canComplete && !task.canAdminister && (
        <em>you may not act on this task</em>
      )}
    </p>
  );
}

// Administrator actions. An administrator does not decide the task on the owner's
// behalf by default — it hands the task to someone else, or moves its deadline.
function AdminActions({ task, active, onDone }) {
  const [roles, setRoles] = useState('');
  const [hours, setHours] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(null);
  const id = encodeURIComponent(task.taskId);

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

  const reassign = () => act(() => api(`/human-tasks/${id}/reassign`, {
    method: 'POST',
    body: JSON.stringify({ userRoles: roles.split(',').map((r) => r.trim()).filter(Boolean) }),
  }));
  // An empty value clears the deadline, so the task waits indefinitely.
  const setDeadline = () => act(() => api(`/human-tasks/${id}/deadline`, {
    method: 'POST',
    body: JSON.stringify({ timeoutMillis: hours === '' ? null : Number(hours) * 3600000 }),
  }));

  return (
    <fieldset style={{ border: '1px dashed #999', borderRadius: 6, marginTop: 8, fontSize: 13 }}>
      <legend>Administer</legend>
      <input
        placeholder="Reassign to roles, e.g. SENIOR_MANAGER"
        value={roles}
        onChange={(e) => setRoles(e.target.value)}
        style={{ width: '45%', marginRight: 8 }}
        disabled={!active}
      />
      <button disabled={busy || !active || !roles.trim()} onClick={reassign}>Reassign</button>{' '}
      <input
        placeholder="Deadline in hours"
        value={hours}
        onChange={(e) => setHours(e.target.value)}
        style={{ width: 120, marginRight: 8 }}
        disabled={!active}
      />
      <button disabled={busy || !active} onClick={setDeadline}>Set deadline</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </fieldset>
  );
}

function InactiveNote({ taskQueue }) {
  return (
    <p style={{ color: '#888', fontStyle: 'italic', margin: '4px 0' }}>
      Grayed out because its integration is not active — no worker is serving
      {taskQueue ? ` task queue "${taskQueue}"` : ' its task queue'}. Start that integration to act on it.
    </p>
  );
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

// Activity types carry a "workflow-<workflowType>." routing prefix in Temporal
// history; show just the function name.
function shortName(name) {
  const parts = (name || '').split('.');
  return parts[parts.length - 1];
}

function ActivityNode({ node }) {
  const failed = node.status === 'FAILED' || node.status === 'TIMED_OUT';
  return (
    <li style={{ listStyle: 'none' }}>
      <details style={rowStyle}>
        <summary style={{ cursor: 'pointer' }}>
          <strong>{shortName(node.name)}</strong>
          {' — '}
          <span style={{ color: failed ? 'red' : 'inherit' }}>{node.status}</span>
          <span style={{ color: '#888', fontSize: 12 }}>
            {node.type !== 'ACTIVITY' ? ` · ${node.type}` : ''}
            {node.startTime ? ` · started ${node.startTime}` : ''}
          </span>
        </summary>
        <div style={{ marginTop: 6 }}>
          <div style={metaStyle}>{node.name}{node.attempt > 1 ? ` · attempt ${node.attempt}` : ''}</div>
          {node.failure && <p style={{ color: 'red', margin: '4px 0' }}>{node.failure.message}</p>}
          Input: <Json value={node.input} />
          Output: <Json value={node.output} />
        </div>
      </details>
    </li>
  );
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
      <div style={rowStyle}>
        <strong>{workflow.workflowType}</strong> — {status}
        <div style={metaStyle}>{workflow.workflowId} · started {workflow.startTime}</div>
        <details open>
          <summary style={{ cursor: 'pointer' }}>Input</summary>
          <Json value={input} />
        </details>
      </div>
      <h3>Activities</h3>
      {activities.length === 0 && <p>No activities recorded yet.</p>}
      <ul style={{ padding: 0 }}>
        {activities.map((a) => <ActivityNode key={a.id} node={a} />)}
      </ul>
    </div>
  );
}

function Workflows({ activeTypes, showInactive }) {
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
  const visible = items.filter((w) => showInactive || hasActiveWorker(w, w.workflowType, activeTypes));
  const hidden = items.length - visible.length;
  return (
    <div>
      {error && <p style={{ color: 'red' }}>Cannot reach the management API: {error}</p>}
      {visible.length === 0 && !error && (
        <p>No workflows to show.{hidden > 0 ? ` ${hidden} from inactive integrations are hidden by the filter.` : ' Start one and it will appear here.'}</p>
      )}
      <ul style={{ padding: 0 }}>
        {visible.map((w) => {
          const active = hasActiveWorker(w, w.workflowType, activeTypes);
          return (
            <li key={w.workflowId} style={active ? rowStyle : inactiveRowStyle}>
              <strong>{w.workflowType}</strong> — {w.status}
              {!active && <span style={{ color: '#888', fontSize: 12 }}> — integration not active</span>}
              <button style={{ float: 'right' }} onClick={() => setSelected(w)}>Details</button>
              <div style={metaStyle}>{w.workflowId} · started {w.startTime}</div>
            </li>
          );
        })}
      </ul>
    </div>
  );
}

// ── Human tasks ──────────────────────────────────────────────────────────────

function HumanTask({ task, active, onDone }) {
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
    <li style={active ? boxStyle : inactiveStyle}>
      <strong>{task.title || task.taskName}</strong>
      <p>{task.description}</p>
      <Json value={task.taskInput} />
      <Audience task={task} />
      {!active && <InactiveNote taskQueue={task.taskQueue} />}
      <input
        placeholder="Comment"
        value={comment}
        onChange={(e) => setComment(e.target.value)}
        style={{ width: '60%', marginRight: 8 }}
        disabled={!active || !task.canComplete}
      />
      <button disabled={busy || !active || !task.canComplete} onClick={() => decide(true)}>Approve</button>{' '}
      <button disabled={busy || !active || !task.canComplete} onClick={() => decide(false)}>Reject</button>
      {task.canAdminister && <AdminActions task={task} active={active} onDone={onDone} />}
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </li>
  );
}

function HumanTasks({ activeTypes, showInactive }) {
  const [tasks, setTasks] = useState([]);
  const [error, setError] = useState(null);

  const load = async () => {
    try {
      // The list endpoint returns summaries; fetch each task for its payload.
      const list = await api('/human-tasks?status=PENDING');
      const details = await Promise.all(
        (list.items || []).map((t) => api(`/human-tasks/${encodeURIComponent(t.taskId)}`).then((d) => ({ ...t, ...d }))),
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

  const visible = tasks.filter((t) => showInactive || hasActiveWorker(t, taskWorkflowType(t), activeTypes));
  const hidden = tasks.length - visible.length;
  return (
    <div>
      {error && <p style={{ color: 'red' }}>Cannot reach the management API: {error}</p>}
      {visible.length === 0 && !error && (
        <p>No pending tasks to show.{hidden > 0 ? ` ${hidden} from inactive integrations are hidden by the filter.` : ''}</p>
      )}
      <ul style={{ padding: 0 }}>
        {visible.map((t) => (
          <HumanTask key={t.taskId} task={t} active={hasActiveWorker(t, taskWorkflowType(t), activeTypes)} onDone={load} />
        ))}
      </ul>
    </div>
  );
}

// ── Failed activities (review) ───────────────────────────────────────────────

function FailedActivity({ task, active, onDone }) {
  const [inputJson, setInputJson] = useState(JSON.stringify(task.taskInput || {}, null, 2));
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
    <li style={active ? boxStyle : inactiveStyle}>
      <strong>{task.activityName || task.taskName}</strong>
      <p>Workflow: {task.parentWorkflowId}</p>
      <p style={{ color: 'red' }}>{task.errorMessage}</p>
      <Audience task={task} />
      {!active && <InactiveNote taskQueue={task.taskQueue} />}
      <label>
        Activity input (edit to retry with corrected values):
        <textarea
          rows={6}
          value={inputJson}
          onChange={(e) => setInputJson(e.target.value)}
          style={{ width: '100%', fontFamily: 'monospace' }}
          disabled={!active}
        />
      </label>
      <button disabled={busy || !active} onClick={retry}>Retry</button>{' '}
      <button disabled={busy || !active} onClick={retryWithInput}>Retry with changes</button>{' '}
      <button disabled={busy || !active} onClick={reject}>Reject</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </li>
  );
}

function FailedActivities({ activeTypes, showInactive }) {
  const [tasks, setTasks] = useState([]);
  const [error, setError] = useState(null);

  const load = async () => {
    try {
      // The list endpoint returns summaries; fetch each task for its error and input.
      const list = await api('/review-activities?status=PENDING');
      const details = await Promise.all(
        (list.items || []).map((t) => api(`/review-activities/${encodeURIComponent(t.taskId)}`).then((d) => ({ ...t, ...d }))),
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

  const visible = tasks.filter((t) => showInactive || hasActiveWorker(t, taskWorkflowType(t), activeTypes));
  const hidden = tasks.length - visible.length;
  return (
    <div>
      {error && <p style={{ color: 'red' }}>Cannot reach the management API: {error}</p>}
      {visible.length === 0 && !error && (
        <p>No failed activities to show.{hidden > 0 ? ` ${hidden} from inactive integrations are hidden by the filter.` : ''}</p>
      )}
      <ul style={{ padding: 0 }}>
        {visible.map((t) => (
          <FailedActivity key={t.taskId} task={t} active={hasActiveWorker(t, taskWorkflowType(t), activeTypes)} onDone={load} />
        ))}
      </ul>
    </div>
  );
}

// ── App ──────────────────────────────────────────────────────────────────────

const TAB_NAMES = ['Workflows', 'Human Tasks', 'Failed Activities'];

export default function App() {
  const [tab, setTab] = useState('Workflows');
  const [activeTypes, setActiveTypes] = useState(new Set());
  const [showInactive, setShowInactive] = useState(false);

  // Workflow types with an active worker in this integration; everything
  // else on the shared Temporal server is shown grayed out.
  const loadDefinitions = () => {
    api('/definitions')
      .then((d) => setActiveTypes(new Set(
        (d.definitions || []).filter((def) => def.isActive).map((def) => def.workflowType),
      )))
      .catch(() => setActiveTypes(new Set()));
  };

  useEffect(() => {
    loadDefinitions();
    const id = setInterval(loadDefinitions, 15000);
    return () => clearInterval(id);
  }, []);

  return (
    <main style={{ fontFamily: 'sans-serif', maxWidth: 720, margin: '2rem auto' }}>
      <h1>Workflow dashboard</h1>
      <nav style={{ marginBottom: 16 }}>
        {TAB_NAMES.map((name) => (
          <button
            key={name}
            onClick={() => setTab(name)}
            style={{ marginRight: 8, fontWeight: tab === name ? 'bold' : 'normal' }}
          >
            {name}
          </button>
        ))}
        <label style={{ marginLeft: 16, fontSize: 14 }}>
          <input
            type="checkbox"
            checked={showInactive}
            onChange={(e) => setShowInactive(e.target.checked)}
          />{' '}
          Show inactive integrations
        </label>
      </nav>
      {tab === 'Workflows' && <Workflows activeTypes={activeTypes} showInactive={showInactive} />}
      {tab === 'Human Tasks' && <HumanTasks activeTypes={activeTypes} showInactive={showInactive} />}
      {tab === 'Failed Activities' && <FailedActivities activeTypes={activeTypes} showInactive={showInactive} />}
    </main>
  );
}
