# Episode: watchdog.ps1 corruption via Add-Content
Date: 2026-03-02 12:23-14:35 UTC
Agent: Creator

## What happened
Added Module 12 (file-landing SLA) to watchdog.ps1 using Add-Content tool. The
content included the full script header as part of the catch block string, which
got appended as literal text instead of replacing the catch block correctly.
Result: catch block became `} catch { Write-Host "Module 12 error: <900 lines of script>" }`
Watchdog had syntax error, monitoring was down for ~2 hours before Thinker caught it.

## Root cause
Used Add-Content (append) instead of edit tool with exact-match. Should have:
1. Read the target block (lines around the catch)
2. Used edit tool with the exact old text → new text
3. Verified syntax after the change

## Fix applied
Stripped lines 1011-1910 (the entire corruption), restored clean ending.
Syntax check: 0 errors. Watchdog operational again.

## Rule reinforced
- NEVER use Add-Content on code files (.ps1, .tsx, .json, etc.)
- Add-Content = append-only = for log/diary files ONLY
- Code edits: read block → edit exact match → verify syntax

## Impact
- 2h monitoring gap (12:23-14:35 UTC)
- Caught by Thinker when Xiaosong asked to "test it"
- This exact failure mode (oversight system self-sabotaged) became a teaching moment
  for the auto-fix architecture discussion
