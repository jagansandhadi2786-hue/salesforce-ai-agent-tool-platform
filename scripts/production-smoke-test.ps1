param(
    [Parameter(Mandatory = $false)]
    [string]$TargetOrgAlias = "prod",

    [Parameter(Mandatory = $false)]
    [string]$BaseUrl,

    [Parameter(Mandatory = $false)]
    [switch]$SkipOrgValidation
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Production Smoke Test" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$failedTests = 0

function Write-TestResult {
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
        $script:failedTests++
    }

    if ($Details) {
        Write-Host "       $Details"
    }
}

function Invoke-SmokeTest {
    param(
        [string]$Name,
        [scriptblock]$Test
    )

    try {
        $result = & $Test

        if ($result -eq $true) {
            Write-TestResult -Name $Name -Passed $true
        }
        else {
            Write-TestResult -Name $Name -Passed $false
        }
    }
    catch {
        Write-TestResult `
            -Name $Name `
            -Passed $false `
            -Details $_.Exception.Message
    }
}

# --------------------------------------------------
# 1. Salesforce CLI validation
# --------------------------------------------------

Invoke-SmokeTest -Name "Salesforce CLI available" -Test {
    $null = Get-Command sf -ErrorAction Stop
    return $true
}

# --------------------------------------------------
# 2. Authenticate / validate target org
# --------------------------------------------------

if (-not $SkipOrgValidation) {

    Invoke-SmokeTest -Name "Validate Salesforce target org" -Test {

        $result = sf org display `
            --target-org $TargetOrgAlias `
            --json 2>$null

        if ($LASTEXITCODE -ne 0) {
            return $false
        }

        $orgInfo = $result | ConvertFrom-Json

        return ($null -ne $orgInfo.result)
    }
}

# --------------------------------------------------
# 3. Determine Salesforce URL
# --------------------------------------------------

if (-not $BaseUrl) {

    try {

        $orgResult = sf org display `
            --target-org $TargetOrgAlias `
            --json

        if ($LASTEXITCODE -eq 0) {

            $orgInfo = $orgResult | ConvertFrom-Json

            if ($orgInfo.result.instanceUrl) {
                $BaseUrl = $orgInfo.result.instanceUrl
            }
        }
    }
    catch {
        Write-Host "Unable to determine Salesforce URL." -ForegroundColor Yellow
    }
}

if ($BaseUrl) {
    Write-Host ""
    Write-Host "Target: $BaseUrl" -ForegroundColor Gray
}

# --------------------------------------------------
# 4. Basic Salesforce query
# --------------------------------------------------

Invoke-SmokeTest -Name "Salesforce API connectivity" -Test {

    $result = sf data query `
        --query "SELECT Id FROM User LIMIT 1" `
        --target-org $TargetOrgAlias `
        --json 2>$null

    if ($LASTEXITCODE -ne 0) {
        return $false
    }

    $queryResult = $result | ConvertFrom-Json

    return ($queryResult.result.totalCount -ge 1)
}

# --------------------------------------------------
# 5. Validate Case object availability
# --------------------------------------------------

Invoke-SmokeTest -Name "Case object available" -Test {

    $result = sf data query `
        --query "SELECT Id FROM Case LIMIT 1" `
        --target-org $TargetOrgAlias `
        --json 2>$null

    if ($LASTEXITCODE -ne 0) {
        return $false
    }

    return $true
}

# --------------------------------------------------
# 6. Optional REST API smoke test
# --------------------------------------------------

if ($BaseUrl) {

    $apiEndpoint = "$BaseUrl/services/data/v65.0/"

    Write-Host ""
    Write-Host "REST endpoint: $apiEndpoint" -ForegroundColor Gray

    Write-Host ""
    Write-Host "API smoke validation is environment dependent." `
        -ForegroundColor Yellow

    Write-Host "Use an authenticated API test here when your" `
        -ForegroundColor Yellow

    Write-Host "production integration endpoint is configured." `
        -ForegroundColor Yellow
}

# --------------------------------------------------
# 7. Final result
# --------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Smoke Test Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

if ($failedTests -eq 0) {

    Write-Host ""
    Write-Host "PRODUCTION SMOKE TEST: PASS" -ForegroundColor Green
    Write-Host ""

    exit 0
}
else {

    Write-Host ""
    Write-Host "PRODUCTION SMOKE TEST: FAIL" -ForegroundColor Red
    Write-Host "Failed tests: $failedTests" -ForegroundColor Red
    Write-Host ""

    exit 1
}