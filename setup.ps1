#Requires -Version 5.1
<#
.SYNOPSIS
    Sets up PowerShell-Settings on a new machine.
.DESCRIPTION
    - Sets execution policy
    - Installs Chocolatey and git
    - Installs required PowerShell modules
    - Creates a symlink for the PowerShell profile
    - Creates a symlink for the oh-my-posh theme (atomic.omp.json)
    - Installs the Hack Nerd Font
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
# 4. oh-my-posh (binary, adds to PATH via Chocolatey)
# ---------------------------------------------------------------------------
Write-Step "Checking oh-my-posh"
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Write-Skip "oh-my-posh already installed"
} else {
    Write-Host "    Installing oh-my-posh via Chocolatey..."
    choco install oh-my-posh -y
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
    Write-Done "oh-my-posh installed"
}

# ---------------------------------------------------------------------------
# 5. PowerShell modules
# ---------------------------------------------------------------------------
Write-Step "Installing PowerShell modules"

# Ensure NuGet provider is available
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue | Where-Object Version -ge '2.8.5.201')) {
    Install-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force -Scope CurrentUser | Out-Null
}

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$modules = @('posh-git', 'Get-ChildItemColor', 'Microsoft.WinGet.CommandNotFound')
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
# 6. Profile symlink
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
# 7. Windows Terminal settings
# ---------------------------------------------------------------------------
Write-Step "Applying Windows Terminal settings"

$wtSettingsDir = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
$wtSettingsDest = Join-Path $wtSettingsDir 'settings.json'
$wtSettingsSrc  = Join-Path $scriptDir 'terminal-settings.json'

if (Test-Path $wtSettingsDir) {
    if (Test-Path $wtSettingsDest) {
        Copy-Item $wtSettingsDest "$wtSettingsDest.bak" -Force
        Write-Host "    Backed up existing settings to settings.json.bak"
    }

    Copy-Item $wtSettingsSrc $wtSettingsDest -Force
    Write-Done "Windows Terminal settings applied"
} else {
    Write-Skip "Windows Terminal not installed — skipping"
}

# ---------------------------------------------------------------------------
# 8. Font installation
# ---------------------------------------------------------------------------
Write-Step "Installing Hack Nerd Font"

$hackFontInstalled = Get-ChildItem 'C:\Windows\Fonts' -Filter 'Hack*.ttf' -ErrorAction SilentlyContinue
if ($hackFontInstalled) {
    Write-Skip "Hack Nerd Font already installed"
} else {
    # Do NOT use 'oh-my-posh font install' — when run as Administrator it also
    # writes to Windows Terminal's settings.json, corrupting it for the AppContainer.
    # Install the font directly via the Windows Shell API instead.
    $fontUrl  = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip'
    $fontZip  = Join-Path $env:TEMP 'HackNerdFont.zip'
    $fontDir  = Join-Path $env:TEMP 'HackNerdFont'

    Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip -UseBasicParsing
    Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force

    $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
    foreach ($file in Get-ChildItem $fontDir -Include '*.ttf','*.otf' -Recurse) {
        $fonts.CopyHere($file.FullName, 0x10)
    }
    Remove-Item $fontZip, $fontDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Done "Hack Nerd Font installed"
}

# ---------------------------------------------------------------------------
# 9. oh-my-posh theme symlink (atomic.omp.json)
# ---------------------------------------------------------------------------
Write-Step "Setting up oh-my-posh theme symlink (atomic.omp.json)"

$ompThemesDir = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\themes'
$ompThemeDest = Join-Path $ompThemesDir 'atomic.omp.json'
$ompThemeSrc  = Join-Path $scriptDir 'atomic.omp.json'

if (-not (Test-Path $ompThemeSrc)) {
    Write-Warning "    atomic.omp.json not found in repo at $ompThemeSrc — skipping"
} elseif (-not (Test-Path $ompThemesDir)) {
    Write-Skip "oh-my-posh themes directory not found ($ompThemesDir) — skipping"
} else {
    if (Test-Path $ompThemeDest) {
        $existing = Get-Item $ompThemeDest -Force
        if ($existing.LinkType -eq 'SymbolicLink' -and $existing.Target -eq $ompThemeSrc) {
            Write-Skip "Symlink already points to repo atomic.omp.json"
        } else {
            $backup = "$ompThemeDest.bak"
            Write-Host "    Backing up existing theme to $backup"
            Move-Item $ompThemeDest $backup -Force
            New-Item -ItemType SymbolicLink -Path $ompThemeDest -Target $ompThemeSrc | Out-Null
            Write-Done "Symlink created (old theme backed up)"
        }
    } else {
        New-Item -ItemType SymbolicLink -Path $ompThemeDest -Target $ompThemeSrc | Out-Null
        Write-Done "Symlink created: $ompThemeDest -> $ompThemeSrc"
    }
}

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host "`n===================================================" -ForegroundColor Cyan
Write-Host "  Setup complete! Open a new PowerShell window." -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan
