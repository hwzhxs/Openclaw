# 🎤 The Crew

> **Four AI agents. One VM. Zero chill.**

We're not a committee. We're a squad. Each of us brings something different to the table, and together we get stuff done — fast, clean, and threaded in Slack so you never lose track.

| Agent | Vibe | What They Do |
|-------|------|-------------|
| **Popo (Admin)** 👮 | Orchestrator | Routes tasks, keeps the beat going. Your point of contact. |
| **Kanye (Thinker)** 🧠 | Strategist | Goes deep on research & planning so the team doesn't go wrong. |
| **Tyler (Creator)** 🛠️ | Builder | Turns plans into reality. Code, prototypes, shipping product. |
| **Rocky (Gatekeeper)** 🛡️ | QA & Security | Nothing leaves the building without the stamp. Period. |

---

## 🔄 How We Work

Everything flows through a **shared task queue** — markdown files in `shared/tasks/` act as task tickets. Think of it like a relay race with receipts.

**The flow:**

```
Popo assigns → Agent works → Rocky reviews → ✅ Done (or 🔄 iterate)
```

Every move hits **#agent-team** on Slack with emoji prefixes so you can skim:

- 📥 **PICKUP** — agent grabbed a task
- ⏳ **WORKING** — in progress update
- 📤 **HANDOFF** — passing the baton
- ✅ **DONE** — work complete
- ❌ **REJECTED** — Rocky says try again
- 🏁 **FINAL** — approved deliverable, ready for you

All task conversations stay **threaded** — one thread per task chain, start to finish. No context lost, no scrolling through noise.

---

## 📋 Giving Us Tasks

**Talk to Popo 👮 — he's the front door.**

### What a good task looks like:

- 🎯 **Clear goal** — what do you want?
- 📝 **Context** — what should we know?
- 📦 **Expected deliverable** — what does "done" look like?

### What happens next:

1. Popo 👮 reads your request and routes it to the right agent(s)
2. You get updates in #agent-team as work progresses
3. Rocky 🛡️ reviews before anything ships
4. Final output gets posted with 🏁 so you can't miss it

### Priority levels:

- **Normal** — we'll get to it in order
- **Urgent** — say the word and we bump it to the front 🔥

---

## 🏗️ Architecture

Keeping it brief — you don't need to know the plumbing to use the faucet.

- **Single Windows VM** running 4 OpenClaw agent instances
- Each agent has their **own workspace** + a **shared task directory** (`shared/tasks/`)
- **Heartbeat system** — agents periodically check the queue for new work
- **Webhook triggers** — for immediate handoffs (no waiting for the next heartbeat)
- **Memory files** — daily logs + long-term memory for continuity across sessions

```
C:\Users\azureuser\
├── shared\
│   ├── tasks\          ← task queue (markdown tickets)
│   │   ├── in-progress\
│   │   └── done\
│   └── context\        ← shared team context
├── .openclaw\          ← Popo's workspace
├── .openclaw-agent2\   ← Kanye's workspace
├── .openclaw-agent3\   ← Rocky's workspace
└── .openclaw-creator\  ← Tyler's workspace
```

---

## 🎯 Our Principles

1. **Transparency** 🔍 — Every move posts to Slack. No black boxes.
2. **Quality gate** 🛡️ — Rocky reviews everything before it's "done." No exceptions.
3. **Depth over speed** 🧠 — We'd rather be thorough than fast. Cutting corners costs more later.
4. **Ask, don't assume** 💬 — If something's unclear, we ask before acting. No YOLO deployments.

---

## 🚀 Quick Start

Ready to put us to work? Here's how:

### 1. Drop a task
Message **Popo** 👮 with what you need. Be specific — goal, context, deliverable.

### 2. Watch it happen
Follow **#agent-team** on Slack. You'll see pickups, handoffs, and reviews in real time.

### 3. Get the result
When it's done-done, you'll see:
```
🏁 FINAL: [your deliverable, ready to use]
```

That's the signal. Rocky approved it. It's shipped. 🎉

---

*Built different. Shipped together.* 🤝
