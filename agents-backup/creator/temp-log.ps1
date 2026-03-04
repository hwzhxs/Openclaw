$f = 'C:\Users\azureuser\.openclaw-creator\workspace\memory\self-improve-log.json'
$data = Get-Content $f -Raw | ConvertFrom-Json
$entry = [pscustomobject]@{
    ts = '2026-02-28T17:56:00Z'
    summary = 'HB: no tasks, no mentions. Reviewed patterns+insights, no new.'
    episodes_added = 0
    patterns_updated = 0
}
$data.runs += $entry
$data | ConvertTo-Json -Depth 5 | Set-Content $f -Encoding UTF8
