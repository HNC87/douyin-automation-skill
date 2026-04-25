# 评论导出与自动回复

## 完整流程

编排器 `douyin_full_orchestrator.py` 的 `run()` 在发布完成后自动执行：

```
export_comments() → build_reply_plan() → reply_comments()
```

## 单独导出评论

```powershell
node "C:\Users\Administrator\.openclaw\douyin-creator-tools\src\export-douyin-comments.mjs" `
  --out "C:\Users\Administrator\.openclaw\douyin-creator-tools\comments-output\unreplied-comments.json" `
  --limit 50 `
  --publish-text "发布于2026年04月25日 12:00"
```

## 单独生成回复计划

回复计划在内存中生成，无需单独运行——由 `build_reply_plan()` 函数处理。

## 单独执行回复

```powershell
node "C:\Users\Administrator\.openclaw\douyin-creator-tools\src\reply-douyin-comments.mjs" `
  --limit 20 `
  --keep-open `
  --out "C:\Users\Administrator\.openclaw\douyin-creator-tools\comments-output\reply-result.json" `
  --timeout 600000 `
  -- "C:\Users\Administrator\.openclaw\douyin-creator-tools\comments-output\auto-reply-plan.json"
```

> 注意：回复操作需要**已登录 Chrome 浏览器**，不要加 `--headless`。

## 回复分类规则

| 类型 | 关键词 | 回复风格 |
|------|--------|---------|
| q（问答） | how/what/why/怎么/如何/请问/教程 | 引导看视频/下次覆盖 |
| t（感谢） | thank/great/helpful/有用 | 感谢支持 |
| n（负面） | bad/wrong/fake/垃圾/骗人 | 中性感谢 |
| f（关注） | follow/粉丝/关注 | 欢迎关注 |
| d（默认） | 其他 | 简短肯定 |

## 导入评论到数据库

```powershell
# 导出的评论可手动导入 chatgroup.db
sqlite3 "D:\douyin\douyin-agent-master\backend\app\chatgroup.db" `
  "SELECT * FROM comments LIMIT 10"
```

comments 表结构：
- `item_id` — 关联 monitor_items.id
- `username` — 评论者用户名
- `text` — 评论内容
- `reply_status` — pending/sent/failed
