# Import the modules
# Strictly speaking the SHiPS import isn't as it should automatically be imported from our module
Write-Output "Import modules..."
Import-Module  SHiPS
Import-Module .\PSSummitNA2019.psd1

# Create a new PS Drive
Write-Output "Creating drive..."
New-PSDrive -Name Summit2019 -PSProvider SHiPS -root 'PSSummitNA2019#Summit2019' | Out-Null

# Set our location to this new drive
Write-Output "Setting location..."
Set-Location Summit2019:\ | Out-Null

Write-Output "Example - Speaker content"
Get-Content 'Summit2019:\Speakers\Glenn Sarti'

Write-Output "`nExample - Agenda Session content"
Get-Content 'Summit2019:\Agenda\Day 2 - Tue\61451'
