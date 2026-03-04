# pulse.ps1 - Canonical monitoring entry point (PS5 compatible)
# Runs every 2 minutes via OpenClaw-Pulse-v2 scheduled task
# Owner: Creator | Changes require GK review + dry-run
# Rules: all output goes to LOG_THREAD only; no top-level posts

param([switch]$SyntaxCheck, [switch]$DryRun)
if ($SyntaxCheck) { Write-Host 'Syntax OK'; return }

# --- Config ------------------------------------------------------------------
. "$PSScriptRoot\load-secrets.ps1"
$TOKEN      = $env:SLACK_BOT_TOKEN
$CHANNEL    = 'C0AGMF65DQB'
$LOG_CHANNEL = 'C0AGMF65DQB'  # Post() always writes here, never to other channels
$CHANNELS   = @('C0AGMF65DQB', 'C0AJ4P0T274')  # agent-team + redbook
$XIAOSONG   = 'U0AGRQDAL94'
$STATE_FILE = 'C:\Users\azureuser\shared\scripts\pulse-state.json'
$LOG_THREAD = '1772504735.586059'   # fixed log thread, never post top-level

# Kill switch: exit immediately if pause flag is present
if (Test-Path 'C:\Users\azureuser\shared\flags\PAUSE_WATCHDOG') { exit 0 }

$PORTS = @{ '18789'='Admin'; '18790'='Thinker'; '18800'='Gatekeeper'; '18810'='Creator' }

# Agent webhook config
$AGENT_WEBHOOKS = @(
    @{ url='http://127.0.0.1:18789/hooks/agent'; token=$env:OPENCLAW_WEBHOOK_ADMIN }
    @{ url='http://127.0.0.1:18790/hooks/agent'; token=$env:OPENCLAW_WEBHOOK_THINKER }
    @{ url='http://127.0.0.1:18800/hooks/agent'; token=$env:OPENCLAW_WEBHOOK_GATEKEEPER }
    @{ url='http://127.0.0.1:18810/hooks/agent'; token=$env:OPENCLAW_WEBHOOK_CREATOR }
)

$BOT_USER_IDS = @('U0AHN84GJGG', 'U0AH72QL9L1', 'U0AGND9JG4B', 'U0AGSEVA4EP')
$BOT_NAMES = @{
    'U0AHN84GJGG' = 'Admin'
    'U0AH72QL9L1' = 'Thinker'
    'U0AGND9JG4B' = 'Gatekeeper'
    'U0AGSEVA4EP' = 'Creator'
}

# Option A: bot tokens for direct chat.delete (loaded after load-secrets.ps1)
function Get-BotTokens {
    @{
        'U0AHN84GJGG' = $env:SLACK_BOT_TOKEN_ADMIN
        'U0AH72QL9L1' = $env:SLACK_BOT_TOKEN_THINKER
        'U0AGND9JG4B' = $env:SLACK_BOT_TOKEN_GATEKEEPER
        'U0AGSEVA4EP' = $env:SLACK_BOT_TOKEN_CREATOR
    }
}

# Module C live flag — set to $false for DryRun-first validation
$script:unicodeEmojiLive = $false

# Rate limit: max 10 Slack posts per run
$script:postCount = 0
$MAX_POSTS = 10

# --- Helpers -----------------------------------------------------------------
function From-UnixTime($unix) {
    [datetime]'1970-01-01 00:00:00' + [timespan]::FromSeconds([double]$unix)
}

function ConvertTo-Hashtable($obj) {
    if ($obj -is [System.Management.Automation.PSCustomObject]) {
        $ht = @{}
        foreach ($p in $obj.PSObject.Properties) { $ht[$p.Name] = ConvertTo-Hashtable $p.Value }
        return $ht
    } elseif ($obj -is [object[]]) {
        return @($obj | ForEach-Object { ConvertTo-Hashtable $_ })
    }
    return $obj
}

function Load-State {
    $default = @{
        lastRun      = ''
        ports        = @{}
        xiaosongSLA  = @{ alertedIds = @() }
        stageNudge   = @{ nudged = @{}; escalated = @{} }
        orphanCleanup = @{ knownThreads = @{}; cleanedThreads = @{} }
        selfMention  = @{ alertedMessageIds = @{} }
        unicodeEmoji = @{ alertedMessageIds = @{} }
        botMentionSLA = @{ alertedMessageIds = @{} }
    }
    foreach ($p in $PORTS.Keys) {
        $default.ports[$p] = @{ status='UP'; since=(Get-Date -Format o); alerted=$false }
    }
    if (-not (Test-Path $STATE_FILE)) { return $default }
    try {
        $raw = ConvertTo-Hashtable (Get-Content -Raw $STATE_FILE | ConvertFrom-Json)
        foreach ($p in $PORTS.Keys) {
            if (-not $raw.ports.ContainsKey($p)) {
                $raw.ports[$p] = @{ status='UP'; since=(Get-Date -Format o); alerted=$false }
            }
        }
        if (-not $raw.ContainsKey('xiaosongSLA'))   { $raw['xiaosongSLA']   = @{ alertedIds = @() } }
        if (-not $raw.ContainsKey('stageNudge'))    { $raw['stageNudge']    = @{ nudged = @{}; escalated = @{} } }
        if (-not $raw.ContainsKey('orphanCleanup')) { $raw['orphanCleanup'] = @{ knownThreads = @{}; cleanedThreads = @{} } }
        if (-not $raw.ContainsKey('selfMention'))   { $raw['selfMention']   = @{ alertedMessageIds = @{} } }
        if (-not $raw.ContainsKey('unicodeEmoji'))  { $raw['unicodeEmoji']  = @{ alertedMessageIds = @{} } }
        if (-not $raw.ContainsKey('botMentionSLA')) { $raw['botMentionSLA'] = @{ alertedMessageIds = @{} } }
        # Ensure sub-keys exist
        if (-not $raw.orphanCleanup.ContainsKey('knownThreads'))  { $raw.orphanCleanup['knownThreads']  = @{} }
        if (-not $raw.orphanCleanup.ContainsKey('cleanedThreads')){ $raw.orphanCleanup['cleanedThreads'] = @{} }
        if (-not $raw.selfMention.ContainsKey('alertedMessageIds'))  { $raw.selfMention['alertedMessageIds']  = @{} }
        if (-not $raw.unicodeEmoji.ContainsKey('alertedMessageIds')) { $raw.unicodeEmoji['alertedMessageIds'] = @{} }
        if (-not $raw.botMentionSLA.ContainsKey('alertedMessageIds')) { $raw.botMentionSLA['alertedMessageIds'] = @{} }
        return $raw
    } catch {
        Remove-Item $STATE_FILE -Force -ErrorAction SilentlyContinue
        return $default
    }
}

function Save-State($state) {
    $state['lastRun'] = (Get-Date -Format o)
    $tmp = "$STATE_FILE.tmp"
    $state | ConvertTo-Json -Depth 10 | Set-Content -Path $tmp -Encoding UTF8
    Move-Item -Path $tmp -Destination $STATE_FILE -Force
}

function Post($text, $threadTs = $LOG_THREAD) {
    if ($script:postCount -ge $MAX_POSTS) { return }  # circuit breaker
    $script:postCount++
    if ($DryRun) { Write-Host "[DRY-RUN] -> $threadTs : $text"; return }
    try {
        $body = @{ channel=$LOG_CHANNEL; text=$text; thread_ts=$threadTs } | ConvertTo-Json -Compress
        Invoke-RestMethod 'https://slack.com/api/chat.postMessage' -Method POST `
            -Headers @{ Authorization="Bearer $TOKEN" } `
            -ContentType 'application/json; charset=utf-8' -Body $body | Out-Null
    } catch { Write-Warning "Post failed: $_" }
}

# Top-level posts: ONLY for port/gateway DOWN events (per Xiaosong rule 2026-03-04)
function PostTopLevel($text) {
    if ($script:postCount -ge $MAX_POSTS) { return }
    $script:postCount++
    if ($DryRun) { Write-Host "[DRY-RUN TOP-LEVEL] $text"; return }
    try {
        $body = @{ channel=$LOG_CHANNEL; text=$text } | ConvertTo-Json -Compress
        Invoke-RestMethod 'https://slack.com/api/chat.postMessage' -Method POST `
            -Headers @{ Authorization="Bearer $TOKEN" } `
            -ContentType 'application/json; charset=utf-8' -Body $body | Out-Null
    } catch { Write-Warning "PostTopLevel failed: $_" }
}

function Get($method, $params) {
    $qs = ($params.GetEnumerator() | ForEach-Object { "$($_.Key)=$([Uri]::EscapeDataString($_.Value))" }) -join '&'
    try { Invoke-RestMethod "https://slack.com/api/${method}?${qs}" -Headers @{ Authorization="Bearer $TOKEN" } }
    catch { $null }
}

# --- Check 1: PORT_HEALTH ----------------------------------------------------
function Check-Ports($state) {
    foreach ($port in $PORTS.Keys) {
        $name = $PORTS[$port]
        $ps   = $state.ports[$port]
        $isUp = Test-NetConnection -ComputerName localhost -Port ([int]$port) `
                    -InformationLevel Quiet -WarningAction SilentlyContinue 2>$null
        $new = if ($isUp) { 'UP' } else { 'DOWN' }

        if ($new -ne $ps['status']) {
            $ps['status'] = $new; $ps['since'] = (Get-Date -Format o); $ps['alerted'] = $false
        }
        if ($new -eq 'DOWN' -and -not $ps['alerted']) {
            PostTopLevel ":red_circle: PULSE: $name (port $port) DOWN since $($ps['since'])"
            $ps['alerted'] = $true
        } elseif ($new -eq 'UP' -and $ps['alerted']) {
            PostTopLevel ":large_green_circle: PULSE: $name (port $port) recovered"
            $ps['alerted'] = $false
        }
        $state.ports[$port] = $ps
    }
}

# --- Check 2: XIAOSONG_UNANSWERED (>5min, no bot reply) ---------------------
function Check-XiaosongSLA($state) {
    $resp = Get 'conversations.history' @{ channel=$CHANNEL; limit='20' }
    if (-not $resp -or -not $resp.ok) { return }

    $now     = (Get-Date).ToUniversalTime()
    $alerted = [System.Collections.Generic.List[string]]::new()
    if ($state.xiaosongSLA['alertedIds']) { foreach ($id in @($state.xiaosongSLA['alertedIds'])) { $alerted.Add([string]$id) } }

    foreach ($msg in $resp.messages) {
        if ($msg.user -ne $XIAOSONG) { continue }
        $ts  = $msg.ts
        if ($alerted.Contains($ts)) { continue }
        $age = ($now - (From-UnixTime $ts).ToUniversalTime()).TotalMinutes
        if ($age -lt 5 -or $age -gt 60) { continue }

        $replies  = Get 'conversations.replies' @{ channel=$CHANNEL; ts=$ts; limit='10' }
        $answered = $replies -and $replies.ok -and ($replies.messages | Where-Object { $_.user -and $_.user -ne $XIAOSONG }).Count -gt 0
        if (-not $answered) {
            $link = "https://openclaw.slack.com/archives/$CHANNEL/p$($ts -replace '\.', '')"
            Post ":alarm_clock: PULSE: Xiaosong unanswered >5min -- $link" $ts
            $alerted.Add($ts)
        }
    }
    $state.xiaosongSLA['alertedIds'] = @($alerted | Where-Object {
        try { ($now - (From-UnixTime $_).ToUniversalTime()).TotalMinutes -lt 120 } catch { $false }
    })
}

# --- Check 3: STAGE_TIMEOUT (20min nudge, 40min escalate) -------------------
$STAGE_MARKERS = @('PICKUP:','WORKING:','BUILDING:','DEPLOYED:','QA:','SPEC READY:','HANDOFF ->','REVIEW:')
$DONE_PATTERNS = 'DONE:|FINAL:|:checkered_flag:|:white_check_mark: DONE'

function Check-StageTimeout($state) {
    $epoch    = [datetime]'1970-01-01 00:00:00'
    $oldest   = "$([math]::Floor(([datetime]::UtcNow - $epoch).TotalSeconds - 7200)).000000"
    $resp     = Get 'conversations.history' @{ channel=$CHANNEL; limit='50'; oldest=$oldest }
    if (-not $resp -or -not $resp.ok) { return $null }

    $now      = (Get-Date).ToUniversalTime()
    $nudged   = if ($state.stageNudge['nudged'])    { $state.stageNudge['nudged'] }    else { @{} }
    $escalated = if ($state.stageNudge['escalated']) { $state.stageNudge['escalated'] } else { @{} }

    foreach ($msg in $resp.messages) {
        $matched = $STAGE_MARKERS | Where-Object { $msg.text -match [regex]::Escape($_) }
        if (-not $matched) { continue }
        $markerAge = ($now - (From-UnixTime $msg.ts).ToUniversalTime()).TotalMinutes
        if ($markerAge -gt 120) { continue }  # too old, skip

        $threadTs = if ($msg.thread_ts) { $msg.thread_ts } else { $msg.ts }
        $replies  = Get 'conversations.replies' @{ channel=$CHANNEL; ts=$threadTs; limit='50' }
        $latest   = if ($replies -and $replies.ok -and $replies.messages.Count -gt 0) {
            ($replies.messages | Sort-Object ts)[-1]
        } else { $msg }
        if ($latest.text -match $DONE_PATTERNS) { continue }

        $silent = ($now - (From-UnixTime $latest.ts).ToUniversalTime()).TotalMinutes
        $link   = "https://openclaw.slack.com/archives/$CHANNEL/p$($threadTs -replace '\.', '')"

        if ($silent -ge 40) {
            $lastEsc = if ($escalated[$threadTs]) { [datetime]$escalated[$threadTs] } else { [datetime]::MinValue }
            if (($now - $lastEsc).TotalMinutes -ge 40) {
                Post ":rotating_light: ESCALATE: Thread silent 40min -- $link" $threadTs
                $escalated[$threadTs] = $now.ToString('o')
            }
        } elseif ($silent -ge 20) {
            $lastNudge = if ($nudged[$threadTs]) { [datetime]$nudged[$threadTs] } else { [datetime]::MinValue }
            if (($now - $lastNudge).TotalMinutes -ge 20) {
                Post ":timer_clock: NUDGE: Thread silent 20min -- $link" $threadTs
                $nudged[$threadTs] = $now.ToString('o')
            }
        }
    }
    $state.stageNudge['nudged']     = $nudged
    $state.stageNudge['escalated']  = $escalated
    return $resp.messages
}

# --- Check 4: ORPHAN_THREADS (tombstone-first detection) --------------------
function Check-OrphanThreads($state) {
    $now          = (Get-Date).ToUniversalTime()
    $epoch        = [datetime]'1970-01-01 00:00:00'

    $oc             = $state.orphanCleanup
    $knownThreads   = if ($oc['knownThreads'])   { $oc['knownThreads'] }   else { @{} }
    $cleanedThreads = if ($oc['cleanedThreads']) { $oc['cleanedThreads'] } else { @{} }

    # Fetch recent history to discover new thread starters
    $oldest = "0.000000"  # scan full history (no time window limit)
    $resp   = Get 'conversations.history' @{ channel=$CHANNEL; limit='200'; oldest=$oldest }
    if ($resp -and $resp.ok) {
        foreach ($msg in $resp.messages) {
            $isTopLevel = ($msg.ts -eq $msg.thread_ts) -or ($msg.reply_count -gt 0) -or (-not $msg.thread_ts)
            if ($isTopLevel -and $msg.subtype -ne 'tombstone') {
                if (-not $knownThreads.ContainsKey($msg.ts)) {
                    $knownThreads[$msg.ts] = @{
                        firstSeen   = $now.ToString('o')
                        starterUser = if ($msg.user) { $msg.user } else { '' }
                    }
                }
            }
        }
    }

    # Prune knownThreads: older than 24h
    $pruneKeys = @($knownThreads.Keys | Where-Object {
        try { ($now - [datetime]$knownThreads[$_]['firstSeen']).TotalHours -gt 24 } catch { $true }
    })
    foreach ($k in $pruneKeys) { $knownThreads.Remove($k) }
    # Cap at 50 entries, remove oldest
    while ($knownThreads.Count -gt 50) {
        $oldest_key = $knownThreads.Keys | Sort-Object { [datetime]$knownThreads[$_]['firstSeen'] } | Select-Object -First 1
        $knownThreads.Remove($oldest_key)
    }

    # Prune cleanedThreads older than 48h
    $pruneClean = @($cleanedThreads.Keys | Where-Object {
        try { ($now - [datetime]$cleanedThreads[$_]).TotalHours -gt 48 } catch { $true }
    })
    foreach ($k in $pruneClean) { $cleanedThreads.Remove($k) }

    # Orphan detection: tombstone-first approach
    foreach ($ts in @($knownThreads.Keys)) {
        if ($cleanedThreads.ContainsKey($ts)) { continue }  # already processed

        $entry = $knownThreads[$ts]
        $firstSeenAge = try { ($now - [datetime]$entry['firstSeen']).TotalMinutes } catch { 999 }
        if ($firstSeenAge -le 5) { continue }  # grace period

        # Directly inspect thread via conversations.replies
        $repliesResp = Get 'conversations.replies' @{ channel=$CHANNEL; ts=$ts; limit='5' }

        $isOrphan = $false
        if (-not $repliesResp -or -not $repliesResp.ok) {
            # API error or thread_not_found — skip for safety (don't false-positive on API errors)
            continue
        }

        $messages = @($repliesResp.messages)
        if ($messages.Count -eq 0) { continue }  # no replies, nothing to clean

        $starter = $messages[0]
        # Orphan confirmed ONLY if starter is explicitly tombstoned
        if ($starter.subtype -eq 'tombstone') {
            $isOrphan = $true
        }

        if (-not $isOrphan) { continue }

        # Count non-tombstone replies
        $validReplies = @($messages | Where-Object { $_.subtype -ne 'tombstone' -and $_.text -ne '' })
        if ($validReplies.Count -eq 0) {
            # Already empty, just mark as cleaned
            $cleanedThreads[$ts] = $now.ToString('o')
            continue
        }

        # Option A: direct chat.delete using per-bot tokens
        $botTokens   = Get-BotTokens
        $deleteCount = 0
        $skipCount   = 0

        foreach ($reply in $validReplies) {
            $replyUser = $reply.user
            if (-not $replyUser) { $skipCount++; continue }

            if ($botTokens.ContainsKey($replyUser) -and $botTokens[$replyUser]) {
                $botToken = $botTokens[$replyUser]
                $agentName = if ($BOT_NAMES.ContainsKey($replyUser)) { $BOT_NAMES[$replyUser] } else { $replyUser }
                if ($DryRun) {
                    Write-Host "[DRY-RUN] chat.delete -> thread $ts, msg $($reply.ts), user $agentName"
                    $deleteCount++
                } else {
                    try {
                        $delBody = @{ channel=$CHANNEL; ts=$reply.ts } | ConvertTo-Json -Compress
                        $delResp = Invoke-RestMethod 'https://slack.com/api/chat.delete' -Method POST `
                            -Headers @{ Authorization="Bearer $botToken" } `
                            -ContentType 'application/json; charset=utf-8' -Body $delBody
                        if ($delResp.ok) { $deleteCount++ }
                        else { Write-Warning "chat.delete failed for $($reply.ts): $($delResp.error)" }
                    } catch { Write-Warning "chat.delete error: $_" }
                }
            } else {
                # Not a bot reply (human or unknown) — skip, can't delete
                $skipCount++
            }
        }

        Post ":wastebasket: PULSE: Orphan thread $ts cleaned (Option A) -- deleted $deleteCount bot replies, skipped $skipCount"
        $cleanedThreads[$ts] = $now.ToString('o')
    }

    # --- Direct tombstone scan (catches threads already tombstoned before pulse first saw them) ---
    if ($resp -and $resp.ok) {
        foreach ($msg in $resp.messages) {
            if ($msg.subtype -ne 'tombstone') { continue }
            $rc = if ($msg.reply_count) { [int]$msg.reply_count } else { 0 }
            if ($rc -eq 0) { continue }

            $ts = $msg.ts
            if ($cleanedThreads.ContainsKey($ts)) { continue }  # already cleaned

            # Grace period: skip if ts is less than 5 minutes old
            $tsAge = try { ($now - (From-UnixTime $ts).ToUniversalTime()).TotalMinutes } catch { 999 }
            if ($tsAge -le 5) { continue }

            # Fetch replies
            $repliesResp = Get 'conversations.replies' @{ channel=$CHANNEL; ts=$ts; limit='10' }
            if (-not $repliesResp -or -not $repliesResp.ok) { continue }

            $messages = @($repliesResp.messages)
            $validReplies = @($messages | Where-Object { $_.subtype -ne 'tombstone' -and $_.text -ne '' })
            if ($validReplies.Count -eq 0) {
                $cleanedThreads[$ts] = $now.ToString('o')
                continue
            }

            # Option A: direct chat.delete (same as tracked-thread path, no webhook dependency)
            $botTokens2  = Get-BotTokens
            $deleteCount2 = 0
            $skipCount2   = 0
            foreach ($reply in $validReplies) {
                $ru = $reply.user
                if (-not $ru) { $skipCount2++; continue }
                if ($botTokens2.ContainsKey($ru) -and $botTokens2[$ru]) {
                    $agentName2 = if ($BOT_NAMES.ContainsKey($ru)) { $BOT_NAMES[$ru] } else { $ru }
                    if ($DryRun) {
                        Write-Host "[DRY-RUN] DirectTombstone chat.delete -> thread $ts, msg $($reply.ts), user $agentName2"
                        $deleteCount2++
                    } else {
                        try {
                            $delBody2 = @{ channel=$CHANNEL; ts=$reply.ts } | ConvertTo-Json -Compress
                            $delResp2 = Invoke-RestMethod 'https://slack.com/api/chat.delete' -Method POST `
                                -Headers @{ Authorization="Bearer $($botTokens2[$ru])" } `
                                -ContentType 'application/json; charset=utf-8' -Body $delBody2
                            if ($delResp2.ok) { $deleteCount2++ }
                            else { Write-Warning "chat.delete failed for $($reply.ts): $($delResp2.error)" }
                        } catch { Write-Warning "chat.delete error: $_" }
                    }
                } else {
                    $skipCount2++
                }
            }

            Post ":wastebasket: PULSE: Orphan thread $ts cleaned (direct tombstone) -- deleted $deleteCount2 bot replies, skipped $skipCount2"
            $cleanedThreads[$ts] = $now.ToString('o')
        }
    }

    $state.orphanCleanup['knownThreads']   = $knownThreads
    $state.orphanCleanup['cleanedThreads'] = $cleanedThreads
}

# --- Check 5: SELF_MENTION ---------------------------------------------------
function Check-SelfMention($state, $historyMessages) {
    if (-not $historyMessages) { return }
    $now      = (Get-Date).ToUniversalTime()
    $alerted  = if ($state.selfMention['alertedMessageIds']) { $state.selfMention['alertedMessageIds'] } else { @{} }

    foreach ($msg in $historyMessages) {
        $userId = $msg.user
        if (-not $userId) { continue }
        if ($BOT_USER_IDS -notcontains $userId) { continue }
        $ts   = $msg.ts
        if ($alerted.ContainsKey($ts)) { continue }

        $selfMentionPattern = "<@$userId>"
        if ($msg.text -and $msg.text.Contains($selfMentionPattern)) {
            $agentName = if ($BOT_NAMES.ContainsKey($userId)) { $BOT_NAMES[$userId] } else { $userId }
            Post ":warning: PULSE: Self-mention detected -- $agentName mentioned itself"
            $alerted[$ts] = $now.ToString('o')
        }
    }

    # Prune entries older than 2h
    $pruneKeys = @($alerted.Keys | Where-Object {
        try { ($now - [datetime]$alerted[$_]).TotalHours -gt 2 } catch { $true }
    })
    foreach ($k in $pruneKeys) { $alerted.Remove($k) }

    $state.selfMention['alertedMessageIds'] = $alerted
}

# --- Check 6: UNICODE_EMOJI --------------------------------------------------
# Module C: DryRun-first — set $script:unicodeEmojiLive = $true to enable Slack posting
function Check-UnicodeEmoji($state, $historyMessages) {
    if (-not $historyMessages) { return }
    $now     = (Get-Date).ToUniversalTime()
    $alerted = if ($state.unicodeEmoji['alertedMessageIds']) { $state.unicodeEmoji['alertedMessageIds'] } else { @{} }

    foreach ($msg in $historyMessages) {
        $userId = $msg.user
        if (-not $userId) { continue }
        if ($BOT_USER_IDS -notcontains $userId) { continue }
        $ts = $msg.ts
        if ($alerted.ContainsKey($ts)) { continue }
        if (-not $msg.text) { continue }

        # PS5-compatible Unicode emoji detection using \p{So} (other symbols) and \p{Cs} (surrogates)
        $hasUnicode = [System.Text.RegularExpressions.Regex]::IsMatch($msg.text, '\p{So}|\p{Cs}')
        # Fallback: check for chars with codepoint > 9999
        if (-not $hasUnicode) {
            $hasUnicode = ($msg.text.ToCharArray() | Where-Object { [int][char]$_ -gt 9999 }).Count -gt 0
        }

        if ($hasUnicode) {
            if ($script:unicodeEmojiLive) {
                Post ":warning: PULSE: Unicode emoji in bot message -- use :colon_syntax: instead"
            } else {
                Write-Host "[Module C - VALIDATE] Unicode emoji detected in msg $ts (unicodeEmojiLive=false, not posting)"
            }
            $alerted[$ts] = $now.ToString('o')
        }
    }

    # Prune entries older than 2h
    $pruneKeys = @($alerted.Keys | Where-Object {
        try { ($now - [datetime]$alerted[$_]).TotalHours -gt 2 } catch { $true }
    })
    foreach ($k in $pruneKeys) { $alerted.Remove($k) }

    $state.unicodeEmoji['alertedMessageIds'] = $alerted
}

# --- Check 7: BOT_MENTION_SLA ------------------------------------------------
function Check-BotMentionSLA($state, $historyMessages, $replyBudgetUsed) {
    if (-not $historyMessages) { return }
    if (-not $replyBudgetUsed) { $replyBudgetUsed = 0 }
    $now = (Get-Date).ToUniversalTime()
    $alerted = if ($state.botMentionSLA['alertedMessageIds']) { $state.botMentionSLA['alertedMessageIds'] } else { @{} }
    $replyChecks = $replyBudgetUsed  # start from budget already used in Pass 2

    foreach ($msg in $historyMessages) {
        $senderId = $msg.user
        if (-not $senderId) { continue }
        if ($BOT_USER_IDS -notcontains $senderId) { continue }  # only bot messages

        $ts = $msg.ts
        if (-not $msg.text) { continue }

        $age = ($now - (From-UnixTime $ts).ToUniversalTime()).TotalMinutes
        if ($age -lt 5 -or $age -gt 60) { continue }

        # Extract all <@U...> mentions
        $mentions = [regex]::Matches($msg.text, '<@(U[A-Z0-9]+)>')
        foreach ($m in $mentions) {
            $mentionedId = $m.Groups[1].Value
            if ($mentionedId -eq $senderId) { continue }        # self-mention
            if ($mentionedId -eq $XIAOSONG) { continue }        # Xiaosong SLA covers this
            if ($BOT_USER_IDS -notcontains $mentionedId) { continue }  # not a bot
            if ($alerted.ContainsKey("$ts|$mentionedId")) { continue }  # already alerted for this bot

            # Check if mentioned bot replied
            if ($replyChecks -ge 5) { break }  # API budget cap
            $threadTs = if ($msg.thread_ts) { $msg.thread_ts } else { $msg.ts }
            $replies = Get 'conversations.replies' @{ channel=$CHANNEL; ts=$threadTs; limit='50' }
            $replyChecks++

            $replied = $false
            if ($replies -and $replies.ok) {
                foreach ($r in $replies.messages) {
                    if ($r.user -eq $mentionedId) {
                        $replyAge = try { (From-UnixTime $r.ts).ToUniversalTime() } catch { [datetime]::MinValue }
                        $mentionTime = try { (From-UnixTime $ts).ToUniversalTime() } catch { [datetime]::MinValue }
                        if ($replyAge -gt $mentionTime) { $replied = $true; break }
                    }
                }
            }

            if (-not $replied) {
                $senderName = if ($BOT_NAMES.ContainsKey($senderId)) { $BOT_NAMES[$senderId] } else { $senderId }
                $mentionedName = if ($BOT_NAMES.ContainsKey($mentionedId)) { $BOT_NAMES[$mentionedId] } else { $mentionedId }
                $link = "https://openclaw.slack.com/archives/$CHANNEL/p$($ts -replace '\.', '')"
                Post ":alarm_clock: PULSE: Bot mention unanswered >5min -- $senderName mentioned $mentionedName -- $link"
                $alerted["$ts|$mentionedId"] = $now.ToString('o')
            }
        }
    }

    # Prune entries older than 2h
    $pruneKeys = @($alerted.Keys | Where-Object {
        try { ($now - [datetime]$alerted[$_]).TotalHours -gt 2 } catch { $true }
    })
    foreach ($k in $pruneKeys) { $alerted.Remove($k) }

    $state.botMentionSLA['alertedMessageIds'] = $alerted
}

# --- Main --------------------------------------------------------------------
$state = Load-State
Check-Ports       $state

# --- Multi-channel monitoring loop -------------------------------------------
# Port checks are global; all other checks run per-channel.
foreach ($ch in $CHANNELS) {
    $CHANNEL = $ch   # swap global so all functions use the current channel

    Check-XiaosongSLA $state

    # Fetch shared history for Modules B and C (reuse Check-StageTimeout's fetch)
    $sharedMessages = Check-StageTimeout $state

    Check-OrphanThreads $state
    Check-SelfMention   $state $sharedMessages
    Check-UnicodeEmoji  $state $sharedMessages

    # --- Module E Pass 2: extend message list with active thread replies ---------
    $extendedMessages = [System.Collections.ArrayList]@()
    if ($sharedMessages) {
        foreach ($m in $sharedMessages) { [void]$extendedMessages.Add($m) }
    }
    $pass2BudgetUsed = 0
    $pass2Cap = 10
    $now2h = (Get-Date).ToUniversalTime()
    if ($sharedMessages) {
        foreach ($topMsg in $sharedMessages) {
            if ($pass2BudgetUsed -ge $pass2Cap) { break }
            $rc = if ($topMsg.reply_count) { [int]$topMsg.reply_count } else { 0 }
            if ($rc -le 1) { continue }
            if (-not $topMsg.latest_reply) { continue }
            try {
                $latestReplyTime = (From-UnixTime $topMsg.latest_reply).ToUniversalTime()
            } catch { continue }
            if (($now2h - $latestReplyTime).TotalMinutes -gt 120) { continue }
            $threadReplies = Get 'conversations.replies' @{ channel=$CHANNEL; ts=$topMsg.ts; limit='50' }
            $pass2BudgetUsed++
            if (-not $threadReplies -or -not $threadReplies.ok) { continue }
            $replyMsgs = $threadReplies.messages
            for ($ri = 1; $ri -lt $replyMsgs.Count; $ri++) {
                [void]$extendedMessages.Add($replyMsgs[$ri])
            }
        }
    }

    # Deduplicate
    $seenTs = @{}
    $deduped = [System.Collections.ArrayList]@()
    foreach ($em in $extendedMessages) {
        if (-not $seenTs.ContainsKey($em.ts)) {
            $seenTs[$em.ts] = $true
            [void]$deduped.Add($em)
        }
    }
    $extendedMessages = $deduped

    Check-BotMentionSLA $state $extendedMessages 0
}

Save-State $state
