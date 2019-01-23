using namespace Microsoft.PowerShell.SHiPS

# Root
[SHiPSProvider(UseCache=$false)]
class Maze : SHiPSDirectory
{
  Hidden [int]$RoomID;

  Maze([string]$name): base($name)
  {
    if (Initialize-Quest) {
      $this.RoomID = $Script:PlayerRoom
    }
  }

  [object[]] GetChildItem()
  {
    $Script:PlayerRoom = $this.RoomID

    $obj =  @()

    $maze = Get-Maze
    $room = $maze[$Script:PlayerRoom]

    if ($room.North) { $obj += [Room]::new('N', $this.RoomID - 7); }
    if ($room.East) { $obj += [Room]::new('E', $this.RoomID + 1); }
    if ($room.South) { $obj += [Room]::new('S', $this.RoomID + 7); }
    if ($room.West) { $obj += [Room]::new('W', $this.RoomID - 1); }
    return $obj;
  }
}

[SHiPSProvider(UseCache=$false)]
class Room : SHiPSDirectory
{
  Hidden [int]$RoomID;

  Room([string]$name, [int]$roomID): base($name)
  {
    $this.RoomID = $roomID
  }

  [object[]] GetChildItem()
  {
    $Script:PlayerRoom = $this.RoomID

    $obj =  @()

    if ($Script:PlayerRoom -eq $Script:TreasureRoom) {
      Write-Host '            _____  _____  _____  _____  _ _ ' -ForegroundColor Yellow
      Write-Host '      /\   |  __ \|  __ \|  __ \|  __ \| | |' -ForegroundColor Yellow
      Write-Host '     /  \  | |__) | |__) | |__) | |__) | | |' -ForegroundColor Yellow
      Write-Host '    / /\ \ |  _  /|  _  /|  _  /|  _  /| | |' -ForegroundColor Yellow
      Write-Host '   / ____ \| | \ \| | \ \| | \ \| | \ \|_|_|' -ForegroundColor Yellow
      Write-Host '  /_/    \_\_|  \_\_|  \_\_|  \_\_|  \_(_|_)' -ForegroundColor Yellow
      Write-Host
      Write-Host ' YOU''VE FOUND THE BOOTY!!' -ForegroundColor Yellow
      return $obj
    }

    if ($Script:PlayerRoom -eq $Script:MonsterRoom) {
      Write-Host '       ___    ___ ________  ___  ___          ________  ________  _______           ________  _______   ________  ________     ' -ForegroundColor Red
      Write-Host '      |\  \  /  /|\   __  \|\  \|\  \        |\   __  \|\   __  \|\  ___ \         |\   ___ \|\  ___ \ |\   __  \|\   ___ \    ' -ForegroundColor Red
      Write-Host '      \ \  \/  / | \  \|\  \ \  \\\  \       \ \  \|\  \ \  \|\  \ \   __/|        \ \  \_|\ \ \   __/|\ \  \|\  \ \  \_|\ \   ' -ForegroundColor Red
      Write-Host '       \ \    / / \ \  \\\  \ \  \\\  \       \ \   __  \ \   _  _\ \  \_|/__       \ \  \ \\ \ \  \_|/_\ \   __  \ \  \ \\ \  ' -ForegroundColor Red
      Write-Host '        \/  /  /   \ \  \\\  \ \  \\\  \       \ \  \ \  \ \  \\  \\ \  \_|\ \       \ \  \_\\ \ \  \_|\ \ \  \ \  \ \  \_\\ \ ' -ForegroundColor Red
      Write-Host '      __/  / /      \ \_______\ \_______\       \ \__\ \__\ \__\\ _\\ \_______\       \ \_______\ \_______\ \__\ \__\ \_______\' -ForegroundColor Red
      Write-Host '     |\___/ /        \|_______|\|_______|        \|__|\|__|\|__|\|__|\|_______|        \|_______|\|_______|\|__|\|__|\|_______|' -ForegroundColor Red
      Write-Host '     \|___|/                                                                                                                   ' -ForegroundColor Red
      Write-Host
      Write-Host ' Black Beard and took the treasure as his. Off to Davy Jones'' locker for you!' -ForegroundColor Red
      return $obj
    }

    Move-Monster

    $maze = Get-Maze
    $room = $maze[$Script:PlayerRoom]

    if ($room.North) { $obj += [Room]::new('N', $this.RoomID - 7); }
    if ($room.East) { $obj += [Room]::new('E', $this.RoomID + 1); }
    if ($room.South) { $obj += [Room]::new('S', $this.RoomID + 7); }
    if ($room.West) { $obj += [Room]::new('W', $this.RoomID - 1); }
    if ($ENV:CHEATMODE) { $obj += [CheatMode]::new('CheatMode'); }
    return $obj;
  }
}

[SHiPSProvider(UseCache=$true)]
class CheatMode : SHiPSLeaf
{
  CheatMode([string]$name): base($name)
  {
  }

  [string] GetContent()
  {
    return (Get-Maze | Out-MazeAsString)
  }
}

# Private Functions
$Script:DataSource = Join-Path -Path $PSScriptRoot -ChildPath 'data\map.csv'

Function Initialize-Quest {
  if ($Script:Initialized -ne $null) {
    Write-Output $false
  } else {
    $Script:Initialized = $true
    Write-Host ' ______   ________  ______    ________   _________  ______        _______   ______   ______   _________  __  __   ' -ForegroundColor Cyan
    Write-Host '/_____/\ /_______/\/_____/\  /_______/\ /________/\/_____/\     /_______/\ /_____/\ /_____/\ /________/\/_/\/_/\  ' -ForegroundColor Cyan
    Write-Host '\:::_ \ \\__.::._\/\:::_ \ \ \::: _  \ \\__.::.__\/\::::_\/_    \::: _  \ \\:::_ \ \\:::_ \ \\__.::.__\/\ \ \ \ \ ' -ForegroundColor Cyan
    Write-Host ' \:(_) \ \  \::\ \  \:(_) ) )_\::(_)  \ \  \::\ \   \:\/___/\    \::(_)  \/_\:\ \ \ \\:\ \ \ \  \::\ \   \:\_\ \ \' -ForegroundColor Cyan
    Write-Host '  \: ___\/  _\::\ \__\: __ `\ \\:: __  \ \  \::\ \   \::___\/_    \::  _  \ \\:\ \ \ \\:\ \ \ \  \::\ \   \::::_\/' -ForegroundColor Cyan
    Write-Host '   \ \ \   /__\::\__/\\ \ `\ \ \\:.\ \  \ \  \::\ \   \:\____/\    \::(_)  \ \\:\_\ \ \\:\_\ \ \  \::\ \    \::\ \' -ForegroundColor Cyan
    Write-Host '    \_\/   \________\/ \_\/ \_\/ \__\/\__\/   \__\/    \_____\/     \_______\/ \_____\/ \_____\/   \__\/     \__\/' -ForegroundColor Cyan
    Write-Host
    Write-Host ' DARE YE ENTER THE MAZE AND FIND THE BOOTY?' -ForegroundColor Cyan
    Write-Host
    Write-Host ' But watch out for Black Beard.  He wants the treasure all to himself' -ForegroundColor Cyan

    $Script:TreasureRoom = Get-Random -Minimum 0 -Maximum 49
    $Script:PlayerRoom = Get-Random -Minimum 0 -Maximum 49
    $Script:MonsterRoom = Get-Random -Minimum 0 -Maximum 49

    $Script:NextMonsterMove = (Get-Date).AddSeconds(2)

    Write-Output $true
  }
}

function Move-Monster {
  if ($Script:NextMonsterMove -ne $null) {
    if ($Script:NextMonsterMove -gt (Get-Date)) { return; }
  }
  $room = (Get-Maze)[$Script:MonsterRoom]
  $options = ''
  # LastMonsterDir is used to weight retracing steps as less chance to happen
  if ($room.North) { if ($Script:LastMonsterDir -ne 'S') { $options += 'NNNN' } else { $options += 'N' } }
  if ($room.East)  { if ($Script:LastMonsterDir -ne 'W') { $options += 'EEEE' } else { $options += 'E' } }
  if ($room.South) { if ($Script:LastMonsterDir -ne 'N') { $options += 'SSSS' } else { $options += 'S' } }
  if ($room.West)  { if ($Script:LastMonsterDir -ne 'E') { $options += 'WWWW' } else { $options += 'W' } }

  $direction = $options.SubString((Get-Random -Maximum $options.Length), 1)

  switch ($direction) {
    'N' { $Script:MonsterRoom = $Script:MonsterRoom - 7 }
    'E' { $Script:MonsterRoom = $Script:MonsterRoom + 1 }
    'S' { $Script:MonsterRoom = $Script:MonsterRoom + 7 }
    'W' { $Script:MonsterRoom = $Script:MonsterRoom - 1 }
  }
  $Script:LastMonsterDir = $direction
  $Script:NextMonsterMove = (Get-Date).AddSeconds(2)

  Write-Host "Black Beard roams around..." -ForegroundColor Yellow
}

Function Get-Maze {
  if ($Script:Maze -eq $null) {
    $CSVObject = Import-CSV -Path $Script:DataSource

    $Script:Maze = @{}
    # The maze is 7x7 grid
    0..48 | ForEach-Object { $Script:Maze[$_] = @{ 'North' = $false; 'East' = $false; 'South' = $false; 'West' = $false; } }
    for ($i = 0; $i -le 12; $i = $i + 2) {
      $roomOffset = ($i / 2 * 7)

      if ($CSVObject[$i].B -eq 'X') {
        $Script:Maze[$roomOffset].East = $true
        $Script:Maze[$roomOffset + 1].West = $true
      }
      if ($CSVObject[$i].D -eq 'X') {
        $Script:Maze[$roomOffset + 1].East = $true
        $Script:Maze[$roomOffset + 2].West = $true
      }
      if ($CSVObject[$i].F -eq 'X') {
        $Script:Maze[$roomOffset + 2].East = $true
        $Script:Maze[$roomOffset + 3].West = $true
      }
      if ($CSVObject[$i].H -eq 'X') {
        $Script:Maze[$roomOffset + 3].East = $true
        $Script:Maze[$roomOffset + 4].West = $true
      }
      if ($CSVObject[$i].J -eq 'X') {
        $Script:Maze[$roomOffset + 4].East = $true
        $Script:Maze[$roomOffset + 5].West = $true
      }
      if ($CSVObject[$i].L -eq 'X') {
        $Script:Maze[$roomOffset + 5].East = $true
        $Script:Maze[$roomOffset + 6].West = $true
      }
    }

    for ($i = 1; $i -le 12; $i = $i + 2) {
      $roomOffset = ( ($i - 1) / 2 * 7)

      if ($CSVObject[$i].A -eq 'X') {
        $Script:Maze[$roomOffset].South = $true
        $Script:Maze[$roomOffset + 7].North = $true
      }
      if ($CSVObject[$i].C -eq 'X') {
        $Script:Maze[$roomOffset + 1].South = $true
        $Script:Maze[$roomOffset + 8].North = $true
      }
      if ($CSVObject[$i].E -eq 'X') {
        $Script:Maze[$roomOffset + 2].South = $true
        $Script:Maze[$roomOffset + 9].North = $true
      }
      if ($CSVObject[$i].G -eq 'X') {
        $Script:Maze[$roomOffset + 3].South = $true
        $Script:Maze[$roomOffset + 10].North = $true
      }
      if ($CSVObject[$i].I -eq 'X') {
        $Script:Maze[$roomOffset + 4].South = $true
        $Script:Maze[$roomOffset + 11].North = $true
      }
      if ($CSVObject[$i].K -eq 'X') {
        $Script:Maze[$roomOffset + 5].South = $true
        $Script:Maze[$roomOffset + 12].North = $true
      }
      if ($CSVObject[$i].M -eq 'X') {
        $Script:Maze[$roomOffset + 6].South = $true
        $Script:Maze[$roomOffset + 13].North = $true
      }
    }
  }
  Write-Output $Script:Maze
}

Function Out-MazeAsString {
  [CmdletBinding()]
  param([parameter(Mandatory=$true,ValueFromPipeline=$true)] [Object]$MazeHash)

  $outString = ""
  0..6 | ForEach-Object {
    $row = $_
    $roomRow = ""
    $connectingRow = ""
    0..6 | ForEach-Object {
      $index = $row*7 + $_
      $room = $MazeHash[$index]
      switch ($index) {
        $Script:TreasureRoom { $roomRow += "◊" }
        $Script:MonsterRoom { $roomRow += "█" }
        $Script:PlayerRoom { $roomRow += "☺"}
        Default { $roomRow += "·"}
      }
      if ($room.East -eq $true) { $roomRow += "─" } else { $roomRow += " " }
      if ($room.South -eq $true) { $connectingRow += "│" } else { $connectingRow += " " }
      $connectingRow += " "
    }
    $outString += "$roomRow`n"
    if ($row -ne 6) { $outString += "$connectingRow`n" }
  }

  Write-Output $outString
}
