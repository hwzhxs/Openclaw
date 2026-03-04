# Task Handoff

- **From:** Thinker 🧠
- **To:** Creator 🛠️
- **Priority:** normal
- **Created:** 2026-02-25 05:55 UTC
- **Slack Thread:** 1771998876.288459

## Task
Write the full team README.md based on the outline below. Tone: casual, hiphop energy, but informative. Think "crew intro" not "corporate doc." Use emoji freely, keep it punchy.

## Context
We're 4 AI agents on one Windows VM, collaborating via shared task queue + Slack threads. This README lives at the project root and tells humans (and future agents) who we are and how to work with us.

## Outline

### 1. 🎤 The Crew (Hero Section)
- One-liner: "Four AI agents. One VM. Zero chill."
- Quick vibe-set — we're a squad, not a committee
- Team table: Name, emoji, role in one sentence each
  - Admin (xXx) 🎤 — Orchestrator. Routes tasks, keeps the beat going.
  - Thinker 🧠 — Researcher & strategist. Goes deep so the team doesn't go wrong.
  - Creator 🛠️ — Builder. Turns plans into reality, code into product.
  - Gatekeeper 🛡️ — QA & security. Nothing ships without the stamp.

### 2. 🔄 How We Work
- Shared task queue (`shared/tasks/`) — markdown files as task tickets
- Slack channel #agent-team for real-time comms + threading
- Flow: Admin assigns → Agent works → Gatekeeper reviews → Done (or iterate)
- Every handoff posts to Slack with emoji prefixes (📥 📤 ✅ ❌)
- Threaded conversations keep task chains traceable

### 3. 📋 Giving Us Tasks
- Talk to Admin — he's the entry point
- What a good task looks like: clear goal, context, expected deliverable
- What happens next: Admin routes to the right agent(s), you get updates in Slack
- Urgent vs normal priority — mention it and we'll adjust

### 4. 🏗️ Architecture (Keep It Brief)
- Single Windows VM, 4 OpenClaw agent instances
- Each agent has own workspace, shared task directory
- Heartbeat system for periodic queue checks
- Webhook triggers for immediate handoffs
- Memory files for continuity across sessions

### 5. 🎯 Our Principles
- Transparency — every move posts to Slack
- Quality gate — Gatekeeper reviews everything before it's "done"
- Depth over speed — we'd rather be thorough than fast
- Ask don't assume — if unclear, we ask before acting

### 6. 🚀 Quick Start
- Step-by-step: How to drop a task for the team
- Where to watch progress (#agent-team Slack channel)
- How to know when it's done (✅ DONE + 🏁 FINAL posts)

## Deliverable
Full README.md file. After writing, hand off to Gatekeeper for review before posting as final.
