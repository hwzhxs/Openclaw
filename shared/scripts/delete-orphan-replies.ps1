$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

$token = $env:SLACK_BOT_TOKEN
$channel = "C0AJ4P0T274"
$targetUser = "U0AHN84GJGG"  # Admin bot

$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

# All tombstone thread_ts values with orphan replies from Admin
$threadIds = @(
    "1772523986.596599",
    "1772523502.853149",
    "1772521404.370029",
    "1772521320.641139",
    "1772521293.823849",
    "1772520851.423699",
    "1772520845.000479",
    "1772520843.855099",
    "1772518432.879569",
    "1772518432.079129",
    "1772518205.482339",
    "1772518203.404609",
    "1772518200.501039",
    "1772518199.921199",
    "1772518199.586289",
    "1772518173.801199",
    "1772518171.143769",
    "1772518065.080479",
    "1772518064.141499",
    "1772518063.346869",
    "1772518062.669419",
    "1772518050.840479",
    "1772517947.794629",
    "1772517947.259489",
    "1772517946.259089",
    "1772517945.868639",
    "1772517843.584779",
    "1772517839.137789",
    "1772517834.753559",
    "1772517830.359719",
    "1772517808.986449",
    "1772517717.876419",
    "1772517713.486219",
    "1772517709.054249",
    "1772517593.225409",
    "1772517588.839629",
    "1772517582.450989",
    "1772517452.490039",
    "1772517452.038539",
    "1772517451.678249",
    "1772517440.065409",
    "1772517327.643529",
    "1772517326.675939",
    "1772517326.287919",
    "1772517317.965169",
    "1772517228.154799",
    "1772517223.781229",
    "1772517205.195909",
    "1772517097.673649",
    "1772517093.310399",
    "1772517081.119559",
    "1772516971.481869",
    "1772516967.115269",
    "1772516852.469339",
    "1772516848.097769",
    "1772516839.654029",
    "1772516721.712589",
    "1772516606.113509",
    "1772516597.432219",
    "1772516485.620459",
    "1772516369.077729",
    "1772516253.868359",
    "1772516121.949649",
    "1772515996.409119",
    "1772515871.783739",
    "1772515867.376599",
    "1772515748.530189",
    "1772514792.571919",
    "1772528717.426829"  # "Delete all spam" thread with Admin replies
)

$deleted = 0
$failed = 0

foreach ($threadTs in $threadIds) {
    # Fetch thread replies
    $url = "https://slack.com/api/conversations.replies?channel=$channel&ts=$threadTs&limit=100"
    try {
        $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
        if (-not $resp.ok) {
            Write-Host "Failed to fetch thread $threadTs`: $($resp.error)"
            continue
        }
        
        foreach ($msg in $resp.messages) {
            # Skip the parent (thread_ts == ts) and only delete target user's messages
            if ($msg.user -eq $targetUser -and $msg.ts -ne $threadTs) {
                $delBody = @{channel=$channel; ts=$msg.ts} | ConvertTo-Json
                try {
                    $delResp = Invoke-RestMethod -Uri "https://slack.com/api/chat.delete" -Method POST -Headers $headers -Body $delBody
                    if ($delResp.ok) {
                        Write-Host "Deleted $($msg.ts)"
                        $deleted++
                    } else {
                        Write-Host "FAILED $($msg.ts): $($delResp.error)"
                        $failed++
                    }
                } catch {
                    Write-Host "ERROR deleting $($msg.ts): $_"
                    $failed++
                }
                Start-Sleep -Milliseconds 300
            }
        }
    } catch {
        Write-Host "ERROR fetching thread $threadTs`: $_"
    }
}

Write-Host "Done. Deleted: $deleted, Failed: $failed"
