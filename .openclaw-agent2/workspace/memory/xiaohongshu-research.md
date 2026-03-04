# 小红书 (Xiaohongshu/RED) — 研究记忆文件
> Thinker 🧠 | Created: 2026-03-03

## 一、MCP 集成

### 基础信息
- **Binary**: `C:\tools\xiaohongshu-mcp\` (v2026.03.01.1740-ed7e493)
- **Server**: `localhost:18060/mcp` (binds 0.0.0.0, firewall blocks external)
- **启动脚本**: `C:\tools\xiaohongshu-mcp\start-mcp.ps1` (auto-syncs cookies from `%USERPROFILE%\cookies.json`)
- **Auth**: Cookie-based, `cookies.json` in server CWD
- **13 tools**: check_login_status, search_feeds, list_feeds, publish_content, publish_with_video, get_feed_detail, post_comment_to_feed, user_profile, like_feed, favorite_feed, reply_comment_in_feed, get_login_qrcode, delete_cookies

### 已知问题
- `mcporter call` has Windows SSE transport bug (exit code 1) — use raw HTTP JSON-RPC via `Invoke-WebRequest`
- PowerShell `ConvertFrom-Json` fails on XHS API responses due to duplicate keys (`nickname`/`nickName`) — workaround: unescape inner JSON from `result.content[0].text`, then regex extract
- One web session per XHS account — logging in elsewhere invalidates MCP cookies
- Server does NOT auto-start on reboot; no Task Scheduler entry yet
- `user_profile` requires `xsec_token` parameter (extract from search results)
- `search_feeds` sort filters (e.g., `sort_by: "最多点赞"`) may not work — returns error in garbled encoding

### 调用模板
```powershell
# Init session
$h = @{"Accept"="application/json, text/event-stream"}
$b = @{jsonrpc="2.0";id=1;method="initialize";params=@{protocolVersion="2024-11-05";capabilities=@{};clientInfo=@{name="thinker";version="1.0"}}} | ConvertTo-Json -Depth 5
$r = Invoke-WebRequest -Uri "http://localhost:18060/mcp" -Method POST -ContentType "application/json" -Body $b -Headers $h -UseBasicParsing -TimeoutSec 30
$sid = $r.Headers["Mcp-Session-Id"]

# Call tool
$h = @{"Accept"="application/json, text/event-stream";"Mcp-Session-Id"=$sid}
$b = @{jsonrpc="2.0";id=2;method="tools/call";params=@{name="search_feeds";arguments=@{keyword="网球穿搭"}}} | ConvertTo-Json -Depth 5
$r = Invoke-WebRequest -Uri "http://localhost:18060/mcp" -Method POST -ContentType "application/json" -Body $b -Headers $h -UseBasicParsing -TimeoutSec 120
```

### 解析模板 (extract from nested JSON)
```powershell
$raw = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($path))
$ts = $raw.IndexOf('"text":"') + 8
$te = $raw.LastIndexOf('"}]}')
$inner = $raw.Substring($ts, $te - $ts) -replace '\\n',' ' -replace '\\"','"' -replace '\\\\','\'
# Then regex: [regex]::Matches($inner, '"likedCount":\s*"(\d+)"')
```

## 二、平台规则
- 标题 ≤20 chars, 正文 ≤1000 chars
- ~50 posts/day max
- 禁止引流/搬运内容
- Peak engagement: 7-9am, 12-2pm, 7-10pm CST
- 算法重点看：收藏率、评论率、搜索来源占比

## 三、内容策略 — 时尚+网球 (女装/气质风格)

### 定位
> 「球场 editorial — 把网球穿搭拍成 lookbook」

- **人群**: 想把网球穿搭拍得像 lookbook 的女生 / 通勤→球场一套两用的白领 / 新手入坑怕尴尬
- **美学**: ALD 式低饱和 + 自然光 + 复古运动感
- **品牌矩阵**: Kith×Wilson / ALD / Lacoste / Nike Court / On
- **内容形式**: 图文为主（lookbook 式），穿插视频
- **差异化**: 小红书目前缺"女装 editorial 网球穿搭"，大部分是 OOTD 自拍

### 风格方向 (4 种)
1. **Clean fit**: 纯色、线条、合身、比例
2. **Old money**: 学院、针织质感、米白海军蓝、金属配饰
3. **韩系甜酷**: 短、收、露一点、亮色点缀
4. **法式运动感**: 松弛、低饱和、复古、细节

### 主攻关键词排序 (基于数据)
1. 「球场穿搭 lookbook」— 头部5帖均赞2,771，收藏率54-112%
2. 「网球 ootd」— 头部6,315赞
3. 「网球穿搭 女生」— 头部1,934赞，收藏率88.8%
4. 「tennis outfit」— 头部390,774赞（但竞争激烈）

## 四、真实数据 — 10 个对标账号 (2026-03-02 抓取)

### 第一批 (Kith×Wilson / ALD 搜索)
| # | redId | 粉丝 | 总互动 | 帖数 | 视频:图文 | 均赞 | 最高赞 | 互动/粉丝 |
|---|---|---|---|---|---|---|---|---|
| A | 5380040756 | 9,033 | 76,374 | 31 | 29:2 | 297 | 1,270 | 8.5 |
| B | BAOJIAN | 271 | 2,564 | 29 | 8:24 | 44 | 403 | 9.5 |
| C | 540487823 | 26,647 | 135,376 | 30 | 10:20 | 339 | 851 | 5.1 |
| D | 187461106 | 20,415 | 71,173 | 32 | 3:29 | 116 | 1,004 | 3.5 |
| E | mensdaily | 38,131 | 239,576 | 31 | 1:30 | 564 | 4,294 | 6.3 |

### 第二批 (扩展关键词搜索)
| # | redId | 粉丝 | 总互动 | 帖数 | 视频:图文 | 均赞 | 最高赞 | 互动/粉丝 |
|---|---|---|---|---|---|---|---|---|
| F | Pearl444 | 12,682 | 58,301 | 32 | 10:22 | 85 | 446 | 4.6 |
| G | 191067827 | 13,729 | 89,735 | 31 | 30:1 | 632 | 4,880 | 6.5 |
| H | 95398709457 | 26 | 1,296 | 2 | 0:3 | 448 | 894 | 49.8 |
| I | _Y775885 | 1,321 | 24,898 | 30 | 2:28 | 245 | 3,868 | 18.8 |
| J | 411421051 | 5,983 | 115,547 | 31 | 7:24 | 108 | 762 | 19.3 |

### 对标优先级
- **学内容结构** → 账号 I (_Y775885, 1,321粉/均赞245/最高3,868)
- **学 lookbook 拍法** → 账号 G (191067827, 均赞632, lookbook赛道最稳)
- **学爆款逻辑** → 账号 H (26粉打出6,315赞)
- **学精品路线** → 账号 E (mensdaily, 31帖→3.8万粉, 几乎全图文)
- **新号对标** → 账号 B (BAOJIAN, 271粉/最高403赞, Kith×Wilson)

## 五、关键发现 (数据支撑)

1. **图文 > 视频** (在 lookbook/styling 赛道): 图文为主账号粉丝天花板更高 (2-3.8万 vs 视频账号9千)
2. **收藏率是北极星指标**: lookbook 赛道收藏 > 点赞是常态 (112%), 说明用户在找可执行方案
3. **新号完全能爆**: 26粉丝打出6,315赞 (互动/粉丝比49.8), 271粉打出403赞 (比9.5) — 内容质量压倒粉丝基数
4. **30帖见结果**: 10个账号都在29-32帖可见, 不需要100帖验证方向
5. **小号曝光效率更高**: 粉丝<1000 互动/粉丝比中位数~20+, 粉丝10k+ 则~5
6. **Kith×Wilson 子赛道图文收藏率29.5%**, ALD 品牌故事+穿搭公式收藏率37.8%

## 六、搜索结果概况 (6 关键词 × 20 条)

| 关键词 | 视频:图文 | 头部最高赞 | 头部收藏率 |
|---|---|---|---|
| 网球穿搭 女生 | 9:11 | 1,934 | 88.8% |
| 网球裙 穿搭 | 6:14 | 340 | 53.3% |
| 运动穿搭 高级感 | 9:11 | 1,934 | 110.1% |
| 网球 ootd | 4:16 | 6,315 | 28.9% |
| tennis outfit | 5:15 | 390,774 | 12.7% |
| 球场穿搭 lookbook | 4:16 | 4,880 | 112.3% |

## 七、拍摄风格建议 (ALD lookbook 式)
- 构图: 全身 3/4 + 细节特写 (面料/logo/鞋袜), 2-3 张一组
- 色调: 低饱和、偏暖、颗粒感
- 场景: 球场边、球网前、看台、更衣室走廊
- 道具: 球拍靠墙/放地上、网球散落、球包半开
- 封面: serif 字体 + 简短 hook, 模仿杂志排版

## 八、原始数据文件
- `C:\temp\xhs-kith.json` — Kith Wilson 网球 搜索结果
- `C:\temp\xhs-ald.json` — ALD 网球穿搭 搜索结果
- `C:\temp\xhs-detail1.json` — 帖子详情
- `C:\temp\xhs-user1.json` — 用户画像
- `C:\temp\xhs-profile-*.json` — 10个对标账号主页数据
- `C:\temp\xhs-search-*.json` — 6个关键词搜索结果

## 九、待办
- [ ] 深拆账号 H (26粉/6315赞) 的帖子内容 (标签、正文、封面)
- [ ] 深拆账号 I (_Y775885) 的帖子结构
- [ ] 提取 mensdaily 具体帖子的标签策略
- [ ] MCP server 加入 Task Scheduler 开机自启
- [ ] Admin 完成关键词矩阵 + 30天发帖节奏最终版
