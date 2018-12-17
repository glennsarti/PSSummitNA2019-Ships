$moduleRoot = $PSScriptRoot

Write-Host "Importing module..."
Import-Module  SHiPS;
Import-Module ".\FilterRepro.psd1"

New-PSDrive -Name Repro -PSProvider SHiPS -root 'FilterRepro#Root' | Out-Null

Set-Location Repro:\ | Out-Null
$VerbosePreference = 'Continue'

Write-Host "Without Filter" -ForegroundColor Yellow
Write-Host "--------------" -ForegroundColor Yellow
Get-ChildItem 'Repro:\ExampleDirectory' | fl

Write-Host "With Empty Filter" -ForegroundColor Yellow
Write-Host "--------------" -ForegroundColor Yellow
Get-ChildItem 'Repro:\ExampleDirectory' -Filter "" | fl

Write-Host "With a Filter" -ForegroundColor Yellow
Write-Host "--------------" -ForegroundColor Yellow
Get-ChildItem 'Repro:\ExampleDirectory' -Filter "e" | fl

Write-Host "--------------" -ForegroundColor Yellow
