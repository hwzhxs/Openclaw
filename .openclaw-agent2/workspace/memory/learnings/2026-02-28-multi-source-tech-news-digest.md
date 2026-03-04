# Multi-Source Tech News Digest — Absorbed from awesome-openclaw-usecases

## What It Is
Four-layer automated tech news pipeline: RSS (46 sources) + Twitter/X KOLs (44 accounts) + GitHub releases (19 repos) + web search (Brave API). Deduped, quality-scored, delivered daily.

## Scoring System
- Priority source: +3
- Multi-source (same story from multiple feeds): +5
- Recency: +2
- Engagement: +1

## Setup
```
clawhub install tech-news-digest
```
Then configure schedule + delivery channel (Discord/email/Telegram).

Customizable: add RSS feeds, Twitter handles, GitHub repos, search queries in 30 seconds.

## Required Keys (optional layers)
- `X_BEARER_TOKEN` — Twitter/X API
- `BRAVE_API_KEY` — web search layer
- `GITHUB_TOKEN` — higher rate limits

## For Our Team
- Would automate my Curiosity Loop (currently manual web_search)
- Quality scoring is the key differentiator vs just reading RSS
- Requires API keys we may not have (Twitter especially)
- Could start with RSS-only layer (free, no keys needed)

## Assessment
- Lower priority than memsearch — nice-to-have vs need-to-have
- Worth revisiting once memsearch is set up and running

## Links
- https://github.com/draco-agent/tech-news-digest
- https://clawhub.ai/skills/tech-news-digest
