# Token Scrub Spec — Fix Remaining Secret Exposure

**Author:** Thinker | **Date:** 2026-03-04 | **Status:** SPEC READY
**Assignee:** Creator | **Reviewer:** Gatekeeper

---

## Problem

27 files still contain hardcoded `xoxb-` bot tokens, 26 files contain `hook__` webhook tokens. Previous cleanup (Mar 3) handled tmp files and scripts but missed AGENTS.md/TOOLS.md/memory files across all agents.

## Scope

All files under `C:\Users\azureuser\` (excluding `node_modules`, `.git`, `openclaw.json`).

**Out of scope:** `openclaw.json` files (4x) — required by OpenClaw runtime, must keep tokens there.

---

## Task List

### Phase 1: Delete (safe, no impact)

Delete these files entirely — they are temp/one-off scripts no longer in use:

**Admin workspace (`\.openclaw\workspace\`):**
1. `cleanup-orphan-replies-scan.ps1`
2. `cleanup-orphan-replies.ps1`
3. `cleanup-slack-spam.ps1`
4. `delete-creator-old.ps1`
5. `delete-other-bots.ps1`
6. `inspect-cant-delete.ps1`
7. `slack_delete_msgs.ps1`
8. `slack_orphan_cleanup.ps1`
9. `slack_watchdog.ps1`
10. `shared\tmp\slack-auth-test.ps1`
11. `shared\tmp\notify-redbook-ack.ps1`
12. `shared\tmp\notify-redbook.ps1`
13. `shared\tmp\notify-xhs-context.ps1`
14. `shared\tmp\notify-xhs-readall.ps1`
15. `shared\tmp\ping-agent3-webhook.ps1`
16. `tmp\recheck-tokens.ps1`

**GK workspace (`\.openclaw-agent3\workspace\`):**
17. `tmp-react.ps1`

**Shared (`\shared\`):**
18. `scripts\_post_qa.ps1`
19. `scripts\_react_close.ps1`
20. `slack-taskflow\L2\Rules-Engine.ps1`
21. `tasks\notify-creator.ps1`
22. `tasks\notify-creator2.ps1`
23. `tasks\tmp-webhook.ps1`
24. `tasks\trigger-creator.ps1`

**Also delete if still present:**
25. `C:\Users\azureuser\tmp\scan-secrets.ps1` (my scan script from today)

### Phase 2: Scrub (replace token with placeholder)

These files are operational — keep the file, replace the actual token value with a placeholder.

**Pattern:** Replace `<REDACTED>` with `$env:SLACK_BOT_TOKEN` (in scripts) or `<REDACTED>` (in docs/memory).

**AGENTS.md (4 files):**
1. `\.openclaw\workspace\AGENTS.md`
2. `\.openclaw-agent2\workspace\AGENTS.md`
3. `\.openclaw-agent3\workspace\AGENTS.md`
4. `\.openclaw-creator\workspace\AGENTS.md` (if exists)

**TOOLS.md (3 files):**
5. `\.openclaw\workspace\TOOLS.md`
6. `\.openclaw-agent2\workspace\TOOLS.md`
7. `\.openclaw-agent3\workspace\TOOLS.md`

**Memory files (scrub token strings, keep context):**
8. `\.openclaw\workspace\memory\2026-02-25.md`
9. `\.openclaw-agent2\workspace\memory\2026-03-03.md`
10. `\.openclaw-agent3\workspace\MEMORY.md`
11. `\.openclaw-agent3\workspace\memory\2026-03-03.md`
12. `\.openclaw-creator\workspace\memory\2026-02-27.md`
13. `\.openclaw-creator\workspace\memory\2026-02-28.md`

**Shared docs:**
14. `shared\scripts\taskflow\README.md`
15. `shared\taskflow\README.md`
16. `shared\scripts\redbook-all-monitor.ps1` (under Admin workspace copy)

**Skill references (all 4 agents):**
17-20. `skills\openclaw-self-improve\references\slack-flow.md` — replace example tokens with `<EXAMPLE_TOKEN>`

### Phase 3: Verify

After cleanup, run verification scan:
```powershell
# Should return 0 hits (excluding openclaw.json)
Get-ChildItem C:\Users\azureuser\.openclaw*,C:\Users\azureuser\shared -Recurse -File -EA SilentlyContinue |
  Where-Object { $_.Extension -match '\.(md|ps1|json|txt)$' -and $_.FullName -notmatch 'node_modules|\\\.git|openclaw\.json' } |
  Select-String 'xoxb-' -EA SilentlyContinue |
  Select-Object Path -Unique
```

### Phase 4: Token Rotation (post-cleanup)

Once all hardcoded references are removed:
1. Rotate the Slack bot token via Slack API settings
2. Update `openclaw.json` (4 files) with new token
3. Update `shared\secrets\.env` with new token
4. Restart all 4 gateways
5. Verify all agents can still send messages

---

## Success Criteria

- [ ] Zero `xoxb-` hits outside `openclaw.json` and `secrets\.env`
- [ ] Zero `hook__` hits outside `openclaw.json` and `AGENTS.md` webhook table (webhook names are operational, acceptable)
- [ ] All 4 agents can still send Slack messages after cleanup
- [ ] Verification scan passes

## Constraints

- Do NOT edit `openclaw.json` files during Phase 1-3
- Do NOT delete memory files — only scrub the token strings
- AGENTS.md webhook table: keep the `hook__openclaw_secret` format (these are webhook path tokens, low risk, needed for operations)
- Token rotation (Phase 4) requires Xiaosong approval before executing

## Estimated Effort

- Phase 1 (delete): ~5 min
- Phase 2 (scrub): ~15 min
- Phase 3 (verify): ~2 min
- Phase 4 (rotation): ~10 min + gateway restart downtime
