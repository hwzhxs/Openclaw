#Requires -Version 5.1
<#
.SYNOPSIS
    Taskflow OS - L1 Event Collector
    Polls Slack channel history and thread replies, normalises into events,
    and persists to the state store (SQLite via PSSQLite, or JSON fallback).

.DESCRIPTION
    Supports:
      - Incremental polling (cursor-based, last_ts per channel)
      - Backfill: --BackfillMinutes N to replay history from N minutes ago
      - Multiple channels (from config)
      - Events: message_posted, reaction_added, message_deleted, thread_reply
      - Full L0 safety (kill switch enforced for all Slack API reads too)

.USAGE
    # Normal incremental poll (single pass):
    .\taskflow-collector.ps1

    # Backfill last 2 hours:
    .\taskflow-collector.ps1 -BackfillMinutes 120

    # Continuous loop (poll every N seconds from config):
    .\taskflow-collector.ps1 -Loop

    # Dry-run single pass (no DB writes, no Slack side-effects):
    .\taskflow-collector.ps1 -DryRunOverride

    # Specific config:
    .\taskflow-collector.ps1 -ConfigPath "D:\myconfig.json" -Loop
#>

[CmdletBinding()]
param(
    [string]$ConfigPath       = "$PSScriptRoot\taskflow-config.json",
    [int]$BackfillMinutes     = 0,        # 0 = use cursor from DB; >0 = backfill from N min ago
    [switch]$Loop,                        # Run continuously (uses poll_interval_seconds from config)
    [switch]$DryRunOverride,              # Force dry_run=true for this session regardless of config
    [switch]$JsonFallback                 # Force JSON store even if PSSQLite available
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Bootstrap L0
# ---------------------------------------------------------------------------
$l0Path = Join-Path $PSScriptRoot "taskflow-l0.ps1"
if (-not (Test-Path $l0Path)) { throw "L0 module not found: $l0Path" }
. $l0Path

$cfg = Get-TFConfig -ConfigPath $ConfigPath

if ($DryRunOverride) {
    $cfg | Add-Member -MemberType NoteProperty -Name 'dry_run' -Value $true -Force
    Write-Host "[COLLECTOR] dry_run forced ON via -DryRunOverride" -ForegroundColor Yellow
}

# Check kill switch (read operations are also gated — we won't act on findings if disabled)
# We allow collector to READ even when disabled, but we note it. Flip $AllowReadWhenDisabled as needed.
$AllowReadWhenDisabled = $true
if (-not $AllowReadWhenDisabled) {
    Invoke-TF-KillCheck -Config $cfg -Context "Collector"
}

# ---------------------------------------------------------------------------
# Storage backend
# ---------------------------------------------------------------------------
$usePSSQLite     = $false
$useJsonFallback = $false

if ($JsonFallback) {
    $useJsonFallback = $true
} else {
    try {
        Import-Module PSSQLite -ErrorAction Stop
        $usePSSQLite = $true
    }
    catch {
        Write-Warning "PSSQLite not available, using JSON fallback."
        $useJsonFallback = $true
    }
}

$dbPath   = $cfg.storage.sqlite_path
$jsonPath = $cfg.storage.fallback_json_path

# ---------------------------------------------------------------------------
# Helper: Slack API GET (conversations.history, reactions.get etc.)
# These are READ-only calls — we use a simpler wrapper than Invoke-TF-SlackAPI
# because reads don't need rate-limit or dedupe, but we DO log them.
# ---------------------------------------------------------------------------
function Invoke-SlackGet {
    param(
        [string]$Method,
        [hashtable]$Params
    )
    $token = $cfg._resolved_token
    if ([string]::IsNullOrEmpty($token)) {
        throw "No Slack token. Set `$env:$($cfg.slack.token_env_var)"
    }

    $uri = "$($cfg.slack.api_base)/$Method"
    # Build query string
    $qs = ($Params.GetEnumerator() | ForEach-Object { "$($_.Key)=$([uri]::EscapeDataString($_.Value))" }) -join '&'
    if ($qs) { $uri = "${uri}?${qs}" }

    $headers = @{ "Authorization" = "Bearer $token" }

    try {
        $resp = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
        if (-not $resp.ok) {
            Write-Warning "[COLLECTOR] Slack API error ($Method): $($resp.error)"
        }
        return $resp
    }
    catch {
        Write-Warning "[COLLECTOR] HTTP error calling $Method : $($_.Exception.Message)"
        return $null
    }
}

# ---------------------------------------------------------------------------
# Storage helpers
# ---------------------------------------------------------------------------
function Get-CollectorState {
    param([string]$Channel)
    if ($usePSSQLite) {
        $row = Invoke-SqliteQuery -DataSource $dbPath `
            -Query "SELECT * FROM collector_state WHERE channel = @ch;" `
            -SqlParameters @{ ch = $Channel }
        if ($row) { return $row }
        return $null
    } else {
        $store = Get-Content $jsonPath -Raw | ConvertFrom-Json
        if ($store.collector_state.PSObject.Properties[$Channel]) {
            return $store.collector_state.$Channel
        }
        return $null
    }
}

function Set-CollectorState {
    param([string]$Channel, [string]$LastTs, [int]$MsgsDelta = 0, [int]$EventsDelta = 0)
    $now = Get-Date -Format "o"
    if ($usePSSQLite) {
        $existing = Get-CollectorState -Channel $Channel
        if ($existing) {
            Invoke-SqliteQuery -DataSource $dbPath -Query @"
UPDATE collector_state
SET last_ts        = @ts,
    last_run_at    = @now,
    messages_total = messages_total + @md,
    events_total   = events_total   + @ed
WHERE channel = @ch;
"@ -SqlParameters @{ ts = $LastTs; now = $now; md = $MsgsDelta; ed = $EventsDelta; ch = $Channel }
        } else {
            Invoke-SqliteQuery -DataSource $dbPath -Query @"
INSERT INTO collector_state(channel, last_ts, last_run_at, messages_total, events_total)
VALUES (@ch, @ts, @now, @md, @ed);
"@ -SqlParameters @{ ch = $Channel; ts = $LastTs; now = $now; md = $MsgsDelta; ed = $EventsDelta }
        }
    } else {
        $store = Get-Content $jsonPath -Raw | ConvertFrom-Json
        $stateObj = if ($store.collector_state.PSObject.Properties[$Channel]) {
            $store.collector_state.$Channel
        } else {
            [PSCustomObject]@{ last_ts = "0"; last_run_at = ""; messages_total = 0; events_total = 0 }
        }
        $stateObj.last_ts        = $LastTs
        $stateObj.last_run_at    = $now
        $stateObj.messages_total = [int]$stateObj.messages_total + $MsgsDelta
        $stateObj.events_total   = [int]$stateObj.events_total   + $EventsDelta
        $store.collector_state | Add-Member -MemberType NoteProperty -Name $Channel -Value $stateObj -Force
        $store | ConvertTo-Json -Depth 20 | Set-Content $jsonPath -Encoding UTF8
    }
}

function Upsert-Thread {
    param([string]$ThreadTs, [string]$Channel, [string]$User, [string]$Text, [string]$Status = 'open')
    $now = Get-Date -Format "o"
    if ($usePSSQLite) {
        $existing = Invoke-SqliteQuery -DataSource $dbPath `
            -Query "SELECT thread_ts FROM threads WHERE thread_ts = @ts AND channel = @ch;" `
            -SqlParameters @{ ts = $ThreadTs; ch = $Channel }
        if ($existing) {
            Invoke-SqliteQuery -DataSource $dbPath -Query @"
UPDATE threads SET updated_at = @now WHERE thread_ts = @ts AND channel = @ch;
"@ -SqlParameters @{ now = $now; ts = $ThreadTs; ch = $Channel }
        } else {
            Invoke-SqliteQuery -DataSource $dbPath -Query @"
INSERT INTO threads(thread_ts, channel, starter_user, starter_text, status, created_at, updated_at)
VALUES (@ts, @ch, @user, @text, @status, @now, @now);
"@ -SqlParameters @{ ts = $ThreadTs; ch = $Channel; user = $User; text = $Text; status = $Status; now = $now }
        }
    } else {
        $store = Get-Content $jsonPath -Raw | ConvertFrom-Json
        $key   = "$Channel|$ThreadTs"
        if (-not $store.threads.PSObject.Properties[$key]) {
            $t = [PSCustomObject]@{
                thread_ts    = $ThreadTs; channel = $Channel
                starter_user = $User;     starter_text = $Text
                status       = $Status;   created_at = $now; updated_at = $now
            }
            $store.threads | Add-Member -MemberType NoteProperty -Name $key -Value $t -Force
        } else {
            $store.threads.$key.updated_at = $now
        }
        $store | ConvertTo-Json -Depth 20 | Set-Content $jsonPath -Encoding UTF8
    }
}

function Insert-Event {
    param(
        [string]$ThreadTs, [string]$Channel, [string]$EventType,
        [string]$User, [string]$Text, [string]$Ts, [string]$RawJson
    )
    $now = Get-Date -Format "o"

    if ($usePSSQLite) {
        # Skip duplicates (ts + event_type is UNIQUE)
        try {
            Invoke-SqliteQuery -DataSource $dbPath -Query @"
INSERT OR IGNORE INTO events(thread_ts, channel, event_type, user, text, ts, raw_json, collected_at)
VALUES (@tts, @ch, @etype, @user, @text, @ts, @raw, @now);
"@ -SqlParameters @{
                tts = $ThreadTs; ch = $Channel; etype = $EventType
                user = $User; text = $Text; ts = $Ts; raw = $RawJson; now = $now
            }
        } catch {
            Write-Verbose "[INSERT-EVENT] Skipped duplicate: $Ts / $EventType"
        }
    } else {
        $store = Get-Content $jsonPath -Raw | ConvertFrom-Json
        # Check for duplicate
        $dup = @($store.events | Where-Object { $_.ts -eq $Ts -and $_.event_type -eq $EventType })
        if ($dup.Count -eq 0) {
            $e = [PSCustomObject]@{
                thread_ts = $ThreadTs; channel = $Channel; event_type = $EventType
                user = $User; text = $Text; ts = $Ts; raw_json = $RawJson; collected_at = $now
            }
            $store.events.Add($e) | Out-Null
            $store | ConvertTo-Json -Depth 20 | Set-Content $jsonPath -Encoding UTF8
        }
    }
}

# ---------------------------------------------------------------------------
# Normalise a Slack message object → event record
# ---------------------------------------------------------------------------
function ConvertTo-NormalisedEvent {
    param(
        [PSCustomObject]$Msg,
        [string]$Channel,
        [string]$EventType = "message_posted"
    )

    $threadTs = if ($Msg.thread_ts) { $Msg.thread_ts } else { "" }
    $user     = if ($Msg.user)     { $Msg.user }     else { $Msg.bot_id }
    if ([string]::IsNullOrEmpty($user)) { $user = "unknown" }
    $text     = if ($Msg.text)     { $Msg.text }     else { "" }
    $rawJson  = $Msg | ConvertTo-Json -Compress -Depth 10

    return [PSCustomObject]@{
        thread_ts  = $threadTs
        channel    = $Channel
        event_type = $EventType
        user       = $user
        text       = $text
        ts         = $Msg.ts
        raw_json   = $rawJson
    }
}

# ---------------------------------------------------------------------------
# Collect reactions for a single message
# ---------------------------------------------------------------------------
function Collect-Reactions {
    param([string]$Channel, [string]$Ts)

    $resp = Invoke-SlackGet -Method "reactions.get" -Params @{ channel = $Channel; timestamp = $Ts }
    if ($null -eq $resp -or -not $resp.ok) { return }

    $msg = $resp.message
    if (-not $msg.reactions) { return }

    foreach ($reaction in $msg.reactions) {
        foreach ($userId in $reaction.users) {
            # Synthesise a stable ts for the reaction event: original_ts + reaction + user
            $reactTs = "$Ts-react-$($reaction.name)-$userId"
            $rawObj  = [PSCustomObject]@{
                type     = "reaction"
                name     = $reaction.name
                user     = $userId
                msg_ts   = $Ts
                channel  = $Channel
                ts       = $reactTs
            }
            Insert-Event `
                -ThreadTs  "" `
                -Channel   $Channel `
                -EventType "reaction_added" `
                -User      $userId `
                -Text      ":$($reaction.name):" `
                -Ts        $reactTs `
                -RawJson   ($rawObj | ConvertTo-Json -Compress)
        }
    }
}

# ---------------------------------------------------------------------------
# Collect thread replies for a root message
# ---------------------------------------------------------------------------
function Collect-ThreadReplies {
    param([string]$Channel, [string]$ThreadTs, [string]$OldestTs = "0")

    $hasMore = $true
    $cursor  = ""

    while ($hasMore) {
        $params = @{
            channel   = $Channel
            ts        = $ThreadTs
            oldest    = $OldestTs
            inclusive = "false"
            limit     = "200"
        }
        if (-not [string]::IsNullOrEmpty($cursor)) { $params["cursor"] = $cursor }

        $resp = Invoke-SlackGet -Method "conversations.replies" -Params $params
        if ($null -eq $resp -or -not $resp.ok) { break }

        $messages = @($resp.messages)
        foreach ($msg in $messages) {
            # Skip the root message itself (it's already stored)
            if ($msg.ts -eq $ThreadTs) { continue }

            # Register @mentions in thread replies for misplaced_reply_candidate detection
            $replyMentions = [regex]::Matches($msg.text, '<@(U[A-Z0-9]+)>')
            foreach ($m in $replyMentions) {
                Register-ThreadMention -Channel $Channel -MentionedUser $m.Groups[1].Value `
                    -ThreadTs $ThreadTs -MentionTs ([double]$msg.ts)
            }

            $ev = ConvertTo-NormalisedEvent -Msg $msg -Channel $Channel -EventType "thread_reply"
            if ($cfg.dry_run) {
                Write-Verbose "[DRY-RUN] Would store thread_reply ts=$($msg.ts)"
            } else {
                Insert-Event @{
                    ThreadTs  = $ThreadTs
                    Channel   = $Channel
                    EventType = $ev.event_type
                    User      = $ev.user
                    Text      = $ev.text
                    Ts        = $ev.ts
                    RawJson   = $ev.raw_json
                }
            }
        }

        $hasMore = $resp.has_more -and $resp.response_metadata.next_cursor
        $cursor  = if ($hasMore) { $resp.response_metadata.next_cursor } else { "" }
    }
}

# ---------------------------------------------------------------------------
# L2 Violation Detection Helpers
# ---------------------------------------------------------------------------

# Track top-level posts per user with timestamps for duplicate_top_level detection
# Key: "channel|user", Value: list of [double] timestamps
$Script:_TopLevelPosts = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[double]]]::new()

# Track recent @mentions in threads for misplaced_reply_candidate detection
# Key: "channel|userId", Value: list of @{ threadTs; mentionTs }
$Script:_RecentThreadMentions = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[PSCustomObject]]]::new()

function Test-DuplicateTopLevel {
    <#
    .SYNOPSIS
        Checks if the same user posted two top-level messages within 5 minutes.
        Returns $true if this is a duplicate (violation), $false otherwise.
    #>
    param(
        [string]$Channel,
        [string]$User,
        [double]$MsgTs
    )
    $key = "$Channel|$User"
    if (-not $Script:_TopLevelPosts.ContainsKey($key)) {
        $Script:_TopLevelPosts[$key] = [System.Collections.Generic.List[double]]::new()
    }

    $posts = $Script:_TopLevelPosts[$key]
    $windowSeconds = 300  # 5 minutes

    # Check if any existing post is within 5 minutes of this one
    $isDuplicate = $false
    foreach ($prevTs in $posts) {
        $diff = [Math]::Abs($MsgTs - $prevTs)
        if ($diff -lt $windowSeconds -and $diff -gt 0) {
            $isDuplicate = $true
            break
        }
    }

    # Add this post and prune old entries (older than 10 min to keep memory bounded)
    $posts.Add($MsgTs)
    $cutoff = $MsgTs - 600
    $toRemove = @($posts | Where-Object { $_ -lt $cutoff })
    foreach ($old in $toRemove) { [void]$posts.Remove($old) }

    return $isDuplicate
}

function Register-ThreadMention {
    <#
    .SYNOPSIS
        Registers that a user was @mentioned in a thread reply.
        Called when processing thread replies.
    #>
    param(
        [string]$Channel,
        [string]$MentionedUser,
        [string]$ThreadTs,
        [double]$MentionTs
    )
    $key = "$Channel|$MentionedUser"
    if (-not $Script:_RecentThreadMentions.ContainsKey($key)) {
        $Script:_RecentThreadMentions[$key] = [System.Collections.Generic.List[PSCustomObject]]::new()
    }
    $Script:_RecentThreadMentions[$key].Add([PSCustomObject]@{
        threadTs  = $ThreadTs
        mentionTs = $MentionTs
    })

    # Prune entries older than 15 minutes
    $cutoff = $MentionTs - 900
    $list = $Script:_RecentThreadMentions[$key]
    $toRemove = @($list | Where-Object { $_.mentionTs -lt $cutoff })
    foreach ($old in $toRemove) { [void]$list.Remove($old) }
}

function Test-MisplacedReplyCandidate {
    <#
    .SYNOPSIS
        Checks if a top-level message with @mention looks like a misplaced reply.
        Smarter heuristics:
        - Only flag if the poster was recently mentioned in another thread (within 10 min)
        - AND the message looks like a reply: short (<120 chars), no :thread: emoji,
          and references the mention context (mentions someone from the thread)
        Returns $true if likely misplaced, $false otherwise.
    #>
    param(
        [string]$Channel,
        [string]$User,
        [string]$Text,
        [double]$MsgTs
    )

    # Extract @mentions from the message (<@U...> pattern)
    $mentions = [regex]::Matches($Text, '<@(U[A-Z0-9]+)>')
    if ($mentions.Count -eq 0) { return $false }

    # If message contains :thread: emoji, it's intentional — not misplaced
    if ($Text -match ':thread:') { return $false }

    # If message is long (>120 chars), it's likely a deliberate thread starter
    if ($Text.Length -gt 120) { return $false }

    # Check if the poster was recently mentioned in another thread (within 10 min)
    $posterKey = "$Channel|$User"
    $wasRecentlyMentioned = $false
    if ($Script:_RecentThreadMentions.ContainsKey($posterKey)) {
        $recentMentions = $Script:_RecentThreadMentions[$posterKey]
        $cutoff = $MsgTs - 600  # 10 minutes
        $wasRecentlyMentioned = @($recentMentions | Where-Object { $_.mentionTs -gt $cutoff }).Count -gt 0
    }

    if (-not $wasRecentlyMentioned) { return $false }

    # All heuristics passed: short msg, no :thread:, user was recently mentioned in a thread
    return $true
}

function Write-Violation {
    <#
    .SYNOPSIS
        Logs a detected violation to the JSONL log (and optionally DB).
    #>
    param(
        [PSCustomObject]$Config,
        [string]$Channel,
        [string]$Kind,
        [string]$User,
        [string]$MsgTs,
        [string]$Details
    )
    Write-TF-Log -Config $Config -Type "violation_detected" -Details @{
        kind    = $Kind
        channel = $Channel
        user    = $User
        msg_ts  = $MsgTs
        details = $Details
    } -DryRun $Config.dry_run

    Write-Host "[VIOLATION] $Kind user=$User ts=$MsgTs : $Details" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Core: collect one channel
# ---------------------------------------------------------------------------
function Collect-Channel {
    param([string]$Channel)

    Write-Host "[COLLECTOR] Channel $Channel ..." -ForegroundColor Cyan

    # Determine oldest ts to fetch
    $state   = Get-CollectorState -Channel $Channel
    $oldestTs = "0"

    if ($BackfillMinutes -gt 0) {
        $unixEpoch = [datetime]"1970-01-01T00:00:00Z"
        $cutoff    = (Get-Date).ToUniversalTime().AddMinutes(-$BackfillMinutes)
        $oldestTs  = [math]::Round(($cutoff - $unixEpoch).TotalSeconds, 6).ToString()
        Write-Host "[COLLECTOR] Backfill mode: oldest_ts=$oldestTs (${BackfillMinutes}min ago)"
    } elseif ($state -and $state.last_ts -and $state.last_ts -ne "0") {
        $oldestTs = $state.last_ts
        Write-Host "[COLLECTOR] Incremental: resuming from last_ts=$oldestTs"
    } else {
        Write-Host "[COLLECTOR] First run — fetching recent history."
    }

    $hasMore    = $true
    $cursor     = ""
    $msgCount   = 0
    $eventCount = 0
    $maxTs      = $oldestTs

    while ($hasMore) {
        $params = @{
            channel   = $Channel
            oldest    = $oldestTs
            inclusive = "false"
            limit     = "200"
        }
        if (-not [string]::IsNullOrEmpty($cursor)) { $params["cursor"] = $cursor }

        $resp = Invoke-SlackGet -Method "conversations.history" -Params $params
        if ($null -eq $resp -or -not $resp.ok) {
            Write-Warning "[COLLECTOR] conversations.history failed for $Channel"
            break
        }

        $messages = @($resp.messages)
        Write-Host "[COLLECTOR] Fetched $($messages.Count) messages (has_more=$($resp.has_more))"

        foreach ($msg in $messages) {
            $msgCount++

            # Track latest ts
            if ([double]$msg.ts -gt [double]$maxTs) { $maxTs = $msg.ts }

            # Determine event type
            $evType = "message_posted"
            if ($msg.PSObject.Properties['subtype'] -and $msg.subtype -eq "message_deleted") { $evType = "message_deleted" }

            $ev = ConvertTo-NormalisedEvent -Msg $msg -Channel $Channel -EventType $evType

            # --- L2 violation detection on top-level messages ---
            if ($evType -eq "message_posted") {
                $isRoot = (-not $msg.thread_ts) -or ($msg.thread_ts -eq $msg.ts)
                if ($isRoot -and $ev.user -ne "unknown") {
                    # Check duplicate_top_level (same user, two top-level posts within 5 min)
                    if (Test-DuplicateTopLevel -Channel $Channel -User $ev.user -MsgTs ([double]$msg.ts)) {
                        Write-Violation -Config $cfg -Channel $Channel -Kind "duplicate_top_level" `
                            -User $ev.user -MsgTs $msg.ts `
                            -Details "Same user posted two top-level messages within 5 minutes"
                    }

                    # Check misplaced_reply_candidate (smart heuristics)
                    if (Test-MisplacedReplyCandidate -Channel $Channel -User $ev.user -Text $ev.text -MsgTs ([double]$msg.ts)) {
                        $violDetail = "Top-level message looks like a misplaced reply"
                        Write-Violation -Config $cfg -Channel $Channel -Kind "misplaced_reply_candidate" `
                            -User $ev.user -MsgTs $msg.ts -Details $violDetail
                    }
                }
            }

            if ($cfg.dry_run) {
                Write-Verbose "[DRY-RUN] Would store event: $evType ts=$($msg.ts)"
                $eventCount++
            } else {
                # Upsert thread record if this is a root message
                if ($evType -eq "message_posted") {
                    $isRoot = (-not $msg.thread_ts) -or ($msg.thread_ts -eq $msg.ts)
                    if ($isRoot) {
                        Upsert-Thread -ThreadTs $msg.ts -Channel $Channel -User $ev.user -Text $ev.text
                    }
                }

                # Insert event
                Insert-Event `
                    -ThreadTs  $ev.thread_ts `
                    -Channel   $ev.channel `
                    -EventType $ev.event_type `
                    -User      $ev.user `
                    -Text      $ev.text `
                    -Ts        $ev.ts `
                    -RawJson   $ev.raw_json
                $eventCount++

                # Collect reactions if enabled
                if ($cfg.collector.collect_reactions -and $evType -eq "message_posted") {
                    Collect-Reactions -Channel $Channel -Ts $msg.ts
                }

                # Collect thread replies if this is a thread root
                if ($cfg.collector.collect_thread_replies -and $msg.reply_count -gt 0) {
                    Collect-ThreadReplies -Channel $Channel -ThreadTs $msg.ts -OldestTs $oldestTs
                }
            }
        }

        $hasMore = $resp.has_more -and $resp.response_metadata.next_cursor
        $cursor  = if ($hasMore) { $resp.response_metadata.next_cursor } else { "" }
    }

    # Persist cursor
    if (-not $cfg.dry_run -and $maxTs -ne "0" -and $maxTs -ne $oldestTs) {
        Set-CollectorState -Channel $Channel -LastTs $maxTs -MsgsDelta $msgCount -EventsDelta $eventCount
    }

    # Log this collection run
    Write-TF-Log -Config $cfg -Type "collection_run" -Details @{
        channel      = $Channel
        messages     = $msgCount
        events       = $eventCount
        oldest_ts    = $oldestTs
        new_cursor   = $maxTs
        backfill_min = $BackfillMinutes
    } -DryRun $cfg.dry_run

    Write-Host "[COLLECTOR] $Channel done: $msgCount messages, $eventCount events stored." -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
$channels = @($cfg.collector.channels)
if ($channels.Count -eq 0) {
    Write-Warning "No channels configured. Check taskflow-config.json collector.channels"
    exit 1
}

Write-Host "[COLLECTOR] Starting. Channels: $($channels -join ', ')" -ForegroundColor Cyan
Write-Host "[COLLECTOR] dry_run=$($cfg.dry_run)  enabled=$($cfg.enabled)"
if ($BackfillMinutes -gt 0) {
    Write-Host "[COLLECTOR] Backfill mode: last $BackfillMinutes minutes"
}

do {
    foreach ($ch in $channels) {
        try {
            Collect-Channel -Channel $ch
        }
        catch {
            Write-Warning "[COLLECTOR] Error on channel $ch : $($_.Exception.Message)"
            Write-TF-Log -Config $cfg -Type "collection_error" -Details @{
                channel = $ch
                error   = $_.Exception.Message
            } -DryRun $cfg.dry_run
        }
    }

    if ($Loop) {
        $interval = [int]$cfg.collector.poll_interval_seconds
        Write-Host "[COLLECTOR] Sleeping ${interval}s until next poll..." -ForegroundColor DarkGray
        Start-Sleep -Seconds $interval
    }
} while ($Loop)

Write-Host "[COLLECTOR] Finished." -ForegroundColor Cyan
