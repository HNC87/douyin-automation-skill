# Qenda AI 封面生成

## 封面优先级

1. item 专属封面目录：`D:\douyin\douyin-agent-master\backend\uploads\cover_{item_id}\cover.jpg`
2. Qenda AI 生成（基于标题，9:16竖版，4K）
3. 通用封面：`D:\douyin\douyin-agent-master\backend\uploads\*.jpg`

## Qenda API

- 端点：`https://api.ai6700.com/api/v1/media/generate`
- 模型：`wan2.7-image`
- API Key：`sk-b31b4c1441fd8c11d6f2f1535b1b37d5394009902df95ae7`
- 同步等待，最长120s（轮询每5s一次，共24次）
- 输出尺寸：9:16（竖版抖音封面）

## 生成提示词模板

```
抖音视频封面，标题文字「{clean_title}」，
深色科技感背景配渐变光效，左上角标注「AI量化」，
整体氛围专业权威，适合金融科技主题，9:16竖版，4K高清
```

clean_title = 标题中移除 emoji、截断到40字。

## 封面测试命令

```powershell
# 手动触发单条封面生成
$python = @"
import sys; sys.path.insert(0, r'D:\douyin\orchestrator')
from douyin_full_orchestrator import ensure_cover_image, _qenda_generate_cover
print(ensure_cover_image(999, 'AI量化策略实战', None))
"@
python -c $python.Replace("`n", ";").Replace("`r", "")
```

## 常见失败

| 状态 | 原因 | 解决 |
|------|------|------|
| submit failed | API Key 无效或余额不足 | 检查 Qenda 账户 |
| poll timeout | 生成耗时>120s | 手动延长超时或使用已有封面 |
| 无生成权限 | 账户额度用完 | 联系 Qenda 续费 |
