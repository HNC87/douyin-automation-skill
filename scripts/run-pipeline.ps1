# Douyin Automation Pipeline Launcher
# 支持 --dry-run / --no-ai 参数
# 优先读取 CONFIG.md 中的路径配置

param(
    [switch]$DryRun,
    [switch]$NoAI
)

$ErrorActionPreference = "Stop"

# 读取 CONFIG.md 同级的配置
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillRoot = Split-Path -Parent $scriptDir
$configFile = Join-Path $skillRoot "CONFIG.md"

# 解析 CONFIG.md 中的 orchestrator 路径（取第一个 json 代码块中的 orchestrator 字段）
$orchestrator = $null
if (Test-Path $configFile) {
    $blocks = [regex]::Matches((Get-Content $configFile -Raw), '```json\s*([\s\S]*?)\s*```')
    foreach ($b in $blocks) {
        try {
            $json = $b.Groups[1].Value | ConvertFrom-Json -ErrorAction Stop
            if ($json.orchestrator) {
                $orchestrator = $json.orchestrator
                break
            }
        } catch { continue }
    }
}

# 回退到默认路径
if (-not $orchestrator) {
    $orchestrator = "D:\douyin\orchestrator\douyin_full_orchestrator.py"
}

$args = @()
if ($DryRun) { $args += "--dry-run" }
if ($NoAI)    { $args += "--no-ai" }

$start = Get-Date
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Douyin Pipeline START" -ForegroundColor Cyan
Write-Host "[Config] Using: $orchestrator" -ForegroundColor DarkGray

python $orchestrator $args

$exit = $LASTEXITCODE
$duration = [math]::Round(((Get-Date) - $start).TotalSeconds)
$color = if ($exit -eq 0) { 'Green' } else { 'Red' }
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] DONE (exit=$exit, ${duration}s)" -ForegroundColor $color
exit $exit
