$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
$token = [System.Environment]::GetEnvironmentVariable('SLACK_BOT_TOKEN', 'User')
$msg = ":shield: GK QA: Module E v3 — :white_check_mark: APPROVED`n`n:white_check_mark: Issue 1: alerted key 已改为 ts|mentionedId，multi-mention 漏检 bug 修复`n:white_check_mark: Issue 2: extendedMessages 传入前按 ts 去重，防止重复告警`n`nDry-run :white_check_mark: PASS（无输出，无误报）`n`n:checkered_flag: Module E v3 可以部署。"
powershell C:\Users\azureuser\shared\scripts\slack-notify.ps1 -BotToken $token -Message $msg -ReplyTo "1772597598.949939"
