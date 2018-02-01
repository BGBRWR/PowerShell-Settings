function workon {
  # Autocomplete for workon environments
  [CmdletBinding()]
  Param(
      # Any other parameters can go here
  )

  DynamicParam {
            # Set the dynamic parameters' name. You probably want to change this.
            $ParameterName = 'env'

            $WORKON_HOME = [environment]::GetEnvironmentVariable("WORKON_HOME")
           
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

            # Create and set the parameters' attributes. You may also want to change these.
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.Position = 0

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet. You definitely want to change this. This part populates your set. 
            $arrSet = Get-ChildItem -Path C:\Repositories\Envs -Directory | Select-Object -ExpandProperty Name
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
  }

  begin {
        # Bind the parameter to a friendly variable
        $env = $PsBoundParameters[$ParameterName]
  }

  process {
        # Your code goes here
        try {
          if ($env) {
            & $WORKON_HOME\$env\Scripts\activate.ps1
            if (Get-Content $WORKON_HOME\$env\.project) {
              cd (Get-Content $WORKON_HOME\$env\.project)
            }
          } else {
            Write-Error 'Enter a enviroment name.'
            echo "Here are your available enviroments."
            lsvirtualenv
          }
        } catch {
          Write-Error $env' does not exist.'
          echo "Here are your available enviroments."
          lsvirtualenv
        }
  }

    
  
}
# Powershell autocomplete like bash
Set-PSReadlineKeyHandler -Key Tab -Function Complete

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

$env:ConEmuANSI = $True

# Connect to SSH
Start-SshAgent

# Status of Elevated prompt


# ls,ll,dir like Bash
Import-Module Get-ChildItemColor

Set-Alias ls Get-ChildItemColor -option AllScope -Force
Set-Alias ll Get-ChildItemColor -option AllScope -Force
Set-Alias dir Get-ChildItemColor -option AllScope -Force

function cddash {
    if ($args[0] -eq '-') {
        $pwd = $OLDPWD;
    } else {
        $pwd = $args[0];
    }
    $tmp = pwd;

    if ($pwd) {
        Set-Location $pwd;
    }
    Set-Variable -Name OLDPWD -Value $tmp -Scope global;
}
# 'cd -'
# Go back to last location
Set-Alias -Name cd -value cddash -Option AllScope
# Git status summary information that can be displayed in the PowerShell prompt
Import-Module posh-git
Import-Module oh-my-posh
$ThemeSettings.MyThemesLocation = 'C:\Userfiles\awalker\Documents\WindowsPowerShell\PoshThemes'

$ThemeSettings.PromptSymbols             = @{
        StartSymbol                      = ' '        
        TruncatedFolderSymbol            = '..'
        PromptIndicator                  = [char]::ConvertFromUtf32(0xE285)  
        FailedCommandSymbol              = [char]::ConvertFromUtf32(0xF165)        
        ElevatedSymbol                   = [char]::ConvertFromUtf32(0xF0E7)
        SegmentForwardSymbol             = [char]::ConvertFromUtf32(0xE0B0)
        SegmentBackwardSymbol            = [char]::ConvertFromUtf32(0x26A1)
        SegmentSeparatorForwardSymbol    = [char]::ConvertFromUtf32(0x26A1)
        SegmentSeparatorBackwardSymbol   = [char]::ConvertFromUtf32(0x26A1)
        PathSeparator                    = '\'
        VirtualEnvSymbol                 = [char]::ConvertFromUtf32(0xF0FB)
}
$ThemeSettings.GitSymbols                = @{
        BranchSymbol                     = [char]::ConvertFromUtf32(0xF406)
        BeforeStashSymbol                = '{'
        AfterStashSymbol                 = '}'
        DelimSymbol                      = '|'
        LocalWorkingStatusSymbol         = '!'
        LocalStagedStatusSymbol          = '~'
        LocalDefaultStatusSymbol         = ''
        BranchUntrackedSymbol            = [char]::ConvertFromUtf32(0xF071)
        BranchIdenticalStatusToSymbol    = [char]::ConvertFromUtf32(0xF039)
        BranchAheadStatusSymbol          = [char]::ConvertFromUtf32(0xF431)
        BranchBehindStatusSymbol         = [char]::ConvertFromUtf32(0xF433)
}
Set-Theme mytheme

# $ThemeSettings.Colors.VirtualEnvBackgroundColor = [ConsoleColor]::DarkYellow
