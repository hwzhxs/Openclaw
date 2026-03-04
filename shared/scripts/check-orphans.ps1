# Load token from secrets (never hardcode)
. "C:\Users\azureuser\shared\scripts\load-secrets.ps1"
$token = $env:SLACK_BOT_TOKEN_THINKER
$h = @{ Authorization = "Bearer $token" }

foreach ($ts in @('1772568094.082149', '1772560836.671609')) {
    $url = "https://slack.com/api/conversations.replies?channel=C0AGMF65DQB&ts=$ts&limit=10"
    $r = Invoke-RestMethod $url -Headers $h
    Write-Host "=== Thread $ts ==="
    Write-Host "ok=$($r.ok) count=$($r.messages.Count)"
    foreach ($m in $r.messages) {
        $txt = if ($m.text.Length -gt 40) { $m.text.Substring(0,40) } else { $m.text }
        Write-Host "  user=$($m.user) subtype=$($m.subtype) text=$txt"
    }
}
