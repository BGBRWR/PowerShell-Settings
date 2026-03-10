# PowerShell-Settings

Custom PowerShell profile with a better prompt, colored output, and productivity shortcuts.

## Setup

Run the setup script as Administrator — it handles everything automatically:

```powershell
git clone https://github.com/BGBRWR/PowerShell-Settings
cd PowerShell-Settings
.\setup.ps1
```

The script will:

1. Set execution policy to `RemoteSigned`
2. Install [Chocolatey](https://chocolatey.org/) and git
3. Install [oh-my-posh](https://ohmyposh.dev/) binary via Chocolatey
4. Install required PowerShell modules
5. Symlink `Microsoft.PowerShell_profile.ps1` to `$PROFILE`
6. Apply Windows Terminal settings
7. Install Hack Nerd Font

## What's Installed

| Item                                                                                      | Purpose                                |
| ----------------------------------------------------------------------------------------- | -------------------------------------- |
| [oh-my-posh](https://ohmyposh.dev/)                                                       | Custom prompt                          |
| [posh-git](https://github.com/dahlbyk/posh-git)                                           | Git status in prompt                   |
| [Get-ChildItemColor](https://github.com/joonro/Get-ChildItemColor)                        | Colored `ls` output                    |
| [Microsoft.WinGet.CommandNotFound](https://github.com/microsoft/winget-command-not-found) | Suggests installs for unknown commands |
| [Hack Nerd Font](https://www.nerdfonts.com/)                                              | Nerd Font for prompt glyphs            |

## Profile Reference

### Navigation

| Command      | Description                   |
| ------------ | ----------------------------- |
| `cd -`       | Go back to previous directory |
| `dev`        | `cd C:/dev`                   |
| `catsclient` | `cd C:/dev/cats-frontend`     |

### Build

| Command | Description                                          |
| ------- | ---------------------------------------------------- |
| `clean` | Remove all `obj/` and `bin/` directories recursively |
| `dt`    | Print current datetime as `yyyyMMddHHmmss`           |

### .NET

| Command | Description                           |
| ------- | ------------------------------------- |
| `vs`    | Open `.sln` file in current directory |
| `vsc`   | Open current directory in VS Code     |
| `dr`    | `dotnet restore`                      |
| `drn`   | `dotnet restore --no-cache`           |

### Git

| Command                      | Description                                                                                                               |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `pull [-b <branch>]`         | `git pull`, optionally from a specific branch                                                                             |
| `pull-all`                   | `git pull` every repo in subdirectories                                                                                   |
| `push [-m <msg>] [-ac] [-o]` | Stage, commit, and push. Blocks pushes to master/develop unless `-o`                                                      |
| `branch <name>`              | `git checkout -b <name>` with prefix shorthands: `b/` → `bugfix/`, `f/` → `feature/`, `r/` → `release/`, `h/` → `hotfix/` |
| `stash`                      | `git stash -u`                                                                                                            |
| `pop`                        | `git stash pop`                                                                                                           |
| `git-reset`                  | Hard reset to previous commit and pull                                                                                    |
| `gite`                       | Open GitExtensions                                                                                                        |

### AWS

| Command     | Description                       |
| ----------- | --------------------------------- |
| `aws-login` | `aws sso login --profile default` |

## Authors

- **[Austin Walker](https://github.com/BGBRWR)**
