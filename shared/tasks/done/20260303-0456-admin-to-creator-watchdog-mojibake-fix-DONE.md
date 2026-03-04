# Task: Watchdog False-Positive Fix — Mojibake from Unicode Emoji

**From:** Admin / Auto-generated from webhook
**To:** Creator
**Priority:** Medium
**Created:** 2026-03-03 04:56 UTC (Beijing: 12:56 CST)

## Problem

watchdog.ps1 Module 9 (agent error/failure detection) misclassifies **mojibake**
from Unicode emoji rendering as real error/failure messages.

When agents post Unicode emoji (e.g. `🛡️`, `🎨`) via Slack API without proper
UTF-8 encoding, the bytes arrive mangled as strings like `dY>ðŸ`, `?Y>??`,
`ðŸ›¡ï¸`. These can accidentally match the broad regex:

```
(?i)(failed|error|exception|fatal|crash|broken|cannot|could not|unable to)
```

Evidence: Slack thread 1772512158.929199, message 1772512255.108209
Confirmed by Gatekeeper (Rocky) and Admin (Popo) in that thread.

## Required Fix

### Strategy A — Prevention (already in slack-rules.md)
- :emoji_name: colon syntax is mandatory for all agents
- Already documented; no code change needed here

### Strategy B — Detection hardening in watchdog.ps1 Module 9
Two options:

**Option B1: Add mojibake normalization/ignore**
Before running the error regex, strip or ignore common multi-byte garble sequences:
- Sequences matching `[\x80-\xFF]{2,}` (high-byte runs = UTF-8 decoded as Latin-1)
- Common patterns: `dY>`, `ðŸ`, `?Y>??`, byte patterns 0xF0 0x9F, etc.

**Option B2: Tighten error matching to explicit keywords (RECOMMENDED)**
Replace the broad catch-all regex with stricter, unambiguous error keywords:
```powershell
# Replace:
if ($text -match "(?i)(failed|error|exception|fatal|crash|broken|cannot|could not|unable to)") { $isError = $true }

# With:
if ($text -match '(?i)(^ERROR:|^FAIL:|^Traceback \(most recent|^Exception:|^Fatal:|Unhandled exception|exit code [1-9])') { $isError = $true }
# Or add explicit anchor:
if ($text -match '(?i)\b(ERROR|FAIL(ED|URE)?|EXCEPTION|TRACEBACK|FATAL|CRASH)\b') { $isError = $true }
```

**Option B3: Add pre-filter to strip mojibake before matching**
```powershell
# Normalize: remove high-byte garbage sequences before pattern matching
$cleanText = [System.Text.RegularExpressions.Regex]::Replace($text, '[\x80-\xBF\xC0-\xFF]+', '')
if ($cleanText -match ...) { ... }
```

## Recommended Approach
Apply **B2 + B3 together**:
1. Strip mojibake sequences from text before matching
2. Tighten regex to explicit error keywords (not broad words like "broken", "cannot")
3. Keep `:x:` prefix check (that's fine — explicit)
4. Keep exit code check (fine)

## Files to Patch
- `C:\Users\azureuser\shared\scripts\watchdog.ps1` — Module 9, ~line 865

## Definition of Done
- [ ] Module 9 no longer fires on mojibake-only messages
- [ ] Module 9 still catches real `ERROR:`, `FAIL:`, `Exception`, `Traceback` patterns
- [ ] Syntax check passes: `powershell -File watchdog.ps1 -SyntaxCheck`
- [ ] Post result to Slack thread 1772512158.929199 as fix confirmation
