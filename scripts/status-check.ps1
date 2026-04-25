# Douyin Automation Quick Health Check
# 优先从 CONFIG.md 读取路径
$ErrorActionPreference = "SilentlyContinue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillRoot = Split-Path -Parent $scriptDir
$configFile = Join-Path $skillRoot "CONFIG.md"

# 解析 CONFIG.md
$config = @{}
if (Test-Path $configFile) {
    $blocks = [regex]::Matches((Get-Content $configFile -Raw), '```json\s*([\s\S]*?)\s*```')
    foreach ($b in $blocks) {
        try {
            $json = $b.Groups[1].Value | ConvertFrom-Json -ErrorAction Stop
            $json.PSObject.Properties | ForEach-Object { $config[$_.Name] = $_.Value }
        } catch { continue }
    }
}

$DB       = if ($config.chatgroup_db)   { $config.chatgroup_db }   else { "D:\douyin\douyin-agent-master\backend\app\chatgroup.db" }
$UPLOADS  = if ($config.uploads_dir)     { $config.uploads_dir }    else { "D:\douyin\douyin-agent-master\backend\uploads" }
$CT_DIR   = if ($config.creator_tools)   { $config.creator_tools }  else { "C:\Users\Administrator\.openclaw\douyin-creator-tools" }

Write-Host "=== Douyin Automation Status ===" -ForegroundColor Cyan

# 1. DB
if (Test-Path $DB) {
    $pending = sqlite3 $DB "SELECT COUNT(*) FROM monitor_items WHERE imagetext_published=0 AND article_published=0 AND transcript_status='full' AND rank_score>=0;" 2>$null
    $published = sqlite3 $DB "SELECT COUNT(*) FROM monitor_items WHERE (imagetext_published=1 OR article_published=1) AND publish_time >= date('now','localtime','+8 hours');" 2>$null
    $pColor = if ([int]$pending -gt 0) { 'Yellow' } else { 'Green' }
    Write-Host "[DB] Pending: $pending | Today Published: $published" -ForegroundColor $pColor
} else {
    Write-Host "[DB] NOT FOUND: $DB" -ForegroundColor Red
}

# 2. Chrome CDP
try {
    $cdp = Invoke-RestMethod http://localhost:9222/json/version -TimeoutSec 3
    Write-Host "[CDP] OK - $($cdp.Browser)" -ForegroundColor Green
} catch {
    Write-Host "[CDP] DOWN - Run: chrome.exe --remote-debugging-port=9222" -ForegroundColor Red
}

# 3. 封面
$coverFiles = (Get-ChildItem $UPLOADS -Recurse -File -Include *.jpg,*.png -ErrorAction SilentlyContinue | Measure-Object).Count
$cColor = if ($coverFiles -gt 0) { 'Green' } else { 'Yellow' }
Write-Host "[Cover] Image files in uploads: $coverFiles" -ForegroundColor $cColor

# 4. Creator Tools
$pub = Join-Path $CT_DIR "src\publish-douyin-article.mjs"
$pubColor = if (Test-Path $pub) { 'Green' } else { 'Red' }
Write-Host "[Tools] publish-douyin-article.mjs: $(if(Test-Path $pub){'OK'}else{'MISSING'})" -ForegroundColor $pubColor
