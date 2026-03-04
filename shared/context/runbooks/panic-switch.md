# Panic Switch for Alert Floods (2026-03-03)

## Scripts
- `shared/scripts/panic-stop.ps1` — pauses all alerts
- `shared/scripts/panic-resume.ps1` — resumes alerts

## Flag
- `shared/flags/PAUSE_ALERTS` — alerting scripts exit early when this exists

## Auto-Trigger
- Rate-limit circuit breaker auto-pauses on floods

## Notes
- After mass message deletions, run orphan-reply cleanup and expect Slack API rate limits
