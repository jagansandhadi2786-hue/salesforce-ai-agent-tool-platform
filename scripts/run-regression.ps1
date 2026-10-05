param(
    [Parameter(Mandatory = $false)]
    [string]$TargetOrgAlias = "qa",

    [Parameter(Mandatory = $false)]
    [ValidateSet("RunLocalTests", "RunSpecifiedTests", "RunAllTestsInOrg")]
    [string]$TestLevel = "RunLocalTests",

    [Parameter(Mandatory = $false)]
    [string[]]$Tests,

    [Parameter(Mandatory = $false)]
    [switch]$SkipApex,

    [Parameter(Mandatory = $false)]
    [switch]$SkipNpm,

    [Parameter(Mandatory = $false)]
    [switch]$SkipAI
)

$ErrorActionPreference = "Stop"

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$resultsDirectory = Join-Path `
    $PSScriptRoot `
    "..\tests\evidence\regression"

New-Item `
    -ItemType Directory `
    -Force `
    -Path $resultsDirectory | Out-Null

$summaryFile = Join-Path `
    $resultsDirectory `
    "regression-$timestamp.txt"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Enterprise Regression Suite" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

"Regression Test Run: $timestamp" | Out-File $summaryFile
"Target Org: $TargetOrgAlias" | Out-File $summaryFile -Append

$failedSuites = 0

function Run-Suite {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    Write-Host ""
    Write-Host "------------------------------------------" `
        -ForegroundColor DarkCyan

    Write-Host "Running: $Name" -ForegroundColor Cyan

    Write-Host "------------------------------------------"

    try {

        & $Command

        if ($LASTEXITCODE -ne 0) {
            throw "Suite returned exit code $LASTEXITCODE"
        }

        Write-Host "[PASS] $Name" -ForegroundColor Green
        "PASS - $Name" | Out-File $summaryFile -Append
    }
    catch {

        Write-Host "[FAIL] $Name" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red

        "FAIL - $Name" | Out-File $summaryFile -Append

        $script:failedSuites++
    }
}

# --------------------------------------------------
# 1. Salesforce Apex tests
# --------------------------------------------------

if (-not $SkipApex) {

    if ($TestLevel -eq "RunSpecifiedTests") {

        if (-not $Tests -or $Tests.Count -eq 0) {

            Write-Host `
                "RunSpecifiedTests requires -Tests." `
                -ForegroundColor Red

            exit 1
        }

        Run-Suite `
            -Name "Salesforce specified Apex tests" `
            -Command {

                sf apex run test `
                    --target-org $TargetOrgAlias `
                    --test-level RunSpecifiedTests `
                    --tests $Tests `
                    --wait 30 `
                    --result-format human
            }
    }
    else {

        Run-Suite `
            -Name "Salesforce Apex regression tests" `
            -Command {

                sf apex run test `
                    --target-org $TargetOrgAlias `
                    --test-level $TestLevel `
                    --wait 30 `
                    --result-format human
            }
    }
}

# --------------------------------------------------
# 2. Node / JavaScript tests
# --------------------------------------------------

if (-not $SkipNpm) {

    if (Test-Path (Join-Path $PSScriptRoot "..\package.json")) {

        Run-Suite `
            -Name "JavaScript / LWC tests" `
            -Command {

                npm test -- --runInBand
            }
    }
    else {

        Write-Host `
            "[SKIP] package.json not found." `
            -ForegroundColor Yellow
    }
}

# --------------------------------------------------
# 3. AI evaluation
# --------------------------------------------------

if (-not $SkipAI) {

    $aiDirectory = Join-Path `
        $PSScriptRoot `
        "..\tests\ai-evaluation"

    if (Test-Path $aiDirectory) {

        Write-Host ""
        Write-Host "AI evaluation dataset detected." `
            -ForegroundColor Cyan

        Write-Host "Execute the project-specific AI evaluation runner here."

        "INFO - AI evaluation dataset detected" |
            Out-File $summaryFile -Append
    }
    else {

        Write-Host `
            "[SKIP] AI evaluation directory not found." `
            -ForegroundColor Yellow
    }
}

# --------------------------------------------------
# 4. Final summary
# --------------------------------------------------

Write-Host ""
Write-Host "==========================================" `
    -ForegroundColor Cyan

Write-Host " Regression Summary" -ForegroundColor Cyan

Write-Host "==========================================" `
    -ForegroundColor Cyan

Write-Host ""
Write-Host "Results: $summaryFile"

if ($failedSuites -eq 0) {

    Write-Host ""
    Write-Host "REGRESSION SUITE: PASS" `
        -ForegroundColor Green

    exit 0
}
else {

    Write-Host ""
    Write-Host "REGRESSION SUITE: FAIL" `
        -ForegroundColor Red

    Write-Host "Failed suites: $failedSuites" `
        -ForegroundColor Red

    exit 1
}