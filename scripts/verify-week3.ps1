$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "== $Title ==" -ForegroundColor Cyan
}

function Invoke-Check {
    param(
        [string]$Name,
        [scriptblock]$Command,
        [bool]$ShouldPass = $true,
        [string]$MustContain = ""
    )

    $output = ""
    $exitCode = 0

    try {
        $output = (& $Command 2>&1 | Out-String).Trim()
        $exitCode = $LASTEXITCODE
    }
    catch {
        $output = $_.Exception.Message
        $exitCode = 1
    }

    $passed = $false

    if ($ShouldPass) {
        $passed = ($exitCode -eq 0)
        if ($passed -and $MustContain -ne "") {
            $passed = $output -match [regex]::Escape($MustContain)
        }
    }
    else {
        $passed = ($exitCode -ne 0)
    }

    if ($passed) {
        Write-Host "[OK]  $Name" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] $Name" -ForegroundColor Red
        if ($output) {
            Write-Host $output -ForegroundColor DarkGray
        }
    }

    return $passed
}

$allOk = $true

Write-Section "Contenedores levantados"
$services = @("firewall", "dns", "vpn_test", "svc_test", "prod_test", "dev_test")

foreach ($service in $services) {
    $result = Invoke-Check `
        -Name "$service está en ejecución" `
        -Command { docker inspect -f "{{.State.Running}}" $service } `
        -ShouldPass $true `
        -MustContain "true"

    if (-not $result) { $allOk = $false }
}

Write-Section "Resolución DNS"
$result = Invoke-Check `
    -Name "svc_test resuelve web.dev.lab.test -> 172.40.0.2" `
    -Command { docker exec svc_test nslookup web.dev.lab.test 172.20.0.10 } `
    -ShouldPass $true `
    -MustContain "172.40.0.2"
if (-not $result) { $allOk = $false }

$result = Invoke-Check `
    -Name "svc_test resuelve web.prod.lab.test -> 172.30.0.3" `
    -Command { docker exec svc_test nslookup web.prod.lab.test 172.20.0.10 } `
    -ShouldPass $true `
    -MustContain "172.30.0.3"
if (-not $result) { $allOk = $false }

$result = Invoke-Check `
    -Name "dev_test resuelve web.prod.lab.test -> 172.30.0.3" `
    -Command { docker exec dev_test nslookup web.prod.lab.test 172.20.0.10 } `
    -ShouldPass $true `
    -MustContain "172.30.0.3"
if (-not $result) { $allOk = $false }

$result = Invoke-Check `
    -Name "prod_test resuelve web.dev.lab.test -> 172.40.0.2" `
    -Command { docker exec prod_test nslookup web.dev.lab.test 172.20.0.10 } `
    -ShouldPass $true `
    -MustContain "172.40.0.2"
if (-not $result) { $allOk = $false }

$result = Invoke-Check `
    -Name "vpn_test resuelve web.prod.lab.test -> 172.30.0.3" `
    -Command { docker exec vpn_test nslookup web.prod.lab.test 172.20.0.10 } `
    -ShouldPass $true `
    -MustContain "172.30.0.3"
if (-not $result) { $allOk = $false }

Write-Section "Reglas del firewall"
$result = Invoke-Check `
    -Name "FORWARD por defecto está en DROP" `
    -Command { docker exec firewall iptables -L FORWARD -n -v } `
    -ShouldPass $true `
    -MustContain "policy DROP"
if (-not $result) { $allOk = $false }

$result = Invoke-Check `
    -Name "Existe regla services -> development" `
    -Command { docker exec firewall iptables -L FORWARD -n -v } `
    -ShouldPass $true `
    -MustContain "172.20.0.0/24"
if (-not $result) { $allOk = $false }

$result = Invoke-Check `
    -Name "Existe regla development -> services" `
    -Command { docker exec firewall iptables -L FORWARD -n -v } `
    -ShouldPass $true `
    -MustContain "172.40.0.0/24"
if (-not $result) { $allOk = $false }

$result = Invoke-Check `
    -Name "Existe regla DNS desde producción" `
    -Command { docker exec firewall iptables -L FORWARD -n -v } `
    -ShouldPass $true `
    -MustContain "172.20.0.10"
if (-not $result) { $allOk = $false }

Write-Section "Conectividad permitida"
$result = Invoke-Check `
    -Name "services -> development permitido" `
    -Command { docker exec svc_test ping -c 2 172.40.0.2 } `
    -ShouldPass $true
if (-not $result) { $allOk = $false }

$result = Invoke-Check `
    -Name "development -> services permitido" `
    -Command { docker exec dev_test ping -c 2 172.20.0.21 } `
    -ShouldPass $true
if (-not $result) { $allOk = $false }

Write-Section "Conectividad bloqueada"
$result = Invoke-Check `
    -Name "production -> services bloqueado" `
    -Command { docker exec prod_test ping -c 2 172.20.0.21 } `
    -ShouldPass $false
if (-not $result) { $allOk = $false }

$result = Invoke-Check `
    -Name "vpn -> production bloqueado" `
    -Command { docker exec vpn_test ping -c 2 172.30.0.3 } `
    -ShouldPass $false
if (-not $result) { $allOk = $false }

Write-Section "Resultado final"
if ($allOk) {
    Write-Host "Todas las verificaciones han pasado correctamente." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "Hay verificaciones que han fallado." -ForegroundColor Red
    exit 1
}