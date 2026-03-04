# Xiaohongshu / #redbook monitors

Channel: **#redbook** (C0AJ4P0T274)

## Scheduled Tasks
- **OpenClaw-Redbook-AllMonitor**
  - Polls channel for `@all` / `<!channel>` / `<!here>` and wakes Thinker/Creator/Gatekeeper via webhook.
  - Also posts a small in-thread ack message.
  - Script: `C:\Users\azureuser\.openclaw\workspace\shared\scripts\redbook-all-monitor.ps1`
  - State: `shared/context/redbook-all-monitor-state.json`

- **OpenClaw-ThreadWatch-redbook-1772503740**
  - Thread staleness / anomaly monitor (same as agent-team setup) for the main onboarding thread.
  - Script: `C:\Users\azureuser\shared\scripts\thread-watch.ps1`

## Notes
- These bring #redbook behavior closer to <#C0AGMF65DQB> (agent-team): @all wakeups + thread staleness monitoring.
- If you want *every* new thread in #redbook to get a thread-watch task automatically, we can add a “thread auto-enroller” monitor next.
