# Taskflow OS — L0 + L1 Reference

> PowerShell-based Slack monitoring safety layer and event data pipeline.
> Runs on Windows PowerShell 5.1+ using **PSSQLite** for local state storage.

---

## Architecture

```
┌───────────────────────────────────────────────┐
│  L0 Safety Layer  (taskflow-l0.ps1)           │
│  ┌──────────┐ ┌────────────┐ ┌─────────────┐ │
│  │Kill Switch│ │Rate Limiter│ │   Dedupe    │ │
│  └──────────┘ └────────────┘ └─────────────┘ │
│            JSONL Audit Log                    │
└───────────────────────────────────────────────┘
          ↕  dot-sourced by all scripts
┌───────────────────────────────────────────────┐
│  L1 Data Layer  (taskflow-collector.ps1)      │
│  ┌──────────────────────────────────────────┐ │
│  │ Event Collector (Slack API polling)      │ │
│  │  conversations.history + replies         │ │
│  │  reactions.get                           │ │
│  └──────────────────────────────────────────┘ │
│  ┌──────────────────────────────────────────┐ │
│  │ SQLite State Store (PSSQLite)            │ │
│  │  threads · events · violations           │ │
│  │  collector_state (cursor/bookmark)       │ │
│  └──────────────────────────────────────────┘ │
└───────────────────────────────────────────────┘
```

---

## Files

| File | Purpose |
|---|---|
| `taskflow-config.json` | Main config — all tunable parameters |
| `taskflow-l0.ps1` | L0 dot-sourceable module |
| `taskflow-collector.ps1` | L1 event collector script |
| `taskflow-schema.sql` | SQLite DDL (tables + indexes) |
| `taskflow-init.ps1` | DB initialiser (run once before anything else) |
| `taskflow.jsonl` | Append-only audit log (auto-created) |
| `taskflow.db` | SQLite database (auto-created by init) |

---

## Quick Start

### 1. Initialize the database

```powershell
cd C:\Users\azureuser\shared\scripts\taskflow
.\taskflow-init.ps1
```

This creates `taskflow.db` with all tables. Safe to run multiple times (idempotent).

### 2. Set your Slack token

```powershell
$env:SLACK_BOT_TOKEN = "xoxb-your-token-here"
```

Or add a `token` field to `taskflow-config.json` under the `slack` key (less secure).

### 3. Enable the system

Edit `taskflow-config.json`:

```json
{
  "enabled": true,
  "dry_run": true,   ← keep true while testing
  ...
}
```

> **The system starts with `enabled: false` and `dry_run: true` for safety.**
> It will NOT make any Slack API calls or DB writes until you explicitly enable it.

### 4. Run the collector (single pass, dry-run)

```powershell
.\taskflow-collector.ps1
```

### 5. Backfill the last N minutes

```powershell
.\taskflow-collector.ps1 -BackfillMinutes 60
```

### 6. Run continuously

```powershell
.\taskflow-collector.ps1 -Loop
```

Polls every `collector.poll_interval_seconds` (default 30s).

---

## Configuration Reference (`taskflow-config.json`)

```jsonc
{
  "enabled": false,      // Master kill switch. false = nothing runs.
  "dry_run": true,       // true = log intent but never write to Slack or DB.

  "slack": {
    "token_env_var": "SLACK_BOT_TOKEN",   // Env var name for the token
    "default_channel": "C0AGMF65DQB",     // Default Slack channel
    "api_base": "https://slack.com/api"
  },

  "rate_limit": {
    "max_posts_per_minute": 5,  // Max Slack posts allowed per agent per window
    "window_seconds": 60        // Rolling window size
  },

  "dedupe": {
    "cooldown_seconds": 300,    // Skip identical actions within this window
    "max_cache_entries": 1000   // Prune dedupe cache when it exceeds this
  },

  "collector": {
    "poll_interval_seconds": 30,   // How often -Loop polls
    "backfill_minutes": 60,        // Default backfill on first run (unused; pass -BackfillMinutes)
    "channels": ["C0AGMF65DQB"],   // Channels to monitor
    "collect_reactions": true,      // Also collect emoji reactions
    "collect_thread_replies": true  // Also collect thread replies
  },

  "storage": {
    "backend": "sqlite",
    "sqlite_path": "...",          // Absolute path to taskflow.db
    "fallback_json_path": "..."    // Used if PSSQLite unavailable
  },

  "logging": {
    "jsonl_path": "...",           // Absolute path to taskflow.jsonl
    "max_file_size_mb": 50         // Auto-rotate log when it hits this size
  }
}
```

---

## L0 Safety Layer (`taskflow-l0.ps1`)

Dot-source this in any script that touches Slack:

```powershell
. "$PSScriptRoot\taskflow-l0.ps1"
$cfg = Get-TFConfig
```

### Kill Switch

```powershell
Invoke-TF-KillCheck -Config $cfg -Context "my-script"
# Throws immediately if $cfg.enabled = false
```

### Rate Limiter

```powershell
$ok = Invoke-TF-RateCheck -Config $cfg -AgentKey "gatekeeper" -PassThru
if (-not $ok) { Write-Warning "Rate limited!"; return }
```

- `AgentKey` — per-agent bucket (string, any identifier)
- Without `-PassThru`, throws on limit hit
- Counts are in-process (per PowerShell session) — suitable for single-process agents

### Dedupe

```powershell
$isDupe = Invoke-TF-DedupeCheck -Config $cfg `
    -Message "Don't use unicode emoji" `
    -Channel "C0AGMF65DQB" `
    -Action  "warn_unicode_emoji"
if ($isDupe) { Write-Verbose "Already handled this recently."; return }
```

Returns `$true` = duplicate (skip), `$false` = new (proceed + registers it).

### JSONL Logging

```powershell
Write-TF-Log -Config $cfg -Type "violation_detected" -Details @{
    rule    = "no_unicode_emoji"
    user    = "U0AHN84GJGG"
    message = "original text"
} -DryRun $cfg.dry_run
```

Every log line is a JSON object:

```jsonc
{
  "timestamp": "2026-03-01T09:00:00.000Z",
  "type": "violation_detected",
  "dry_run": true,
  "agent_key": "default",
  "details": { "rule": "no_unicode_emoji", ... }
}
```

### Guarded Slack Post

```powershell
Send-TFSlackMessage -Config $cfg `
    -Text     "Please use :white_check_mark: instead of ✅" `
    -Channel  "C0AGMF65DQB" `
    -ThreadTs "1234567890.123456" `
    -AgentKey "gatekeeper"
```

Automatically applies: kill switch → rate limit → dedupe → dry-run guard → actual call.

### Guarded Webhook

```powershell
Send-TFWebhook -Config $cfg `
    -WebhookUrl "http://localhost:18800/hook__openclaw-agent3_secret" `
    -Body       @{ text = "Agent wake-up: threading violation detected" } `
    -AgentKey   "taskflow"
```

---

## L1 Data Layer (`taskflow-collector.ps1`)

### Event Types

| Type | Trigger |
|---|---|
| `message_posted` | New message in channel or thread root |
| `thread_reply` | Reply within a thread |
| `reaction_added` | Emoji reaction on a message |
| `message_deleted` | Message with `subtype=message_deleted` |

### SQLite Tables

```
threads(thread_ts PK, channel, starter_user, starter_text, status, created_at, updated_at)
events(id, thread_ts, channel, event_type, user, text, ts UNIQUE, raw_json, collected_at)
violations(id, thread_ts, channel, rule_name, details, action_taken, dry_run, created_at)
collector_state(channel PK, last_ts, last_run_at, messages_total, events_total)
```

### Query Examples

```powershell
Import-Module PSSQLite
$db = "C:\Users\azureuser\shared\scripts\taskflow\taskflow.db"

# All open threads
Invoke-SqliteQuery -DataSource $db -Query "SELECT * FROM threads WHERE status='open' ORDER BY updated_at DESC LIMIT 20;"

# Recent events in a channel
Invoke-SqliteQuery -DataSource $db -Query "SELECT event_type, user, text, ts FROM events WHERE channel='C0AGMF65DQB' ORDER BY ts DESC LIMIT 50;"

# All violations (dry-run)
Invoke-SqliteQuery -DataSource $db -Query "SELECT * FROM violations WHERE dry_run=1 ORDER BY created_at DESC;"

# Tail the JSONL log
Get-Content "C:\Users\azureuser\shared\scripts\taskflow\taskflow.jsonl" -Tail 20 | ForEach-Object { $_ | ConvertFrom-Json }
```

---

## Dry-Run Mode

When `dry_run: true`:

- **No Slack posts** are made (all `Send-TFSlackMessage` / `Send-TFWebhook` calls return a mock response)
- **No DB writes** happen in the collector (events are computed but not inserted)
- **All intended actions are logged** to `taskflow.jsonl` with `"dry_run": true`

This lets you observe what the system *would* do without touching Slack.

To go live:
1. Verify `taskflow.jsonl` looks correct
2. Set `"enabled": true, "dry_run": false` in config
3. Re-run

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Kill switch is OFF` error | Set `enabled: true` in config, or it's working as intended |
| `No Slack token` error | Run `$env:SLACK_BOT_TOKEN = "xoxb-..."` |
| `PSSQLite not found` | Run `Install-Module PSSQLite -Scope CurrentUser` |
| Duplicate events | Normal — `INSERT OR IGNORE` on `(ts, event_type)` handles it |
| Log file too large | Increase `max_file_size_mb` or archive manually; auto-rotation kicks in |

---

## Requirements

- PowerShell 5.1+
- PSSQLite module (`Install-Module PSSQLite` — already available on this VM)
- Slack Bot Token with scopes: `channels:history`, `reactions:read`, `chat:write` (for L2+)
