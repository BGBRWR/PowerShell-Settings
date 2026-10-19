Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) {
    Import-Module $ChocolateyProfile
}

Import-Module Get-ChildItemColor
Import-Module posh-git
Import-Module -Name Microsoft.WinGet.CommandNotFound

Set-Alias ls  Get-ChildItemColor -Option AllScope -Force
Set-Alias ll  Get-ChildItemColor -Option AllScope -Force
Set-Alias dir Get-ChildItemColor -Option AllScope -Force
Set-Alias find 'C:/Program Files/git/usr/bin/find.exe'

# Config path must be absolute - newer oh-my-posh no longer falls back silently when a relative path misses
$ompThemePath = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\themes\atomic.omp.json'
if (-not (Test-Path $ompThemePath)) {
    $ompThemePath = Join-Path $PSScriptRoot 'atomic.omp.json'
}
oh-my-posh init pwsh --config $ompThemePath | Invoke-Expression

$global:OLDPWD = $PWD

function cddash {
    if ($args[0] -eq '-') {
        $pwd = $OLDPWD
    } else {
        $pwd = $args[0]
    }
    $tmp = $PWD
    if ($pwd) { Set-Location $pwd }
    $global:OLDPWD = $tmp
}
Set-Alias -Name cd -Value cddash -Option AllScope

## NAVIGATION

function dev { Set-Location 'C:/dev' }

function catsclient { Set-Location 'C:/dev/cats-frontend' }

## BUILD HELPERS

function cleanobj {
    Get-ChildItem . -Include obj,bin -Recurse -Force | Remove-Item -Recurse -Force
}

function dt { Get-Date -Format "yyyyMMddHHmmss" }

## DOTNET HELPERS

function vs  { & ./*.sln }
function vsc { code . }
function dr  { dotnet restore }
function drn { dotnet restore --no-cache }

## GIT HELPERS

function gite { & 'C:/Program Files (x86)/GitExtensions/GitExtensions.exe' }

function git-reset {
    git fetch
    git reset --hard HEAD~1
    git clean -d -f
    git pull
}

function pull {
    param ([alias("b")][string] $branchName)
    if (![string]::IsNullOrEmpty($branchName)) {
        git pull origin $branchName
    } else {
        git pull
    }
}

function pull-all {
    Write-Host "Running the Git Pull All tool..."
    Write-Host "Note: This tool will call 'git pull' for each git repository under it." -ForegroundColor Cyan
    Push-Location .
    Write-Host "`nParent Directory: $PSScriptRoot" -ForegroundColor Cyan
    foreach ($path in Get-ChildItem) {
        if ($path.PSIsContainer) {
            Write-Host "`nChild Directory: $($path.FullName)" -ForegroundColor Cyan
            Set-Location $path.FullName
            if (git rev-parse --git-dir 2>$null) {
                Write-Host "Getting latest..." -ForegroundColor Green
                pull
            } else {
                Write-Host "Not a Git repository. Skipping..." -ForegroundColor Yellow
            }
        }
    }
    Pop-Location
}

function stash { git stash -u }
function pop   { git stash pop }

function branch {
    param ([alias("b")][string] $branchName)
    if    ($branchName.StartsWith("b/")) { $branchName = "bugfix/$($branchName.Substring(2))" }
    elseif ($branchName.StartsWith("f/")) { $branchName = "feature/$($branchName.Substring(2))" }
    elseif ($branchName.StartsWith("r/")) { $branchName = "release/$($branchName.Substring(2))" }
    elseif ($branchName.StartsWith("h/")) { $branchName = "hotfix/$($branchName.Substring(2))" }
    git checkout -b $branchName
    Write-Host "git checkout -b $branchName"
}

function push {
    param (
        [alias("m")][string] $message,
        [alias("ac")][switch] $allowConfigs,
        [alias("o")][switch] $override
    )
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    if (!$branch) { throw [System.ArgumentException] "Can't push to a non-branch!" }

    if ($branch -ieq "master" -or $branch -ieq "develop") {
        if ($override) {
            Write-Host "WARNING!!! You just pushed directly to master/develop!" -ForegroundColor Yellow
        } else {
            throw [System.ArgumentException] "Not allowed to push directly to master/develop!"
        }
    }

    if (![string]::IsNullOrEmpty($message)) {
        git add -A
        if (-not $allowConfigs) {
            git reset *.json
            git reset *.config
        }
        git commit -m $message
    }

    git push --set-upstream origin $branch
    Write-Host "git push --set-upstream origin $branch" -ForegroundColor Cyan
}

## AWS

function aws-login { aws sso login --profile default }

Write-Host
Write-Host "Welcome PowerShell Master, $([Environment]::UserName)."
Write-Host
