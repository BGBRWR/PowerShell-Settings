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

#### Clone this repo and copy the files to 



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
### <span style="color:red"> make sure you close and reopen your conslole at this point since your windows enviroment variables have been altered. </span>

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

#### Clone this repo and copy the files to:
```
%USERPROFILE%\Documents\WindowsPowerShell\
```
***note that if this directory doesn't exist yet, make sure that you create it.

**Change `$ThemeSettings.MyThemesLocation` in [Microsoft.PowerShell_profile.ps1](https://github.com/BGBRWR/PowerShell-Settings/blob/master/Microsoft.PowerShell_profile.ps1#L112) to your own '\Documents\WindowsPowerShell\PoshThemes'** e.g.
```
$ThemeSettings.MyThemesLocation = '%USERPROFILE%\Documents\WindowsPowerShell\PoshThemes'
```

### Install DejaVu Font (from the repo you cloned)
[Custom DejaVu Font](https://github.com/BGBRWR/PowerShell-Settings/blob/master/DejaVuSansMono.ttf)

### Setup Enviroment Variables
Add the following to system's PATH in environment variables
```
%USERPROFILE%\Documents\WindowsPowerShell\Tools\ColorTool
```
Wherever your **`Documents`** folder is located. e.g.
```
%USERPROFILE%\Documents\WindowsPowerShell\Tools\ColorTool
```
#### If you haven't already done so, create a 'Envs' folder wherever you want (usually located with your git repos)

Add the following to User Variables in environment variables
```
WORKON_HOME   Wherever you saved created your Envs folder (%USERPROFILE%\Repositories\Envs)
```
Or wherever you want virtualenvwrapper to put your virtualenvs.

### <span style="color:red"> make sure you close and reopen your conslole at this point since your windows enviroment variables have been altered. </span>

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
* [posh-git](https://github.com/dahlbyk/posh-git)
