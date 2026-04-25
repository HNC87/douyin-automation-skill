# 编排器配置参数详解

## 配置文件位置

编排器没有独立的配置文件，所有常量直接定义在 `douyin_full_orchestrator.py` 顶部。

## 关键常量

```python
# 数据库
AGENT_DB_PATH = r"D:\douyin\douyin-agent-master\backend\app\chatgroup.db"

# Creator 工具路径
CREATOR_TOOLS_DIR = r"C:\Users\Administrator\.openclaw\douyin-creator-tools"
CREATOR_OUTPUT   = r"C:\Users\Administrator\.openclaw\douyin-creator-tools\comments-output"

# 封面/上传目录
UPLOADS_DIR = r"D:\douyin\douyin-agent-master\backend\uploads"

# 发布频率（见 references/publishing.md）
MIN_SCORE = 0
MAX_ITEMS = 1
MIN_PUBLISH_INTERVAL_H = 1
MAX_DAILY_PUBLISH = 3

# AI 优化
OPENCLAW_GATEWAY = "http://127.0.0.1:28789"
OPENCLAW_TOKEN   = "<从 openclaw.json 获取>"
OPENCLAW_MODEL   = "openclaw/default"
AI_OPTIMIZE_TIMEOUT = 30  # 秒

# 小红书（已禁用）
XHS_ENABLED = False

# 内容策略（见 references/publishing.md）
TOPIC_KEYWORDS / EXCLUDE_KEYWORDS / FINANCE_BANNED_WORDS
```

## 修改建议

如果要调整运营策略，**推荐在编排器顶部添加覆盖变量**，而不是直接修改硬编码常量，这样更新时不易丢失：

```python
# === 用户配置覆盖区（放在文件顶部）===
# MAX_DAILY_PUBLISH = 5   # 提高每日发布上限
# XHS_ENABLED = True      # 重新启用小红书
# AI_OPTIMIZE_ENABLED = False  # 禁用AI优化
```

## 状态字段

monitor_items 表中与发布相关的字段：

| 字段 | 含义 |
|------|------|
| `article_published` | 是否已发文章（0/1） |
| `imagetext_published` | 是否已发长图文（0/1） |
| `publish_status` | published / failed:xxx / NULL |
| `publish_time` | 发布时间（ISO格式） |
| `transcript_status` | pending / processing / full |
| `rank_score` | 内容质量评分 |
