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

Write-Output "`nExample - Speaker properties"
Get-Item 'Summit2019:\Speakers\Glenn Sarti' | Select *

Write-Output "`nExample - Speaker content"
if ($PSVersionTable.PSVersion.Major -ge 6) {
  Get-Content 'Summit2019:\Speakers\Glenn Sarti' | Show-Markdown
} else {
  Get-Content 'Summit2019:\Speakers\Glenn Sarti'
}

Write-Output "`nExample - Agenda properties"
Get-Item 'Summit2019:\Agenda\Day 2 - Tue\61451' | Select *

Write-Output "`nExample - Agenda content"
if ($PSVersionTable.PSVersion.Major -ge 6) {
  Get-Content 'Summit2019:\Agenda\Day 2 - Tue\61451' | Show-Markdown
} else {
  Get-Content 'Summit2019:\Agenda\Day 2 - Tue\61451'
}

Write-Output "`nExample - Daily Agenda "
if ($PSVersionTable.PSVersion.Major -ge 6) {
  (Get-Item 'Summit2019:\Agenda\Day 2 - Tue').AgendaMarkdown | Show-Markdown
} else {
  (Get-Item 'Summit2019:\Agenda\Day 2 - Tue').AgendaMarkdown
}

# Write-Output "`nExample - Daily Agenda to view in code"
# $agendaMd = Join-Path -Path $ENV:Temp -ChildPath 'agenda.md'
# Write-Host $agendaMd
# (Get-Item 'Summit2019:\Agenda\Day 2 - Tue').AgendaMarkdown | Set-Content -Path $agendaMd
# & code $agendaMd

