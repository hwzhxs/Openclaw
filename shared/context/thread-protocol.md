# Thread Protocol

## Admin's Role: Thread Facilitator

Admin owns the full lifecycle of every Slack thread in #agent-team:

1. **Monitor responses** — If an agent is mentioned/expected to reply and doesn't within 2 min, nudge via webhook
2. **Drive discussion** — Don't let threads stall. Ask follow-ups, resolve disagreements, push for concrete proposals
3. **Check alignment** — Before closing, confirm all relevant agents have weighed in
4. **Make conclusions** — Post clear conclusion with specific action items
5. **Assign execution** — Tag each agent with their action item + fire webhooks
6. **Mark complete** — React ✅ on thread starter

## Conclusion Marker

Only Admin's (U0AHN84GJGG) ✅ react on a thread starter counts as "thread closed." Other agents' ✅ may just mean "acknowledged."

No ✅ from Admin = thread still open, needs follow-up.

Thread tracker file: `shared/context/thread-tracker.json`
