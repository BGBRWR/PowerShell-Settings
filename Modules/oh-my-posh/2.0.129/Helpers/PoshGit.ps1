#requires -Version 2 -Modules posh-git
function Format-BranchName {
    param(
        [string]
        $branchName
    )

    if($spg.BranchNameLimit -gt 0 -and $branchName.Length -gt $spg.BranchNameLimit) {
        $branchName = ' {0}{1} ' -f $branchName.Substring(0, $spg.BranchNameLimit), $spg.TruncatedBranchSuffix
    }
    return " $branchName "
}

function Get-VCSStatus {
    $status = $null
    $vcs_systems = @{
        'posh-git' = 'Get-GitStatus'
        'posh-hg' = 'Get-HgStatus'
        'posh-svn' = 'Get-SvnStatus'
    }

    foreach ($key in $vcs_systems.Keys) {
        $module = Get-Module -Name $key
        if($module -and @($module).Count -gt 0) {
            $status = (Invoke-Expression -Command ($vcs_systems[$key]))
            if ($status) {
                $global:GitStatus = $status
                return $status
            }
        }
    }
    return $status
}


function Get-VcsInfo {
    param(
        [Object]
        $status
    )

    if ($status) {
        $branchStatusBackgroundColor = $sl.Colors.GitDefaultColor

        # Determine Colors
        $localChanges = ($status.HasIndex -or $status.HasUntracked -or $status.HasWorking)
        #Git flags
        $localChanges = $localChanges -or (($status.Untracked -gt 0) -or ($status.Added -gt 0) -or ($status.Modified -gt 0) -or ($status.Deleted -gt 0) -or ($status.Renamed -gt 0))
        #hg/svn flags

        if($localChanges) {
            $branchStatusBackgroundColor = $sl.Colors.GitLocalChangesColor
        }
        if(-not ($localChanges) -and ($status.AheadBy -gt 0)) {
            $branchStatusBackgroundColor = $sl.Colors.GitNoLocalChangesAndAheadColor
        }

        $vcInfo = $sl.GitSymbols.BranchSymbol;
        
        $branchStatusSymbol = $null

        if (!$status.Upstream) {
            $branchStatusSymbol = $sl.GitSymbols.BranchUntrackedSymbol
        }
        elseif ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0) {
            # We are aligned with remote
            $branchStatusSymbol = $sl.GitSymbols.BranchIdenticalStatusToSymbol
        }
        elseif ($status.BehindBy -ge 1 -and $status.AheadBy -ge 1) {
            # We are both behind and ahead of remote
            $branchStatusSymbol = "$($sl.GitSymbols.BranchAheadStatusSymbol)$($status.AheadBy) $($sl.GitSymbols.BranchBehindStatusSymbol)$($status.BehindBy)"
        }
        elseif ($status.BehindBy -ge 1) {
            # We are behind remote
            $branchStatusSymbol = "$($sl.GitSymbols.BranchBehindStatusSymbol)$($status.BehindBy)"
        }
        elseif ($status.AheadBy -ge 1) {
            # We are ahead of remote
            $branchStatusSymbol = "$($sl.GitSymbols.BranchAheadStatusSymbol)$($status.AheadBy)"
        }
        else
        {
            # This condition should not be possible but defaulting the variables to be safe
            $branchStatusSymbol = '?'
        }

        $vcInfo = $vcInfo +  (Format-BranchName -branchName ($status.Branch))

        if ($branchStatusSymbol) {
            $vcInfo = $vcInfo +  ('{0} ' -f $branchStatusSymbol)
        }

        if($spg.EnableFileStatus -and $status.HasIndex) {
            $vcInfo = $vcInfo +  $sl.BeforeIndexSymbol

            if($spg.ShowStatusWhenZero -or $status.Index.Added) {
                $vcInfo = $vcInfo +  "+$($status.Index.Added.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Modified) {
                $vcInfo = $vcInfo +  "~$($status.Index.Modified.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Deleted) {
                $vcInfo = $vcInfo +  "-$($status.Index.Deleted.Count) "
            }

            if ($status.Index.Unmerged) {
                $vcInfo = $vcInfo +  "!$($status.Index.Unmerged.Count) "
            }

            if($status.HasWorking) {
                $vcInfo = $vcInfo +  "$($sl.GitSymbols.DelimSymbol) "
            }
        }

        if($spg.EnableFileStatus -and $status.HasWorking) {
            if($showStatusWhenZero -or $status.Working.Added) {
                $vcInfo = $vcInfo +  "+$($status.Working.Added.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Modified) {
                $vcInfo = $vcInfo +  "~$($status.Working.Modified.Count) "
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Deleted) {
                $vcInfo = $vcInfo +  "-$($status.Working.Deleted.Count) "
            }
            if ($status.Working.Unmerged) {
                $vcInfo = $vcInfo +  "!$($status.Working.Unmerged.Count) "
            }
        }

        if ($status.HasWorking) {
            # We have un-staged files in the working tree
            $localStatusSymbol = $sl.GitSymbols.LocalWorkingStatusSymbol
        }
        elseif ($status.HasIndex) {
            # We have staged but uncommited files
            $localStatusSymbol = $sl.GitSymbols.LocalStagedStatusSymbol
        }
        else {
            # No uncommited changes
            $localStatusSymbol = $sl.GitSymbols.LocalDefaultStatusSymbol
        }

        if ($localStatusSymbol) {
            $vcInfo = $vcInfo +  ('{0} ' -f $localStatusSymbol)
        }

        if ($status.StashCount -gt 0) {
            $vcInfo = $vcInfo +  "$($sl.GitSymbols.BeforeStashSymbol)$($status.StashCount)$($sl.GitSymbols.AfterStashSymbol) "
        }

        if ($WindowTitleSupported -and $spg.EnableWindowTitle) {
            if( -not $Global:PreviousWindowTitle ) {
                $Global:PreviousWindowTitle = $Host.UI.RawUI.WindowTitle
            }
            $repoName = Split-Path -Leaf -Path (Split-Path -Path $status.GitDir)
            $prefix = if ($spg.EnableWindowTitle -is [string]) {
                $spg.EnableWindowTitle
            }
            else {
                ''
            }
            $Host.UI.RawUI.WindowTitle = "$script:adminHeader$prefix$repoName [$($status.Branch)]"
        }

        return New-Object PSObject -Property @{
            BackgroundColor = $branchStatusBackgroundColor
            VcInfo          = $vcInfo.Trim()
        }
    }
}

$spg = $global:GitPromptSettings #Posh-Git settings
$sl = $global:ThemeSettings #local settings