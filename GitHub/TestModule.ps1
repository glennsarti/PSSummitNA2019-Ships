. .\tmp\MyToken.ps1

Write-Host "Importing module..."
Import-Module  SHiPS;

# For Demo Purposes only
$ENV:UseGithubShipsCache = "True"
Import-Module ".\Github.psd1"

New-PSDrive -Name Github -PSProvider SHiPS -root 'Github#Root' | Out-Null

Set-Location GitHub:\ | Out-Null

Get-ChildItem "Github:\Repositories" | Select-Object -First 3 | Format-Table

Get-ChildItem "Github:\Repositories" | Measure-Object

Get-ChildItem "Github:\Repositories\puppetlabs-powershell\master" | Format-Table

# Diff same file across branches
$f1 = Join-Path -Path $ENV:TEMP -ChildPath 'Master-metadata.json'
$f2 = Join-Path -Path $ENV:TEMP -ChildPath 'Release-metadata.json'

Remove-Item -Path $f1 -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Path $f2 -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

Get-Content "Github:\Repositories\puppetlabs-powershell\master\metadata.json" | Set-Content -Path $f1
Get-Content "Github:\Repositories\puppetlabs-powershell\release\metadata.json" | Set-Content -Path $f2

Read-Host "Press Enter to diff in VS Code" | Out-Null
& code '--diff' $f2 $f1
