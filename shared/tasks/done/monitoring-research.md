# Monitoring/Dashboard Tools for Small AI Agent Team on Windows

## Comparison of 3 Free Tools

### 1. Uptime Kuma
**What:** Self-hosted status/uptime monitoring with a clean dashboard UI.
- **Pros:**
  - Beautiful, modern UI out of the box
  - Runs via Node.js or Docker — very lightweight (~60MB RAM)
  - Monitors processes, HTTP endpoints, TCP ports, and more
  - Built-in notifications (Slack, Discord, email, etc.)
  - Easy 2-minute setup: `npx uptime-kuma` or Docker one-liner
  - Can monitor each agent's health endpoint or process
- **Cons:**
  - Primarily a *status monitor*, not a task-flow visualizer
  - No built-in concept of task queues — you'd monitor file/process presence
  - Single-user by default (auth exists but basic)

### 2. Dashy
**What:** Self-hosted dashboard/startpage that aggregates status widgets.
- **Pros:**
  - Highly customizable YAML-based dashboard
  - Widgets for system stats (CPU, RAM, disk), service status, custom iframes
  - Can embed task queue file counts, process status via status-check widgets
  - Very lightweight static site + optional status-checking backend
  - Docker or bare Node.js setup
  - Looks great, very configurable layout
- **Cons:**
  - More of a *dashboard aggregator* than a monitoring tool — you configure what it shows
  - Requires manual widget setup for each thing you want to track
  - No alerting/notification system built in

### 3. Glances (with Web UI)
**What:** System monitoring tool (like htop) with a built-in web dashboard.
- **Pros:**
  - Installs via `pip install glances[web]` — one command
  - Real-time CPU, RAM, disk, network, and **per-process** monitoring
  - Web UI mode (`glances -w`) gives browser-accessible dashboard
  - Can show each agent process and its resource usage
  - REST API for building custom integrations
  - Extremely lightweight (<30MB RAM)
  - Works natively on Windows
- **Cons:**
  - System-focused, not task/workflow-focused
  - Web UI is functional but not pretty
  - No built-in Slack/notification integration (needs scripting)

---

## Recommendation: **Uptime Kuma + a simple custom status page**

**Why Uptime Kuma wins for this use case:**

1. **Closest to what we need** — monitors whether each agent is alive and responsive
2. **Slack notifications built in** — fits our existing workflow (we already post to Slack)
3. **Fastest to set up** — literally `npx uptime-kuma` and configure via browser
4. **Low resource footprint** — important since we're sharing one VM with 4 agents
5. **Can monitor the task queue** — set up a simple script that exposes task counts as an HTTP endpoint, then monitor it

**Suggested setup:**
- One Uptime Kuma monitor per agent (check process or a health endpoint)
- One monitor for the shared task queue directory (via a tiny HTTP script)
- Slack notifications on status changes
- Total overhead: ~60MB RAM, negligible CPU

For task-flow visibility specifically, our existing Slack thread approach already works well. Uptime Kuma would add the missing piece: **"are the agents actually running?"**

If we later want fancier dashboards, we can add Dashy on top to aggregate Uptime Kuma + system stats in one view.
