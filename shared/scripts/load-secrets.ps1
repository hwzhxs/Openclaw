# load-secrets.ps1 - Dot-source this at the top of any script that needs secrets
# Usage: . "$PSScriptRoot\load-secrets.ps1"
# Example: . "C:\Users\azureuser\shared\scripts\load-secrets.ps1"

$secretsFile = "C:\Users\azureuser\shared\secrets.env"
if (Test-Path $secretsFile) {
    # Use ReadAllLines for reliable encoding handling (avoids PS5 Get-Content issues)
    $lines = [System.IO.File]::ReadAllLines($secretsFile, [System.Text.Encoding]::UTF8)
    foreach ($line in $lines) {
        if ($line -match '^\s*([^#][^=]+)=(.+)$') {
            [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
        }
    }
} else {
    Write-Warning "secrets.env not found at $secretsFile"
}
