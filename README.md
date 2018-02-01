# PowerShell-Settings
My Personal PowerShell Settings

## Getting Started
### How to install:
Set your PowerShell execution policy
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
```
Install Chocolatey
```
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
```
Install Chocolatey packages
```
choco install git.install -y
```
Install PowerShell modules
```
Install-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
Install-Module Get-ChildItemColor -Scope CurrentUser
```
Or for updating
```
Update-Module powershellget
Update-Module posh-git -Scope CurrentUser
Update-Module oh-my-posh -Scope CurrentUser
Update-Module Get-ChildItemColor -Scope CurrentUser
```
Change *$ThemeSettings.MyThemesLocation* in [Microsfot.PowerShell_profile.ps1](https://github.com/BGBRWR/PowerShell-Settings/blob/master/Microsoft.PowerShell_profile.ps1#L112) to your own '\Documents\WindowsPowerShell\PoshThemes'

#### Install DejaVu Font
