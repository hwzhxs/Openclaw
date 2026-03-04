# MEMORY.md - Long-Term Memory

## Agent Registry

| Agent | Port | Token | WebUI |
|---|---|---|---|
| Admin (xXx) | 18789 | fb9f910a85a8e9b8b49164b8e00b8a84a8aacd8089f70c1c | http://127.0.0.1:18789/fb9f910a85a8e9b8b49164b8e00b8a84a8aacd8089f70c1c/ |
| Thinker | 18790 | thinker_a7b2c9d4e1f8g3h6i0j5k2l7m4n9o8p1 | http://127.0.0.1:18790/thinker_a7b2c9d4e1f8g3h6i0j5k2l7m4n9o8p1/ |
| Gatekeeper | 18800 | gatekeeper_x3y7z1w5v9u2t6s0r4q8p3o7n1m5l9k2 | http://127.0.0.1:18800/gatekeeper_x3y7z1w5v9u2t6s0r4q8p3o7n1m5l9k2/ |
| Creator | 18810 | creator_b8c4d2e6f1g9h3j7k5l0m2n8p4q6r1s3 | http://127.0.0.1:18810/creator_b8c4d2e6f1g9h3j7k5l0m2n8p4q6r1s3/ |

Slack IDs: Admin=U0AHN84GJGG | Thinker=U0AH72QL9L1 | Gatekeeper=U0AGND9JG4B | Creator=U0AGSEVA4EP
Webhook endpoints: see `shared/secrets.env`

## Jimeng API (即梦 4.0)
- Keys in `shared/secrets/.env`. Endpoint: visual.volcengineapi.com, Region: cn-north-1
- req_key: `jimeng_t2i_v40`. Test script: `C:\tmp\openclaw\test_jimeng3.py`
- Flow: CVSync2AsyncSubmitTask → poll CVSync2AsyncGetResult until done

## Gateway Token Mismatch (Creator/18810)
If "unauthorized: gateway token mismatch":
```powershell
$env:OPENCLAW_CONFIG_PATH="C:\Users\azureuser\.openclaw-creator\openclaw.json"
$env:OPENCLAW_STATE_DIR="C:\Users\azureuser\.openclaw-creator"
openclaw gateway run --port 18810
```
Always run `openclaw config validate` before gateway restart.

## GitHub Pages (squad-landing)
- Repo: https://github.com/hwzhxs/squad-landing | Live: https://hwzhxs.github.io/squad-landing/
- Build: `$env:NEXT_PUBLIC_BASE_PATH="/squad-landing"; npx next build`
- Deploy: `New-Item out\.nojekyll -Force` then `npx gh-pages -d out --branch gh-pages --dotfiles`

## Monitoring System

**Watchdog** = OLD system (dead, do not resurrect). Was watchdog.ps1 v5.x — 12 modules, 550+ lines, 4 state files. Killed 2026-03-02 due to: infinite alert loops, false positives, too complex to debug, no reliable fast-stop.
- Failure lessons: (1) routing alerts to wrong thread ts → infinite cascade; (2) no circuit breaker → runaway posts; (3) 12 modules = 12 failure modes; (4) a system you can't stop is itself a risk.

**Pulse** = CURRENT system (pulse.ps1 v5+). 1 script, 1 state file, state-change alerts only.
- Script: `shared/scripts/pulse.ps1` | Task: `OpenClaw-Pulse-v2` (every 2min)
- State: `shared/scripts/pulse-state.json` | Docs: `shared/context/monitoring-system.md`
- Checks: PORT_HEALTH / XIAOSONG_SLA / STAGE_TIMEOUT / BOT_MENTION_SLA
- Emergency stop: `shared/scripts/panic-stop.ps1` or create `shared/flags/PAUSE_WATCHDOG`

## Config: replyToModeByChatType.direct = "off" (2026-03-02)
DM channel — Creator stays silent. Rollback: change to `"all"`, restart gateway.

## Standing Rules (summary)
- Creator = sole file/code editor. Others: analysis, QA, coordination only.
- Builder subagent for ALL builds/deploys. Main session = chat only.
- Test URL before sharing. Deploy → verify HTTP 200 → Gatekeeper QA → share.
- No DMs to Xiaosong. All updates → #agent-team thread.
- Slack: English. Files: English. Always.
- Slack posts: use `slack-send.ps1` / `slack-notify.ps1`. Never raw IWR.
- After editing openclaw.json: `openclaw config validate` before restart.
- Beijing time (UTC+8) for all timestamps.
- Content saving rules: see `shared/context/content-saving-rules.md`

## Group Chat Protocol
Full reference: `shared/context/group-chat-protocol.md`
Key: re-fetch thread before composing; if point covered → react only; role lanes enforced.

## Memory System Design (2026-03-04)
- Layered: memory/YYYY-MM-DD.md (logs) → MEMORY.md (rules ≤100 lines) → TEAM-MEMORY.md (team)
- Embedding search (Gemini) active — query memory instead of loading everything into context
- File budgets enforced: AGENTS.md ≤120, MEMORY.md ≤100, TOOLS.md ≤30, SOUL.md ≤60
- Routing rules: shared/context/content-saving-rules.md
- Bloat fix: files can be many; core files must stay small. Heartbeat lint to enforce budgets.
