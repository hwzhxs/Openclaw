# TOOLS.md - Local Notes

## Slack
- Emoji react: use `exec` with Slack API `reactions.add`, token from `$env:SLACK_BOT_TOKEN`
- Shared scripts (`slack-notify.ps1`, `check-unanswered-mentions.ps1`) require `-BotToken` explicitly
- After editing `openclaw.json`: run `openclaw config validate` before restart

## TTS / Voice
- Telegram voice: `message(action=send, asVoice=true, filePath=<path>, target=8166133248)`
- Edge TTS (Chinese): `edge-tts --voice zh-CN-XiaoxiaoNeural --text "..." --write-media C:\tmp\openclaw\voice.mp3`
  - Set PATH first: `cmd /c "set PATH=%LOCALAPPDATA%\Programs\Python\Python312;%LOCALAPPDATA%\Programs\Python\Python312\Scripts;%PATH% && edge-tts ..."`
  - Male: `zh-CN-YunxiNeural` / Female: `zh-CN-XiaoxiaoNeural`
- Transcription: `C:\Users\azureuser\.openclaw\scripts\transcribe.ps1 -AudioFile <path>` (Azure Speech, southeastasia)
