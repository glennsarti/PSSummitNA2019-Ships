# Import the modules
# Strictly speaking the SHiPS import isn't as it should automatically be imported from our module
Write-Output "Import modules..."
Import-Module  SHiPS
Import-Module .\PirateBooty.psd1

# Create a new PS Drive
Write-Output "Creating drive..."
New-PSDrive -Name Maze -PSProvider SHiPS -root 'PirateBooty#Maze' | Out-Null

# Set our location to this new drive
Write-Output "Setting location..."
Set-Location Maze:\ | Out-Null
