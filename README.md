# PowerShell-Settings
Improve PowerShell because it's ugly.
<img width="841" alt="powershellscreenshot" src="https://user-images.githubusercontent.com/20848224/35691185-09ea5c70-0735-11e8-9816-fe2e87947f14.PNG">
## Getting Started
### Requirements
For Windows 10:
[virtualenvwrapper-win](https://pypi.python.org/pypi/virtualenvwrapper-win)

For Linux:
[virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/)

> If you are not working with python or not using virtualenvs you can remove the `workon` function from [Microsoft.PowerShell_profile.ps1](https://github.com/BGBRWR/PowerShell-Settings/blob/master/Microsoft.PowerShell_profile.ps1#L1)

### Installing
##### Set your PowerShell execution policy
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
```
##### Install Chocolatey
```
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
```
##### Install Chocolatey packages
```
choco install git.install -y
```
##### Install PowerShell modules
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
**Change `$ThemeSettings.MyThemesLocation` in [Microsoft.PowerShell_profile.ps1](https://github.com/BGBRWR/PowerShell-Settings/blob/master/Microsoft.PowerShell_profile.ps1#L112) to your own '\Documents\WindowsPowerShell\PoshThemes'** e.g.
```
$ThemeSettings.MyThemesLocation = 'C:\Userfiles\awalker\Documents\WindowsPowerShell\PoshThemes'
```

### Install DejaVu Font
[Custom DejaVu Font](https://github.com/BGBRWR/PowerShell-Settings/blob/master/DejaVuSansMono.ttf)

### Setup Enviroment Variables
Add the following to system's PATH in environment variables
```
...\Documents\WindowsPowerShell\Tools\ColorTool
```
Wherever your **`Documents`** folder is located. e.g.
```
C:\Userfiles\awalker\Documents\WindowsPowerShell\Tools\ColorTool
```

Add the following to User Variables in environment variables
```
WORKON_HOME   C:\Repositories\Envs
```
Or wherever you want virtualenvwrapper to put your virtualenvs.


## Settings
#### In PowerShell

Change font to `DejaVuSansMono`.

You can change colors with [ColorTool](https://github.com/Microsoft/console/tree/master/tools/ColorTool).
```
colortool -b 'seti'
```
Extra themes are already included. You can review them [here](https://github.com/mbadolato/iTerm2-Color-Schemes).
#### In VSCode 
```
"terminal.integrated.shell.windows": "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
"terminal.integrated.fontFamily": "DejaVuSansMono",
"terminal.integrated.fontSize": 16
```

## Authors

* **[Austin Walker](https://github.com/BGBRWR)** - *Initial work* - [PowerShellSettings](https://github.com/BGBRWR/PowerShell-Settings)

## Acknowledgments

* [Matthew Hodgkins' Blog](https://hodgkins.io/ultimate-powershell-prompt-and-git-setup)
* [Get-ChildItemColor](https://github.com/joonro/Get-ChildItemColor)
* [ColorTool](https://github.com/Microsoft/console/tree/master/tools/ColorTool)
* [iTerm2-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes)
* [oh-my-posh](https://github.com/JanJoris/oh-my-posh)
* [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
* [FontForge](http://fontforge.github.io/en-US/)
