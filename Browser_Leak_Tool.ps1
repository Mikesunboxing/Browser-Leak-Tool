if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Please run PowerShell as Administrator." -ForegroundColor Red
    return
}

# --- AUTOMATIC WINDOW RESIZING ---
$headerText = @(
    "=========================================================",
    "               Built by Mikesunboxing LTD                ",
    "       Free to use for Personal or Business use.        ",
    "                 Use at your own risk.                   ",
    "=========================================================",
    "   WINDOWS & BROWSER ROUTER POLICY MANAGER (ALL USERS)   ",
    "=========================================================",
    "1. APPLY  (Prevent Browser DNS Leaks & Respect Static IPs)",
    "2. REMOVE (Revert Windows & Browsers back to default settings)",
    "3. Exit"
)

$maxTextWidth = ($headerText | Measure-Object -Property Length -Maximum).Maximum
$paddingEachSide = 4
$targetWidth = $maxTextWidth + ($paddingEachSide * 2)

try {
    $rawUI = $Host.UI.RawUI
    $currentSize = $rawUI.WindowSize
    if ($targetWidth -gt $rawUI.BufferSize.Width) {
        $rawUI.BufferSize = New-Object System.Management.Automation.Host.Size($targetWidth, $rawUI.BufferSize.Height)
    }
    $rawUI.WindowSize = New-Object System.Management.Automation.Host.Size($targetWidth, $currentSize.Height)
} catch {}

Clear-Host
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "               Built by Mikesunboxing LTD                " -ForegroundColor Yellow
Write-Host "       Free to use for Personal or Business use.        " -ForegroundColor Yellow
Write-Host "                 Use at your own risk.                   " -ForegroundColor Red
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   WINDOWS & BROWSER ROUTER POLICY MANAGER (ALL USERS)   " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "1. APPLY  (Prevent Browser DNS Leaks & Respect Static IPs)" -ForegroundColor Green
Write-Host "2. REMOVE (Revert Windows & Browsers back to default settings)" -ForegroundColor Yellow
Write-Host "3. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Select an option (1, 2, or 3)"

$browsers = "Google\Chrome","Microsoft\Edge","BraveSoftware\Brave","Vivaldi","Opera","DuckDuckGo","Chromium"

if ($choice -eq "1") {
    Write-Host "`n[1/3] Checking Active Network Adapters..." -ForegroundColor Cyan
    
    Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object {
        $adapter =$_
        # Pipe the adapter object directly into Get-NetIPInterface to avoid string expansion bugs
        $dhcpInfo =$adapter | Get-NetIPInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue
        
        if ($dhcpInfo -and$dhcpInfo.Dhcp -eq 'Enabled') {
            Write-Host " - Adapter '$($adapter.Name)': DHCP detected. Enforcing router DNS..." -ForegroundColor Gray
            $adapter | Set-DnsClientServerAddress -ResetServerAddresses -ErrorAction SilentlyContinue
        } else {
            Write-Host " - Adapter '$($adapter.Name)': Static IP detected. Preserving custom IP/Subnet configuration." -ForegroundColor Yellow
        }
    }

    # Disable system-level DoH in Windows
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'EnableAutoDoh' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    Write-Host "`n[2/3] Blocking Browser DNS Leaks via Registry Policies..." -ForegroundColor Cyan
    foreach ($b in $browsers) {
        $p = "HKLM:\SOFTWARE\Policies\$b"
        if (-not (Test-Path $p)) { New-Item $p -Force -ErrorAction SilentlyContinue | Out-Null }
        
        # Turn off browser internal DoH so requests cannot leak to external DoH servers
        Set-ItemProperty $p 'DnsOverHttpsMode' 'off' -Type String
        
        # Ensure built-in DNS client resolves directly via OS adapter without WPAD proxy hangs
        Set-ItemProperty $p 'BuiltInDnsClientEnabled' 1 -Type DWord -ErrorAction SilentlyContinue
        Remove-ItemProperty $p 'ProxyMode' -ErrorAction SilentlyContinue
    }

    # Lock Firefox
    if (-not (Test-Path 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox')) { 
        New-Item 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' -Force -ErrorAction SilentlyContinue | Out-Null 
    }
    # Mode 0 = Disable DoH completely in Firefox
    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' 'DNSOverHTTPS' 0 -Type DWord
    Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' 'ProxyServerMode' -ErrorAction SilentlyContinue

    Write-Host "[3/3] Flushing Resolver Caches..." -ForegroundColor Cyan
    ipconfig /flushdns | Out-Null

    Write-Host "`n[SUCCESS] Settings applied safely without altering static IPs!" -ForegroundColor Green
}
elseif ($choice -eq "2") {
    Write-Host "`n[1/3] Reverting Network Adapters..." -ForegroundColor Cyan
    
    Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object {
        $adapter = $_
        $dhcpInfo = $adapter | Get-NetIPInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue
        
        if ($dhcpInfo -and $dhcpInfo.Dhcp -eq 'Enabled') {
            $adapter | Set-DnsClientServerAddress -ResetServerAddresses -ErrorAction SilentlyContinue
        }
    }

    Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' 'EnableAutoDoh' -ErrorAction SilentlyContinue

    Write-Host "[2/3] Reverting Browser Policies..." -ForegroundColor Cyan
    foreach ($b in $browsers) {
        $p = "HKLM:\SOFTWARE\Policies\$b"
        if (Test-Path $p) {
            Remove-ItemProperty $p 'ProxyMode' -ErrorAction SilentlyContinue
            Remove-ItemProperty $p 'DnsOverHttpsMode' -ErrorAction SilentlyContinue
            Remove-ItemProperty $p 'BuiltInDnsClientEnabled' -ErrorAction SilentlyContinue
        }
    }
    if (Test-Path 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox') {
        Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' 'ProxyServerMode' -ErrorAction SilentlyContinue
        Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' 'DNSOverHTTPS' -ErrorAction SilentlyContinue
    }

    Write-Host "[3/3] Refreshing Network Cache & Renewing IP Lease..." -ForegroundColor Cyan
    ipconfig /flushdns | Out-Null
    ipconfig /renew | Out-Null

    Write-Host "`n[SUCCESS] All settings reverted, DNS flushed, and IP renewed!" -ForegroundColor Green
}
else {
    Write-Host "Exiting." -ForegroundColor Gray
}