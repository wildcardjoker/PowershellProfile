# Get path to My Documents folder
[string] $MyDocsPath = [environment]::getfolderpath(“mydocuments”)
# Get the path to the PowerShell folder
[string] $Path = "$MyDocsPath\WindowsPowerShell"
# Create PowerShell folder if it does not exist.
if (!$(Test-Path $Path))
{
    New-Item -ItemType directory -Path $Path | Out-Null
}
Copy-Item .\Microsoft.PowerShell_profile.ps1 $Profile