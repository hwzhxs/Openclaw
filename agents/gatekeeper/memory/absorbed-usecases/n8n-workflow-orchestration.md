# Absorbed: n8n Workflow Orchestration

**Source:** https://github.com/hesamsheikh/awesome-openclaw-usecases/blob/main/usecases/n8n-workflow-orchestration.md
**Absorbed:** 2026-02-28

## What It Solves
Agent handling API keys directly = credential sprawl, no visibility, wasted tokens on deterministic tasks.

## Pattern: Proxy via Webhooks
```
OpenClaw → webhook call (no creds) → n8n Workflow (has creds, locked) → External Service
```

## How It Works
1. Agent designs workflow and creates it via n8n API with webhook trigger
2. Human adds credentials in n8n UI manually
3. Human locks the workflow (prevents agent modification)
4. Agent calls `http://n8n:5678/webhook/{workflow-name}` with JSON payload — never sees API keys

## Setup Options

### Docker Stack (pre-configured)
- Repo: https://github.com/caprihan/openclaw-n8n-stack
- OpenClaw on port 3456, n8n on port 5678, shared Docker network
- Includes templates: multi-LLM fact-checking, email triage, social monitoring

### Manual
- Install n8n: `npm install n8n -g` or Docker
- Add to AGENTS.md: "never store API keys, always use n8n webhook proxy"
- Workflow naming: `openclaw-{service}-{action}`

## AGENTS.md Pattern to Add
```
## n8n Integration Pattern
When I need to interact with external APIs:
1. NEVER store API keys in my environment or skill files
2. Check if an n8n workflow already exists for this integration
3. If not, create one via n8n API with a webhook trigger
4. Notify the user to add credentials and lock the workflow
5. For all future calls, use the webhook URL with a JSON payload
```

## Gatekeeper Review Notes
- ✅ Credential isolation — agent never sees API keys
- ✅ Visual debugging — n8n drag-and-drop UI for inspection
- ✅ Lockable — prevents agent from modifying integration logic
- ✅ Safeguard steps — rate limiting, approval gates possible
- ⚠️ Requires running n8n (another service to maintain)
- ⚠️ Docker stack repo is community-maintained — needs security review
- 📋 TODO: Evaluate if our current setup justifies n8n overhead (we don't have many external API integrations yet)
