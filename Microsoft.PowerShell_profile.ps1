<#
 # Powershell Profile
 # Launches when a Powershell window is opened.
 # This script generates Functions for going to common folders, launching applications, and running scripts.
 # Includes Git integration using PoshGit and Github
 # Command prompt modified to show banner.
#>


# Set variables.
[string] $MyDocsPath      = [environment]::getfolderpath(“mydocuments”)
[string] $CodePath        = "$MyDocsPath\GitHub"
[string] $BannerMessage   = "Microsoft Powershell Version $($($PSVersionTable).PSVersion)"
[string] $EditorPath      = "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
[string] $VsCodePath      = "${env:ProgramFiles(x86)}\Microsoft VS Code\code.exe"
[string] $TranscriptPath  = "$myDocsPath\PowerShell Transcripts"
[string] $WindowTitle     = "($env:userdomain\$env:username) - Windows PowerShell" 

$console = $host.ui.RawUI# Set console colours$ConsoleBackgroundColour = [ConsoleColor]::Black$ConsoleForegroundColour = [ConsoleColor]::Gray$GitPromptColour         = [ConsoleColor]::White$ProgressBarBackground   = [ConsoleColor]::DarkGreen$ProgressBarForeground   = [ConsoleColor]::Green$AdminConsoleColur       = [ConsoleColor]::Red# Set console window title.$host.ui.RawUI.WindowTitle = $WindowTitle
# Go to Code Folder
function GoToCode ()
{
    Set-Location $CodePath
}

# Set default Editor
function Edit ($file)
{
    . "$EditorPath" "$file"
}

# Launch Microsoft Visual Studio Code - useful for writing Markdown documents.
function Code ($file)
{
    . "$VsCodePath" "$file"
}

# Generate Heading Separator
function GenerateHeadingSeparator()
{
    [int]    $ConsoleWidth = $console.WindowSize.Width
    [string] $heading = $null
    for($i=0;$i -lt $ConsoleWidth;$i++){$heading +="="}
    return $heading
}

# Display console heading
function DisplayHeading()
{
    [string] $HeadingSeparator = GenerateHeadingSeparator
    Write-Host $HeadingSeparator -NoNewline
    Write-Host $BannerMessage
    Write-Host "Transcript file: $TranscriptPath\$TranscriptName"
    Write-Host $HeadingSeparator
}

# Display all possible colour combinations
function ShowAllColours()
{
    $colours = [enum]::GetValues([System.ConsoleColor])
    foreach( $fcolour in $colours )
    {
        foreach( $bcolour in $colours )
        {
            Write-Host "ForegroundColour is : $fcolour BackgroundColour is : $bcolour "-ForegroundColor $fcolour -BackgroundColor $bcolour
        }
    }
}

# Get status of all Git Repositories in folder.
function GitStatus([string] $Path)
{
    . $CodePath\scripts\Powershell\Get-GitStatus.ps1 -Path $Path
}

# GIT: Push Tags as well as commits
function GPush()
{
    git push
    git push --tags
}

# GIT: Pull Tags as well as commits
function GPull()
{
    git pull
    git pull --tags
}

# GIT: Sync Tags as well as commits
function GSync()
{
    git sync
    git sync --tags
}

# GIT: Update submodules from master
# Checkout Master branch of each subfolder, sync, and continue.
function Update-SubModules()
{
    ls | %{ cd $_.Name; Write-Host -ForegroundColor White $_.Name; git checkout master; git sync; cd .. }
}

# Update Default PowerShell Profile
function Update-Profile()
{
    Copy-Item -Path .\Microsoft.PowerShell_profile.ps1 -Destination $Profile
}

# Is user running as Administrator?
Function global:TEST-LocalAdmin() 
{ 
    Return ([security.principal.windowsprincipal] [security.principal.windowsidentity]::GetCurrent()).isinrole([Security.Principal.WindowsBuiltInRole] "Administrator") 
} 

# Create a filename for Transcript files, allowing them to be sorted by timestamp and/or computer name.
function Get-TranscriptName
{
    $invalidChars = [io.path]::GetInvalidFileNameChars()
    "{0}.{1}.{2}.txt" -f "PowerShell_Transcript",$env:COMPUTERNAME,(Get-Date -Format "yyyyMMHHmm")
}

# Test if running in Powershell Console
Function Test-ConsoleHost
{
    if(($host.Name -match 'consolehost')) {$true} Else {$false}  
}

# If running as Administrator, update Banner.
if (TEST-LocalAdmin)
{
    $BannerMessage = $BannerMessage + " (Administrator)"
}
# Set Console colours$console.BackgroundColor = $ConsoleBackgroundColour$console.ForegroundColor = $ConsoleForegroundColour

# Load posh-git example profile
. (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
. (Resolve-Path "$env:github_posh_git\profile.example.ps1")

# Adjust Git prompt colours
$GitPromptSettings.BeforeForegroundColor     = $GitPromptColour
$GitPromptSettings.DelimForegroundColor      = $GitPromptColour
$GitPromptSettings.AfterForegroundColor      = $GitPromptColour

# Modify Progress Bar colours
$Host.PrivateData.ProgressBackgroundColor    = $ProgressBarBackground
$Host.PrivateData.ProgressForegroundColor    = $ProgressBarForeground

# Set up a simple prompt, adding the git prompt parts inside git repos
# This is copied from the GitPrompt.ps1 file, and replaces the function in that file
# The only difference is that the prompt colour is modified.
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    if (TEST-LocalAdmin)
    {
        $foreColour = $AdminConsoleColur
    }
    else
    {
        $foreColour = $ConsoleForegroundColour
    }
    Write-Host($pwd.ProviderPath) -nonewline -ForegroundColor $foreColour

    Write-VcsStatus

    Write-Host "> " -NoNewline -ForegroundColor $foreColour
    $global:LASTEXITCODE = $realLASTEXITCODE
    return " "
}

# Get a random BOFH excuse
# Pulls excuses from web, stores them in a global variable, then spits out a random one.
# https://www.reddit.com/r/PowerShell/comments/2x8n3y/getexcuse/coz53xa
function Get-Excuse {
    if(!(Get-Variable -Scope Global -Name "excuses" -ErrorAction SilentlyContinue))
    {
        $global:excuses = (Invoke-WebRequest http://pages.cs.wisc.edu/~ballard/bofh/excuses).content.split([Environment]::NewLine)
    }
    Get-Random -InputObject $global:excuses
}

# Clear the BODH Excuses
function Forget-Excuses {
    Remove-Variable -Scope Global -Name "excuses"
}

### Commands to run when console opened
# Go to the code folder, clear the screen, and write a welcome message.
if((Test-Path -Path $TranscriptPath) -eq $false) {mkdir -Path $TranscriptPath}
[string] $TranscriptName  = Get-TranscriptName
Clear-Host
GoToCode
DisplayHeading
# Don't create a transcript for ISE sessions.
if(Test-ConsoleHost) { Start-Transcript -Path (Join-Path -Path $TranscriptPath -ChildPath $($TranscriptName)) | Out-Null}