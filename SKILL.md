---
name: douyin-automation
description: 抖音内容自动化运营技能。自动化抓取AI量化/金融科技类视频内容，通过AI改写后发布为抖音长图文/文章，并自动回复评论。适用场景：(1) 定时运营流水线执行，(2) 单步操作（发布/导出评论/回复），(3) 配置调整（关键词/频率/AI参数），(4) 故障排查，(5) 新平台扩展。
---

# Douyin-Automation 抖音内容自动化运营

## 系统架构

```
liblib.tv 视频 → douyin-agent (FastAPI :8080)
    ↓ 提取文案 + AI改写 → chatgroup.db (SQLite)
    ↓
douyin_full_orchestrator.py  ← 当前 Skill 的核心编排器
    ↓ 调用
douyin-creator-tools/src/
    publish-douyin-article.mjs  → 抖音文章（长图文）
    export-douyin-comments.mjs → 导出评论
    reply-douyin-comments.mjs  → 回复评论
```

## 核心路径（必读）

**跨电脑迁移必读** → [CONFIG.md](CONFIG.md)，所有路径集中管理，改一处全生效。

- **编排器**：`D:\douyin\orchestrator\douyin_full_orchestrator.py`
- **Agent后端**：`D:\douyin\douyin-agent-master\backend\app\main.py`（FastAPI，端口8080）
- **数据库**：`D:\douyin\douyin-agent-master\backend\app\chatgroup.db`（SQLite，存放监控项和发布状态）
- **Creator工具**：`C:\Users\Administrator\.openclaw\douyin-creator-tools\src\`
- **上传目录**：`D:\douyin\douyin-agent-master\backend\uploads\`（封面图存放）
- **Cookie**：`D:\douyin\douyin-agent-master\backend\douyin_cookies.json`

## 运营流程（定时 Cron）

编排器每次执行完整流水线：
1. **频率检查** — 每日上限3条，每次间隔≥1h
2. **内容筛选** — 从DB查询 rank_score≥0、已完整转写、未发布的AI/量化相关视频
3. **安全检查** — 金融违规词过滤、内容安全高危词过滤
4. **AI优化** — 调用 OpenClaw Gateway 将视频脚本转为适合图文阅读的正文
5. **封面生成** — 优先 item 专属封面 → Qenda AI 生成 → 回退到通用封面
6. **发布长图文** → `publish-douyin-article.mjs`（经 Chrome CDP 操作已登录浏览器）
7. **导出评论** → `export-douyin-comments.mjs`
8. **自动回复** → `reply-douyin-comments.mjs`

## 执行方式

### 方式一：定时 Cron（推荐）

由 OpenClaw Cron 触发（参考 `qclaw-cron-skill`），调用编排器：

```powershell
python "D:\douyin\orchestrator\douyin_full_orchestrator.py"
```

参数：
- `--dry-run` — 只看日志，不实际发布
- `--no-ai` — 禁用AI优化，回退到正则清洗

### 方式二：单步操作

| 目标 | 脚本 |
|------|------|
| 仅发布 | `python "D:\douyin\orchestrator\douyin_full_orchestrator.py"` |
| 仅导出评论 | 见 references/comment-reply.md |
| 仅回复评论 | 见 references/comment-reply.md |
| 仅生成封面 | 见 references/cover-ai.md |
| 查看DB待发队列 | 见 references/publishing.md |

## 详细内容参考

- **发布配置与安全规则** → [references/publishing.md](references/publishing.md)
- **评论导出与自动回复** → [references/comment-reply.md](references/comment-reply.md)
- **Qenda AI 封面生成** → [references/cover-ai.md](references/cover-ai.md)
- **编排器配置参数** → [references/config-reference.md](references/config-reference.md)

## 快速运维命令

```powershell
# 检查编排器依赖（Python 3.11）
python -c "import sqlite3, asyncio, json, subprocess; print('OK')"

# 查看今日已发布数量
sqlite3 "D:\douyin\douyin-agent-master\backend\app\chatgroup.db" "SELECT COUNT(*) FROM monitor_items WHERE publish_status='published' AND date(publish_time) = date('now', 'localtime', '+8 hours')"

# 查看待发队列
sqlite3 "D:\douyin\douyin-agent-master\backend\app\chatgroup.db" "SELECT id, title, rank_score, imagetext_published FROM monitor_items WHERE imagetext_published=0 AND transcript_status='full' ORDER BY rank_score DESC LIMIT 10"

# 重置某条发布状态（重新发布）
sqlite3 "D:\douyin\douyin-agent-master\backend\app\chatgroup.db" "UPDATE monitor_items SET imagetext_published=0, article_published=0, publish_status=NULL WHERE id=<item_id>"

# 检查 Chrome CDP 是否可用（手动启动 Chrome 带 --remote-debugging-port=9222）
curl http://localhost:9222/json/version 2>$null; if ($LASTEXITCODE -eq 0) { "CDP OK" } else { "CDP down" }

# 重启 douyin-agent 后端
Stop-Process -Name python -Filter "main:uvicorn" -Force -ErrorAction SilentlyContinue
Start-Process python -ArgumentList "-m uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload" -WorkingDirectory "D:\douyin\douyin-agent-master\backend"
```

## 新平台扩展（小红书）

小红书发布功能已实现但账号已封禁。解封后：
1. 确认 `XHS_ENABLED = True`（在编排器中）
2. 确认 Chrome CDP 端口 9222 正常
3. 参考 [references/publishing.md](references/publishing.md) 激活小红书发布

## 常见故障

| 症状 | 可能原因 | 解决 |
|------|---------|------|
| "No items to publish" | DB无满足条件的项 | 确认 agent 已抓取并改写内容 |
| "No cover image" | 封面目录为空 | 检查 uploads 目录，运行封面生成 |
| "Content unsafe" | 命中安全词过滤 | 检查 FINANCE_BANNED_WORDS |
| CDP 连接失败 | Chrome 未带调试端口启动 | 手动启动 Chrome `--remote-debugging-port=9222` |
| 编排器卡住 | 浏览器登录态失效 | 重新扫码登录，更新 douyin_cookies.json |
