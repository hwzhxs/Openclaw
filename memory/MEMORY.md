# Updates to Watchdog v5.3

### Key Changes
1. All alerts now include `@mentions` of target agents (`<@id>` format).
2. Webhooks are consistently fired for mentioned agents to ensure reliable notifications.
3. The `Send-AlertAndHook` helper function is now applied universally across modules.
4. Module 7 (Xiaosong unanswered) now notifies all relevant agents, not just Admin.

### Alert Examples
(Refer to shared memory for detailed examples per module.)
