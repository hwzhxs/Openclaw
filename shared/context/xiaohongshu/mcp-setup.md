# 小红书 MCP — 技术运维手册
> Owner: Admin / Creator | Last updated: 2026-03-03 | Scope: 安装、启动、登录、已知坑、调用模板

## 基础信息
- **Binary**: `C:\tools\xiaohongshu-mcp\` (v2026.03.01.1740-ed7e493, MCP server v2.0.0)
- **Server**: `http://localhost:18060/mcp` (binds 0.0.0.0, firewall blocks external)
- **启动脚本**: `C:\tools\xiaohongshu-mcp\start-mcp.ps1` (auto-syncs cookies from `%USERPROFILE%\cookies.json`)
- **Auth**: Cookie-based, `cookies.json` must be in server CWD
- **13 tools**: check_login_status, search_feeds, list_feeds, publish_content, publish_with_video, get_feed_detail, post_comment_to_feed, user_profile, like_feed, favorite_feed, reply_comment_in_feed, get_login_qrcode, delete_cookies

## 启动步骤
1. 运行 `C:\tools\xiaohongshu-mcp\start-mcp.ps1`
2. 验证: call `check_login_status` → 应返回「已登录」

## 登录 / Cookies
- 登录需要 GUI (非 SSH): 运行 `C:\tools\xiaohongshu-mcp\xiaohongshu-login-windows-amd64.exe`
- Login binary 存 `cookies.json` 到 `%USERPROFILE%\`，start script 会自动 sync 到 server CWD
- ⚠️ One web session per XHS account — 在浏览器登录会使 MCP cookies 失效
- Cookie 过期需重新运行 login binary

## 安全
- Server binds `0.0.0.0:18060` — firewall rules 已添加阻止外部访问
- `cookies.json` 是明文，注意保护

## 已知问题
| 问题 | Workaround |
|---|---|
| `mcporter call` exit code 1 (Windows SSE bug) | 用 raw HTTP JSON-RPC via `Invoke-WebRequest` |
| PowerShell `ConvertFrom-Json` fails (duplicate `nickname`/`nickName` keys) | 用 regex 从 inner JSON 提取，或 string-replace `"nickName":` → `"nick_name":` |
| `user_profile` 需要 `xsec_token` | 从 `search_feeds` 结果中提取 |
| `search_feeds` sort filters 不工作 | 不传 sort 参数，手动排序 |
| Server 不自动启动 | 未加入 Task Scheduler (待办) |

## 调用模板 (Raw HTTP)
```powershell
# 1. Init session
$h = @{"Accept"="application/json, text/event-stream"}
$b = @{jsonrpc="2.0";id=1;method="initialize";params=@{protocolVersion="2024-11-05";capabilities=@{};clientInfo=@{name="agent";version="1.0"}}} | ConvertTo-Json -Depth 5
$r = Invoke-WebRequest -Uri "http://localhost:18060/mcp" -Method POST -ContentType "application/json" -Body $b -Headers $h -UseBasicParsing -TimeoutSec 30
$sid = $r.Headers["Mcp-Session-Id"]

# 2. Call tool
$h = @{"Accept"="application/json, text/event-stream";"Mcp-Session-Id"=$sid}
$b = @{jsonrpc="2.0";id=2;method="tools/call";params=@{name="search_feeds";arguments=@{keyword="网球穿搭"}}} | ConvertTo-Json -Depth 5
$r = Invoke-WebRequest -Uri "http://localhost:18060/mcp" -Method POST -ContentType "application/json" -Body $b -Headers $h -UseBasicParsing -TimeoutSec 120
```

## 解析模板 (nested JSON extraction)
```powershell
$raw = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($path))
$ts = $raw.IndexOf('"text":"') + 8
$te = $raw.LastIndexOf('"}]}')
$inner = $raw.Substring($ts, $te - $ts) -replace '\\n',' ' -replace '\\"','"' -replace '\\\\','\'
# Then regex: [regex]::Matches($inner, '"likedCount":\s*"(\d+)"')
```
