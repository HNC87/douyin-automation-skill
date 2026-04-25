---
name: douyin-automation
description: 抖音内容自动化运营技能。自动化抓取AI量化/金融科技类视频内容，通过AI改写后发布为抖音长图文/文章，并自动回复评论。跨平台支持 Windows/macOS/Linux，运行 setup.py 自动检测路径。适用场景：(1) 定时运营流水线执行，(2) 单步操作（发布/导出评论/回复），(3) 配置调整（关键词/频率/AI参数），(4) 故障排查。
---

# Douyin-Automation 抖音内容自动化运营

## Quick Start

```bash
# 1. 运行安装向导（自动检测路径，生成 CONFIG.md）
python scripts/setup.py

# 2. 检查系统状态
python scripts/status-check.py

# 3. 执行运营流水线
python scripts/run-pipeline.py
python scripts/run-pipeline.py --dry-run   # 试运行
python scripts/run-pipeline.py --no-ai     # 禁用AI优化
```

## 系统架构

```
视频源 → douyin-agent (FastAPI, 端口由 CONFIG.md 配置)
    ↓ 提取文案 + AI改写 → chatgroup.db (SQLite)
    ↓
douyin_full_orchestrator.py  ← 核心编排器（路径见 CONFIG.md.orchestrator）
    ↓ 调用
douyin-creator-tools/src/
    publish-douyin-article.mjs  → 抖音长图文
    export-douyin-comments.mjs → 导出评论
    reply-douyin-comments.mjs  → 回复评论
```

## 配置

所有路径集中在 [CONFIG.md](CONFIG.md) 的 JSON 块中。运行 `python scripts/setup.py` 自动检测并生成。

关键路径说明（值均在 CONFIG.md JSON 中）：

| 键 | 说明 |
|---|---|
| `douyin_home` | 项目根目录（包含 douyin-agent-master 和 orchestrator） |
| `orchestrator` | 编排器脚本路径 |
| `agent_backend` | FastAPI 后端目录 |
| `chatgroup_db` | SQLite 数据库路径 |
| `creator_tools` | JS 发布/评论工具目录 |
| `chrome_cdp_port` | Chrome 调试端口（默认 9222） |

## 运营流程（定时 Cron）

编排器每次执行完整流水线：
1. **频率检查** — 每日上限3条，每次间隔 ≥1h
2. **内容筛选** — 从 DB 查询 rank_score ≥0、已完整转写、未发布的 AI/量化相关视频
3. **安全检查** — 金融违规词过滤、内容安全高危词过滤
4. **AI 优化** — 调用 OpenClaw Gateway 将视频脚本转为适合图文阅读的正文
5. **封面生成** — 优先 item 专属封面 → Qenda AI 生成 → 回退到通用封面
6. **发布长图文** — 经 Chrome CDP 操作已登录浏览器
7. **导出评论** → 自动回复（最多 20 条）

## 执行方式

### 方式一：Python 脚本（跨平台）

```bash
# 完整流水线
python scripts/run-pipeline.py

# 试运行 / 禁用AI
python scripts/run-pipeline.py --dry-run
python scripts/run-pipeline.py --no-ai

# 系统健康检查
python scripts/status-check.py
```

### 方式二：定时 Cron（推荐）

由 OpenClaw Cron 触发（参考 `qclaw-cron-skill`），调用：

```bash
python <skill_dir>/scripts/run-pipeline.py
```

### 方式三：直接调用编排器

```bash
python <CONFIG.orchestrator 路径>
```

## 详细内容参考

- **发布配置与安全规则** → [references/publishing.md](references/publishing.md)
- **评论导出与自动回复** → [references/comment-reply.md](references/comment-reply.md)
- **Qenda AI 封面生成** → [references/cover-ai.md](references/cover-ai.md)
- **编排器配置参数** → [references/config-reference.md](references/config-reference.md)

## 快速运维

```bash
# 查看待发队列（路径取自 CONFIG.md）
python -c "
import json, re, sqlite3
config_path = '<skill_dir>/CONFIG.md'
with open(config_path) as f:
    m = re.search(r'```json\s*([\s\S]*?)\s*```', f.read())
    cfg = json.loads(m.group(1))
conn = sqlite3.connect(cfg['chatgroup_db'])
print('Pending:', conn.execute('''SELECT COUNT(*) FROM monitor_items WHERE imagetext_published=0 AND transcript_status=\"full\" AND rank_score>=0''').fetchone()[0])
"

# 检查 Chrome CDP
curl http://localhost:9222/json/version

# 重新配置
python scripts/setup.py
```

## 新平台扩展（小红书）

小红书发布功能已实现但账号已封禁。解封后在编排器中设置 `XHS_ENABLED = True`。

## 常见故障

| 症状 | 可能原因 | 解决 |
|------|---------|------|
| "No items to publish" | DB 无满足条件的项 | 确认 agent 已抓取并改写内容 |
| "No cover image" | 封面目录为空 | 检查 uploads_dir，运行封面生成 |
| "Content unsafe" | 命中安全词过滤 | 检查 FINANCE_BANNED_WORDS |
| CDP 连接失败 | Chrome 未带调试端口启动 | 启动 Chrome `--remote-debugging-port=<port>` |
| 编排器卡住 | 浏览器登录态失效 | 重新扫码登录，更新 cookies |
| "CONFIG.md not configured" | 未运行 setup.py | 运行 `python scripts/setup.py` |
