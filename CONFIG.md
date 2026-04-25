# douyin-automation 配置中心
> 技能跨电脑迁移时，只需修改本文件的路径，其他文档无需改动。

## 路径配置（必须根据目标电脑调整）

```json
{
  "orchestrator": "D:\\douyin\\orchestrator\\douyin_full_orchestrator.py",
  "agent_backend": "D:\\douyin\\douyin-agent-master\\backend\\app\\main.py",
  "chatgroup_db": "D:\\douyin\\douyin-agent-master\\backend\\app\\chatgroup.db",
  "uploads_dir": "D:\\douyin\\douyin-agent-master\\backend\\uploads",
  "creator_tools": "C:\\Users\\Administrator\\.openclaw\\douyin-creator-tools",
  "creator_output": "C:\\Users\\Administrator\\.openclaw\\douyin-creator-tools\\comments-output",
  "douyin_cookies": "D:\\douyin\\douyin-agent-master\\backend\\douyin_cookies.json"
}
```

## 运营参数

```json
{
  "max_daily_publish": 3,
  "min_interval_hours": 1,
  "min_rank_score": 0,
  "xhs_enabled": false,
  "ai_optimize_enabled": true,
  "max_comment_replies": 20
}
```

## API 配置

```json
{
  "openclaw_gateway": "http://127.0.0.1:28789",
  "openclaw_model": "openclaw/default",
  "openclaw_token": "<从 openclaw.json 获取>",
  "qenda_api_key": "sk-b31b4c1441fd8c11d6f2f1535b1b37d5394009902df95ae7",
  "qenda_api_base": "https://api.ai6700.com/api/v1/media/generate"
}
```

---

## 跨电脑迁移步骤

1. 将 `douyin-automation` 目录复制到目标电脑的 `~/.qclaw/skills/`
2. 打开本文件，修改上方 JSON 中的所有路径为新电脑的实际路径
3. 同步抖音相关文件（orchestrator、creator-tools、数据库）到新电脑
4. 确认 Chrome 调试端口 9222 可用
5. 重新注册 Cron 任务（参考 qclaw-cron-skill）

## 路径修改快速对照

| 变量名 | 当前值 | 改成... |
|--------|--------|---------|
| `orchestrator` | `D:\douyin\orchestrator\` | 新电脑路径 |
| `chatgroup_db` | `D:\douyin\douyin-agent-master\...` | 新电脑路径 |
| `creator_tools` | `C:\Users\Administrator\.openclaw\...` | 新电脑路径 |
| `uploads_dir` | `D:\douyin\douyin-agent-master\...` | 新电脑路径 |
