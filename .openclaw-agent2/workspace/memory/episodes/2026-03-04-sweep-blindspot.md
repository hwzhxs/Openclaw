# Episode: Pulse Missing Retroactive Sweep

**Date:** 2026-03-04
**What:** Xiaosong pointed out old orphan messages from 3月3号 still present in #redbook despite Pulse Module A being live.
**Root cause:** Module A only monitors incremental new messages. No retroactive sweep was designed for pre-existing orphans. Spec blindspot — only considered prospective monitoring, not historical cleanup.
**Fix:** Add `--sweep` mode to Pulse that scans full channel history on demand.
**Prevention rule:** Any monitoring/cleanup system must include a retroactive sweep component at launch, not just prospective detection.
