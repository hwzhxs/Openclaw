$ErrorActionPreference='Stop'
$path='C:\Users\azureuser\shared\scripts\watchdog.ps1'
$raw=Get-Content $path -Raw
$idx=$raw.IndexOf('Persist state')
if($idx -lt 0){ throw 'Persist state marker not found' }

$insert=@'

# ═══════════════════════════════════════════════════════════════
# MODULE 11: "React only" text replies enforcement
# If an agent posts text like "react only / not my @mention" instead of using emoji,
# ask them to delete that message and react with emoji instead.
# NOTE: This module only requests deletion (no auto-delete).
# ═══════════════════════════════════════════════════════════════
try {
    $oldest11 = Get-Oldest $RuleLookbackMin
    $hist11 = Invoke-RestMethod "https://slack.com/api/conversations.history?channel=$SlackChannel&oldest=$oldest11&limit=50" `
        -Method GET -Headers @{Authorization="Bearer $SlackToken"}

    $allMsgs11 = @()
    if ($hist11.ok -and $hist11.messages) {
        $allMsgs11 += $hist11.messages
        foreach ($m in $hist11.messages) {
            if ($m.thread_ts -and $m.reply_count -and [int]$m.reply_count -gt 0) {
                $replies = Get-Replies $m.thread_ts
                foreach ($r in $replies) {
                    if ($r.ts -ne $m.thread_ts) { $allMsgs11 += $r }
                }
            }
        }
    }

    $reactOnlyPat = "(?i)(react\s+only|emoji\s+react\s+only|not\s+my\s+@mention|no\s+@all\s+mention|no\s+@[^\s]+\s+mention)"

    foreach ($msg in $allMsgs11) {
        $isAgent = ($AgentBotUserIds -contains $msg.user) -or ($msg.bot_id -and $BotIdToUserId.ContainsKey($msg.bot_id))
        if (-not $isAgent) { continue }

        $text = if ($msg.text) { $msg.text.Trim() } else { "" }
        if (-not $text) { continue }
        if ($text -match "^:warning: Watchdog:") { continue }
        if (-not ($text -match $reactOnlyPat)) { continue }

        $msgTs = $msg.ts
        $threadTs = if ($msg.thread_ts) { $msg.thread_ts } else { $msg.ts }
        $k = "reactonly_$msgTs"
        if (-not (Should-Alert $k)) { continue }

        $userId = if ($msg.user -and $AgentBotUserIds -contains $msg.user) { $msg.user }
                  elseif ($msg.bot_id -and $BotIdToUserId.ContainsKey($msg.bot_id)) { $BotIdToUserId[$msg.bot_id] }
                  else { "" }
        if (-not $userId) { continue }

        $snippet = if ($text.Length -gt 120) { $text.Substring(0,120) + "..." } else { $text }
        $mention = "<@$userId>"
        Send-AlertAndHook ":warning: Watchdog: $mention please delete this text reply and use emoji reaction only (no text when not @mentioned).\n> $snippet" @('U0AHN84GJGG',$userId) $threadTs
        Mark-Alert $k
    }
} catch { Write-Host "Module 11 error: $_" }
'@

$raw2 = $raw.Insert($idx-3, $insert + "`r`n")
Set-Content -Path $path -Value $raw2 -Encoding UTF8
'patched'
