param(
  [string]$Path = "."
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path -LiteralPath $Path
Set-Location -LiteralPath $root

function HasFile($relative) {
  Test-Path -LiteralPath (Join-Path $root $relative)
}

$checks = @(
  @{ Name = "package.json"; Ok = HasFile "package.json" },
  @{ Name = "src directory"; Ok = Test-Path -LiteralPath (Join-Path $root "src") },
  @{ Name = "wrangler.jsonc"; Ok = HasFile "wrangler.jsonc" },
  @{ Name = "worker/index.mjs"; Ok = HasFile "worker/index.mjs" },
  @{ Name = "schema.sql"; Ok = HasFile "schema.sql" }
)

foreach ($check in $checks) {
  $mark = if ($check.Ok) { "OK" } else { "MISSING" }
  Write-Output ("[{0}] {1}" -f $mark, $check.Name)
}

if (HasFile "package.json") {
  $pkg = Get-Content -Raw -Path (Join-Path $root "package.json") | ConvertFrom-Json
  if ($pkg.scripts.build) {
    Write-Output "[OK] package.json has build script"
  } else {
    Write-Output "[MISSING] package.json build script"
  }
}

if (HasFile "wrangler.jsonc") {
  $wrangler = Get-Content -Raw -Path (Join-Path $root "wrangler.jsonc")
  if ($wrangler -match '"assets"') { Write-Output "[OK] wrangler assets block found" } else { Write-Output "[MISSING] wrangler assets block" }
  if ($wrangler -match '"d1_databases"') { Write-Output "[OK] wrangler D1 binding block found" } else { Write-Output "[INFO] no D1 binding block" }
  if ($wrangler -match '"main"') { Write-Output "[OK] wrangler Worker main found" } else { Write-Output "[INFO] no Worker main; static-only config possible" }
}
