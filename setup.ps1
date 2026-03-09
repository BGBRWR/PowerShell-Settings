#Requires -Version 5.1
<#
.SYNOPSIS
    Sets up PowerShell-Settings on a new machine.
.DESCRIPTION
    - Sets execution policy
    - Installs Chocolatey and git
    - Installs required PowerShell modules
    - Creates a symlink for the PowerShell profile
    - Installs the DejaVuSansMono font
.NOTES
    Must be run as Administrator.
#>

# ---------------------------------------------------------------------------
# Require elevation
# ---------------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host "Restarting as Administrator..." -ForegroundColor Yellow
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Step { param($msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Skip  { param($msg) Write-Host "    [skip] $msg" -ForegroundColor DarkGray }
function Write-Done  { param($msg) Write-Host "    [done] $msg" -ForegroundColor Green }

# ---------------------------------------------------------------------------
# 1. Execution policy
# ---------------------------------------------------------------------------
Write-Step "Setting execution policy to RemoteSigned"
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
Write-Done "ExecutionPolicy = RemoteSigned (LocalMachine)"

# ---------------------------------------------------------------------------
# 2. Chocolatey
# ---------------------------------------------------------------------------
Write-Step "Checking Chocolatey"
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Skip "Chocolatey already installed"
} else {
    Write-Host "    Installing Chocolatey..."
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Done "Chocolatey installed"
    # Reload PATH so choco is available
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

# ---------------------------------------------------------------------------
# 3. Git
# ---------------------------------------------------------------------------
Write-Step "Checking git"
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Skip "git already installed"
} else {
    Write-Host "    Installing git via Chocolatey..."
    choco install git.install -y
    Write-Done "git installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

# ---------------------------------------------------------------------------
# 4. PowerShell modules
# ---------------------------------------------------------------------------
Write-Step "Installing PowerShell modules"

# Ensure NuGet provider is available
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue | Where-Object Version -ge '2.8.5.201')) {
    Install-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force -Scope CurrentUser | Out-Null
}

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$modules = @('posh-git', 'oh-my-posh', 'Get-ChildItemColor', 'Microsoft.WinGet.CommandNotFound')
foreach ($mod in $modules) {
    if (Get-Module -ListAvailable -Name $mod) {
        Write-Skip "$mod already installed"
    } else {
        Write-Host "    Installing $mod..."
        Install-Module $mod -Scope CurrentUser -Force -AllowClobber
        Write-Done "$mod installed"
    }
}

# ---------------------------------------------------------------------------
# 5. Profile symlink
# ---------------------------------------------------------------------------
Write-Step "Setting up PowerShell profile symlink"

$profileDir = Split-Path $PROFILE
$profileSource = Join-Path $scriptDir 'Microsoft.PowerShell_profile.ps1'

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Write-Done "Created directory: $profileDir"
}

if (Test-Path $PROFILE) {
    $existing = Get-Item $PROFILE -Force
    if ($existing.LinkType -eq 'SymbolicLink' -and $existing.Target -eq $profileSource) {
        Write-Skip "Symlink already points to repo profile"
    } else {
        $backup = "$PROFILE.bak"
        Write-Host "    Backing up existing profile to $backup"
        Move-Item $PROFILE $backup -Force
        New-Item -ItemType SymbolicLink -Path $PROFILE -Target $profileSource | Out-Null
        Write-Done "Symlink created (old profile backed up)"
    }
} else {
    New-Item -ItemType SymbolicLink -Path $PROFILE -Target $profileSource | Out-Null
    Write-Done "Symlink created: $PROFILE -> $profileSource"
}

# ---------------------------------------------------------------------------
# 6. Font installation
# ---------------------------------------------------------------------------
Write-Step "Installing DejaVuSansMono font"

$fontSource = Join-Path $scriptDir 'DejaVuSansMono.ttf'
$fontDest   = 'C:\Windows\Fonts\DejaVuSansMono.ttf'
$fontName   = 'DejaVu Sans Mono (TrueType)'
$fontValue  = 'DejaVuSansMono.ttf'

if (Test-Path $fontDest) {
    Write-Skip "Font already installed at $fontDest"
} else {
    Copy-Item $fontSource $fontDest -Force
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' `
        -Name $fontName -Value $fontValue -Force
    Write-Done "Font installed: $fontName"
}

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host "`n===================================================" -ForegroundColor Cyan
Write-Host "  Setup complete! Open a new PowerShell window." -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan
