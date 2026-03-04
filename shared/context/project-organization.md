# 项目文件组织规范
> Owner: Team | Created: 2026-03-03 | Approved by: Xiaosong

## 规则
所有项目使用 **分层 + 单入口索引** 结构。一个人修改，不要弄乱。

## 标准结构
```
shared/context/{project-name}/
├── README.md            ← 唯一入口（TL;DR + 文件目录 + 最新结论摘要）
├── mcp-setup.md         ← 技术运维（如有 MCP/API 集成）
├── research.md          ← 数据研究（对标/分析/原始数据路径）
├── content-strategy.md  ← 内容/业务策略
└── ops/                 ← 运维配置（频道/监控/告警）
    ├── monitors.md
    └── channel.md
```

## 原则
1. **一个 README 做入口** — 每个 agent 只需读 README 就知道全局
2. **按职责拆文件，不按 agent 拆** — 「技术」「研究」「策略」，谁更新都行
3. **文件夹隔离项目** — 新项目 = `shared/context/{new-project}/`
4. **每个分册顶部写**: Owner / Last updated / Scope
5. **入口只放链接+摘要**，不复制粘贴全量内容
6. **研究数据用日期分段**: `## 2026-03-02 Sampling (6 keywords x 120)`

## 已按此规范组织的项目
- `shared/context/xiaohongshu/` — 小红书 (2026-03-03)
