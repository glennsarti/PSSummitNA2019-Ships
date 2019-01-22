# Import the modules
# Strictly speaking the SHiPS import isn't as it should automatically be imported from our module
Write-Output "Import modules..."
Import-Module  SHiPS
Import-Module .\PSSummitNA2019.psd1

# Mimic the default display format of SHiPS objects
function ConvertTo-OldFormat {
  [CmdletBinding()]
  param([parameter(Mandatory=$true,ValueFromPipeline=$true)] [Object]$Value)
  Process { $Value | Select-Object -Property @{Name="Mode"; Expression = {$_.SSItemMode}},@{Name="Name"; Expression = {$_.PSChildName}} }
}

# Create a new PS Drive
Write-Output "Creating drive..."
New-PSDrive -Name Summit2019 -PSProvider SHiPS -root 'PSSummitNA2019#Summit2019' | Out-Null

# Set our location to this new drive
Write-Output "Setting location..."
Set-Location Summit2019:\ | Out-Null

Write-Output "`nExample - Speakers - Before"
Get-ChildItem 'Summit2019:\Speakers' | Select -First 3 | ConvertTo-OldFormat | Format-Table

Write-Output "`nExample - Speakers - After"
Get-ChildItem 'Summit2019:\Speakers' | Select -First 3 | Format-Table

Write-Output "`nExample - Agenda Summary - Before"
Get-ChildItem 'Summit2019:\Agenda' | ConvertTo-OldFormat | Format-Table

Write-Output "`nExample - Agenda Summary - Before"
Get-ChildItem 'Summit2019:\Agenda' | Format-Table

Write-Output "`nExample - Agenda schedule - Before"
Get-ChildItem 'Summit2019:\Agenda\In the Cloud' | Sort-Object -Property Start | Select-Object -First 3 | ConvertTo-OldFormat | Format-List

Write-Output "`nExample - Agenda schedule - After"
Get-ChildItem 'Summit2019:\Agenda\In the Cloud' | Sort-Object -Property Start | Select-Object -First 3 | Format-List
