# OpenClaw Multi-Agent System

A 4-agent AI team running on [OpenClaw](https://openclaw.dev), wired to Slack. Each agent has a distinct role, personality, and workspace. Together they handle research, design, code, QA, and coordination — autonomously.

---

## The Team

| Agent | Role | Personality | Port |
|-------|------|-------------|------|
| **Admin** (xXx 🚔) | Coordinator — routes tasks, monitors team | Direct, structured | 18789 |
| **Thinker** (🧠) | Research, planning, specs | Analytical, thorough | 18790 |
| **Gatekeeper** (🛡️) | QA, review, standards | Critical, precise | 18800 |
| **Creator** (🎨) | Build, design, code, deploy | Action-oriented, visual | 18810 |

---

## Prerequisites

- **OpenClaw** installed on a Windows machine ([openclaw.dev](https://openclaw.dev))
- **Node.js** v18+ and **npm**
- A **Slack workspace** with 4 bot tokens (one per agent)
- A Windows VM or workstation (paths assume `C:\Users\<user>\`)
- **Git** installed

---

## One-Click Setup (~10 minutes)

### 1. Clone this repo

```powershell
git clone https://github.com/hwzhxs/Openclaw.git
cd Openclaw
```

### 2. Install OpenClaw (if not already)

```powershell
npm install -g openclaw
```

### 3. Copy workspace files to each agent's directory

```powershell
# Admin
Copy-Item agents\admin\* C:\Users\$env:USERNAME\.openclaw\workspace\ -Force -Recurse

# Thinker
Copy-Item agents\thinker\* C:\Users\$env:USERNAME\.openclaw-agent2\workspace\ -Force -Recurse

# Gatekeeper
Copy-Item agents\gatekeeper\* C:\Users\$env:USERNAME\.openclaw-agent3\workspace\ -Force -Recurse

# Creator
Copy-Item agents\creator\* C:\Users\$env:USERNAME\.openclaw-creator\workspace\ -Force -Recurse
```

### 4. Copy shared team files

```powershell
Copy-Item shared\* C:\Users\$env:USERNAME\shared\ -Force -Recurse
```

### 5. Configure secrets

Create `C:\Users\<user>\shared\secrets.env` (never committed):

```env
# Slack Bot Tokens — one per agent
SLACK_BOT_TOKEN_ADMIN=xoxb-...
SLACK_BOT_TOKEN_THINKER=xoxb-...
SLACK_BOT_TOKEN_GATEKEEPER=xoxb-...
SLACK_BOT_TOKEN_CREATOR=xoxb-...

# Primary read/post token
SLACK_BOT_TOKEN=xoxb-...

# OpenClaw Webhook Tokens (set in openclaw.json per agent)
OPENCLAW_WEBHOOK_ADMIN=hook__openclaw_secret
OPENCLAW_WEBHOOK_THINKER=hook__openclaw-agent2_secret
OPENCLAW_WEBHOOK_GATEKEEPER=hook__openclaw-agent3_secret
OPENCLAW_WEBHOOK_CREATOR=hook__openclaw-creator_secret
```

Load secrets in any script:
```powershell
. "C:\Users\$env:USERNAME\shared\scripts\load-secrets.ps1"
```

### 6. Configure `openclaw.json` per agent

Each agent needs its own `openclaw.json` in its workspace dir. Set:
- `agentId` (e.g. `openclaw`, `openclaw-agent2`, `openclaw-agent3`, `openclaw-creator`)
- `port` (18789, 18790, 18800, 18810)
- `slackBotToken` — from secrets
- `webhookSecret` — from secrets
- `model` — e.g. `github-copilot/claude-sonnet-4.6`

### 7. Start all 4 gateways

Open 4 terminal windows (or use a start script):

```powershell
# Admin (terminal 1)
cd C:\Users\$env:USERNAME\.openclaw\workspace
openclaw gateway start

# Thinker (terminal 2)
cd C:\Users\$env:USERNAME\.openclaw-agent2\workspace
openclaw gateway start

# Gatekeeper (terminal 3)
cd C:\Users\$env:USERNAME\.openclaw-agent3\workspace
openclaw gateway start

# Creator (terminal 4)
cd C:\Users\$env:USERNAME\.openclaw-creator\workspace
openclaw gateway start
```

Or check gateway status:
```powershell
openclaw gateway status
```

---

## Architecture

```
Slack Workspace
      │
      ├── #agent-team (main coordination channel)
      │
      ▼
┌─────────────────────────────────────────────────┐
│  OpenClaw Gateway (per agent, separate port)    │
│                                                 │
│  Admin :18789  ←→  Thinker :18790               │
│       ↕                  ↕                      │
│  Gatekeeper :18800 ←→ Creator :18810            │
└─────────────────────────────────────────────────┘
      │
      ├── C:\Users\<user>\shared\          (team files)
      │     ├── scripts/                  (Slack helpers, pulse)
      │     ├── context/                  (TEAM-MEMORY, specs, runbooks)
      │     ├── tasks/                    (task queue: *.md files)
      │     └── secrets.env              (NOT committed)
      │
      └── C:\Users\<user>\.openclaw-{agent}\workspace\
            ├── AGENTS.md               (role rules, team protocol)
            ├── SOUL.md                 (personality)
            ├── MEMORY.md               (standing memory)
            ├── skills/                 (agent-specific skills)
            └── memory/                 (episodic logs — local only)
```

### Task Flow

```
Thinker writes spec → Creator builds → Gatekeeper QA → Admin shares with user
```

Tasks live in `shared/tasks/`:
- `*-to-{agent}.md` — incoming
- `in-progress/` — being worked on  
- `done/` — completed

---

## Shared Scripts

| Script | Purpose |
|--------|---------|
| `scripts/pulse.ps1` | Monitor all agents, post heartbeat to Slack |
| `scripts/slack-send.ps1` | Send threaded Slack messages (supports @mentions) |
| `scripts/slack-notify.ps1` | Simple Slack notification |
| `scripts/load-secrets.ps1` | Load secrets.env into env vars |
| `scripts/panic-stop.ps1` | Emergency stop all agents |
| `scripts/panic-resume.ps1` | Resume after panic stop |

---

## Repo Structure

```
Openclaw/
├── README.md               ← You are here
├── .gitignore
├── agents/
│   ├── admin/              ← Admin workspace files (AGENTS.md, SOUL.md, etc.)
│   ├── thinker/            ← Thinker workspace files
│   ├── gatekeeper/         ← Gatekeeper workspace files
│   └── creator/            ← Creator workspace files + skills/
├── shared/
│   ├── context/            ← Team memory, runbooks, specs
│   ├── scripts/            ← Shared PowerShell utilities
│   └── specs/              ← Feature specs
└── workspace/              ← Legacy Creator workspace snapshot
```

---

## Notes

- **Never commit `secrets.env`** — it's in `.gitignore`
- Memory daily logs (`memory/YYYY-MM-DD.md`) are local only — not in repo
- Each agent reads `shared/context/TEAM-MEMORY.md` for cross-agent context
- The Slack channel ID for the team is set in each agent's `AGENTS.md`
