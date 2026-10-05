param(
    [Parameter(Mandatory = $false)]
    [switch]$SkipSecrets,

    [Parameter(Mandatory = $false)]
    [switch]$SkipSalesforce,

    [Parameter(Mandatory = $false)]
    [switch]$SkipNpm
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Enterprise Security Scan" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$failedChecks = 0

function Write-SecurityResult {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Details = ""
    )

    if ($Passed) {
        Write-Host "[PASS] $Name" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] $Name" -ForegroundColor Red
        $script:failedChecks++
    }

    if ($Details) {
        Write-Host "       $Details"
    }
}

# --------------------------------------------------
# 1. Secret file scan
# --------------------------------------------------

if (-not $SkipSecrets) {

    Write-Host "Scanning repository for potential secret files..."

    $secretExtensions = @(
        "*.pem",
        "*.key",
        "*.p12",
        "*.pfx",
        "*.jks"
    )

    $secretFiles = @()

    foreach ($extension in $secretExtensions) {

        $secretFiles += Get-ChildItem `
            -Path (Join-Path $PSScriptRoot "..") `
            -Filter $extension `
            -Recurse `
            -File `
            -ErrorAction SilentlyContinue
    }

    if ($secretFiles.Count -eq 0) {

        Write-SecurityResult `
            -Name "Secret file scan" `
            -Passed $true
    }
    else {

        Write-SecurityResult `
            -Name "Secret file scan" `
            -Passed $false `
            -Details "Potential secret files detected."
    }
}

# --------------------------------------------------
# 2. .env files
# --------------------------------------------------

$envFiles = Get-ChildItem `
    -Path (Join-Path $PSScriptRoot "..") `
    -Filter ".env*" `
    -Recurse `
    -File `
    -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -notin @(".env.example")
    }

if ($envFiles.Count -eq 0) {

    Write-SecurityResult `
        -Name "Environment secret file scan" `
        -Passed $true
}
else {

    Write-SecurityResult `
        -Name "Environment secret file scan" `
        -Passed $false `
        -Details "Potential .env secret files detected."
}

# --------------------------------------------------
# 3. Common hard-coded secret patterns
# --------------------------------------------------

if (-not $SkipSecrets) {

    $repoRoot = Resolve-Path `
        (Join-Path $PSScriptRoot "..")

    $filesToScan = Get-ChildItem `
        -Path $repoRoot `
        -Recurse `
        -File `
        -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch "\\node_modules\\" -and
            $_.FullName -notmatch "\\.git\\" -and
            $_.Extension -in @(
                ".cls",
                ".trigger",
                ".js",
                ".ts",
                ".json",
                ".yaml",
                ".yml",
                ".ps1",
                ".md"
            )
        }

    $patterns = @(
        "password\s*=",
        "api[_-]?key\s*=",
        "client[_-]?secret\s*=",
        "private[_-]?key\s*=",
        "access[_-]?token\s*=",
        "secret[_-]?key\s*="
    )

    $secretMatches = @()

    foreach ($file in $filesToScan) {

        try {

            $content = Get-Content `
                -Path $file.FullName `
                -Raw `
                -ErrorAction Stop

            foreach ($pattern in $patterns) {

                if ($content -match $pattern) {

                    $secretMatches += $file.FullName
                    break
                }
            }
        }
        catch {
            # Ignore binary/unreadable files.
        }
    }

    if ($secretMatches.Count -eq 0) {

        Write-SecurityResult `
            -Name "Hard-coded secret pattern scan" `
            -Passed $true
    }
    else {

        Write-SecurityResult `
            -Name "Hard-coded secret pattern scan" `
            -Passed $false `
            -Details "$($secretMatches.Count) potential files detected."
    }
}

# --------------------------------------------------
# 4. Git ignore validation
# --------------------------------------------------

$gitignorePath = Join-Path `
    $PSScriptRoot `
    "..\.gitignore"

if (Test-Path $gitignorePath) {

    $gitignore = Get-Content $gitignorePath -Raw

    $requiredPatterns = @(
        ".env",
        "*.pem",
        "*.key",
        "*.p12",
        "*.pfx"
    )

    $missingPatterns = @()

    foreach ($pattern in $requiredPatterns) {

        if ($gitignore -notmatch [regex]::Escape($pattern)) {
            $missingPatterns += $pattern
        }
    }

    if ($missingPatterns.Count -eq 0) {

        Write-SecurityResult `
            -Name ".gitignore security rules" `
            -Passed $true
    }
    else {

        Write-SecurityResult `
            -Name ".gitignore security rules" `
            -Passed $false `
            -Details "Missing: $($missingPatterns -join ', ')"
    }
}
else {

    Write-SecurityResult `
        -Name ".gitignore exists" `
        -Passed $false `
        -Details ".gitignore not found."
}

# --------------------------------------------------
# 5. Salesforce Code Analyzer
# --------------------------------------------------

if (-not $SkipSalesforce) {

    if (Get-Command sf -ErrorAction SilentlyContinue) {

        Write-Host ""
        Write-Host "Running Salesforce Code Analyzer..." `
            -ForegroundColor Cyan

        try {

            sf scanner run `
                --target "force-app" `
                --format table

            if ($LASTEXITCODE -eq 0) {

                Write-SecurityResult `
                    -Name "Salesforce Code Analyzer" `
                    -Passed $true
            }
            else {

                Write-SecurityResult `
                    -Name "Salesforce Code Analyzer" `
                    -Passed $false
            }
        }
        catch {

            Write-SecurityResult `
                -Name "Salesforce Code Analyzer" `
                -Passed $false `
                -Details $_.Exception.Message
        }
    }
    else {

        Write-Host `
            "[SKIP] Salesforce CLI not installed." `
            -ForegroundColor Yellow
    }
}

# --------------------------------------------------
# 6. NPM audit
# --------------------------------------------------

if (-not $SkipNpm) {

    $packageJson = Join-Path `
        $PSScriptRoot `
        "..\package.json"

    if (Test-Path $packageJson) {

        Write-Host ""
        Write-Host "Running npm audit..." `
            -ForegroundColor Cyan

        try {

            npm audit --audit-level=high

            if ($LASTEXITCODE -eq 0) {

                Write-SecurityResult `
                    -Name "NPM dependency audit" `
                    -Passed $true
            }
            else {

                Write-SecurityResult `
                    -Name "NPM dependency audit" `
                    -Passed $false
            }
        }
        catch {

            Write-SecurityResult `
                -Name "NPM dependency audit" `
                -Passed $false `
                -Details $_.Exception.Message
        }
    }
    else {

        Write-Host `
            "[SKIP] package.json not found." `
            -ForegroundColor Yellow
    }
}

# --------------------------------------------------
# 7. Final result
# --------------------------------------------------

Write-Host ""
Write-Host "==========================================" `
    -ForegroundColor Cyan

Write-Host " Security Scan Summary" `
    -ForegroundColor Cyan

Write-Host "==========================================" `
    -ForegroundColor Cyan

Write-Host ""

if ($failedChecks -eq 0) {

    Write-Host "SECURITY SCAN: PASS" `
        -ForegroundColor Green

    exit 0
}
else {

    Write-Host "SECURITY SCAN: FAIL" `
        -ForegroundColor Red

    Write-Host "Failed checks: $failedChecks" `
        -ForegroundColor Red

    exit 1
}