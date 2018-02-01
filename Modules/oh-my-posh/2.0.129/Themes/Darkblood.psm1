#requires -Version 2 -Modules posh-git

function Write-Theme {

    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    
    Write-Prompt -Object ([char]::ConvertFromUtf32(0x250C)) -ForegroundColor $sl.Colors.PromptSymbolColor
    Write-Segment -content ([Environment]::UserName) -foregroundColor $sl.Colors.PromptForegroundColor

    $prompt = "$user$($sl.PromptSymbols.SegmentForwardSymbol) "

    $status = Get-VCSStatus
    if ($status) {
        $vcsInfo = Get-VcsInfo -status ($status)
        $info = $vcsInfo.VcInfo
        Write-Segment -content $info -foregroundColor $sl.Colors.GitForegroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Segment -content $sl.PromptSymbols.ElevatedSymbol -foregroundColor $sl.Colors.AdminIconForegroundColor
    }

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        Write-Segment -content $sl.PromptSymbols.FailedCommandSymbol -foregroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    Write-Host ''

    # SECOND LINE
    Write-Prompt -Object ([char]::ConvertFromUtf32(0x2514)) -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt = Get-FullPath -dir $pwd
    Write-Prompt -Object $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor $sl.Colors.PromptSymbolColor
    Write-Prompt -Object $prompt -ForegroundColor $sl.Colors.PromptForegroundColor

    if (Test-VirtualEnv) {
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) $($sl.PromptSymbols.SegmentBackwardSymbol)" -ForegroundColor $sl.Colors.PromptSymbolColor        
        Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName)" -ForegroundColor $sl.Colors.VirtualEnvForegroundColor
    }

    if ($with) {
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) $($sl.PromptSymbols.SegmentBackwardSymbol)" -ForegroundColor $sl.Colors.PromptSymbolColor
        Write-Prompt -Object "$($with.ToUpper())" -ForegroundColor $sl.Colors.WithForegroundColor
    }

    Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol)$($sl.PromptSymbols.PromptIndicator)" -ForegroundColor $sl.Colors.PromptSymbolColor
}

function Write-Segment {

    param(
        $content,
        $foregroundColor
    )

    Write-Prompt -Object $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor $sl.Colors.PromptSymbolColor
    Write-Prompt -Object $content -ForegroundColor $foregroundColor
    Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.PromptSymbolColor
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = '>'
$sl.PromptSymbols.SegmentForwardSymbol = ']'
$sl.PromptSymbols.SegmentBackwardSymbol = '['
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::DarkRed
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::White
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkYellow
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Magenta
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White