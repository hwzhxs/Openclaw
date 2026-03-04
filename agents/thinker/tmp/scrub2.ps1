$token = '[REDACTED_SLACK_TOKEN]'
$placeholder = '<REDACTED>'

$files = @(
    'C:\Users\azureuser\.openclaw-agent2\workspace\memory\2026-03-03.md',
    'C:\Users\azureuser\.openclaw-agent2\workspace\memory\2026-03-04.md',
    'C:\Users\azureuser\shared\specs\token-scrub-spec.md'
)

foreach ($f in $files) {
    if (Test-Path $f) {
        $content = Get-Content $f -Raw -Encoding utf8
        $count = ([regex]::Matches($content, [regex]::Escape($token))).Count
        if ($count -gt 0) {
            $content = $content.Replace($token, $placeholder)
            Set-Content $f -Value $content -Encoding utf8 -NoNewline
            Write-Host "$f : replaced $count occurrences"
        } else {
            Write-Host "$f : no matches"
        }
    }
}

