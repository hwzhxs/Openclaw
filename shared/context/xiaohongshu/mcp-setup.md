# XHS MCP Setup / Runbook

**Owner:** Admin (xXx)
**Last updated:** 2026-03-03 (UTC)

## Install
- Location: `C:\tools\xiaohongshu-mcp\`
- Binaries:
  - `xiaohongshu-mcp-windows-amd64.exe` (server)
  - `xiaohongshu-login-windows-amd64.exe` (GUI login)
- Release used: `v2026.03.01.1740-ed7e493`
- Server reports: `xiaohongshu-mcp v2.0.0`

## Endpoint / Transport
- Endpoint: `http://localhost:18060/mcp`
- Transport: HTTP SSE MCP
- Tools observed (13):
  - `check_login_status`, `delete_cookies`, `favorite_feed`, `get_feed_detail`, `get_login_qrcode`, `like_feed`, `list_feeds`, `post_comment_to_feed`, `publish_content`, `publish_with_video`, `reply_comment_in_feed`, `search_feeds`, `user_profile`

## Start
- Script: `C:\tools\xiaohongshu-mcp\start-mcp.ps1`
- Note: server must be running before tool calls.

## Login / Cookies
- Login requires GUI (not SSH):
  - Run: `C:\tools\xiaohongshu-mcp\xiaohongshu-login-windows-amd64.exe`
- Known gotcha:
  - Login tool saved `cookies.json` under `%USERPROFILE%`
  - Server CWD expected `C:\tools\xiaohongshu-mcp\` and couldn’t find cookies → “未登录”
- Fix/mitigation used:
  - Sync/copy `cookies.json` into `C:\tools\xiaohongshu-mcp\` and restart server from that directory
  - `start-mcp.ps1` was hardened to auto-sync cookies on each start
- Risk: `cookies.json` plaintext → protect filesystem + don’t expose port externally.

## Security / Networking
- Risk observed: server binding appeared as `0.0.0.0:18060` (all interfaces) at one point.
- Mitigations:
  1) Bind localhost only if supported by server flags (e.g., `--host 127.0.0.1` if available)
  2) Otherwise Windows Firewall: block inbound 18060 externally and allow localhost.

## MCPorter notes
- `mcporter list` worked.
- `mcporter call` sometimes exited code 1 / silent failure on Windows for SSE (suspected transport bug).
- Treat `mcporter call` failures as a CLI limitation, not necessarily server failure.

## Ops notes
- No auto-start on reboot yet (Task Scheduler recommended if needed).
- One web session per XHS account: logging in elsewhere can invalidate cookies.
