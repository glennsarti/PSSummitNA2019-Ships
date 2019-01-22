using namespace Microsoft.PowerShell.SHiPS

# Root
[SHiPSProvider(UseCache=$true)]
class Summit2019 : SHiPSDirectory
{
  Summit2019([string]$name): base($name)
  {
  }

  [object[]] GetChildItem()
  {
    $obj =  @()

    $obj += [Speakers]::new('Speakers');
    $obj += [Agenda]::new('Agenda');

    return $obj;
  }
}

# Directory Nodes
# Speakers
[SHiPSProvider(UseCache=$true)]
class Speakers : SHiPSDirectory
{
  Speakers([string]$name): base($name)
  {
  }

  [object[]] GetChildItem()
  {
    $obj = New-Object System.Collections.ArrayList($null)

    (Get-SpeakersObject).items | ForEach-Object -Process {
      $obj.Add([Speaker]::new($_.name, $_))
    }

    return $obj;
  }
}

# Agenda
[SHiPSProvider(UseCache=$true)]
class Agenda : SHiPSDirectory
{
  Agenda([string]$name): base($name)
  {
  }

  [object[]] GetChildItem()
  {
    $obj = New-Object System.Collections.ArrayList($null)

    $obj.Add([AgendaTrackSummary]::new('All', @{ }))
    $obj.Add([AgendaTrackSummary]::new('Day 1 - Mon', @{ 'Day' = 29 }))
    $obj.Add([AgendaTrackSummary]::new('Day 2 - Tue', @{ 'Day' = 30 }))
    $obj.Add([AgendaTrackSummary]::new('Day 3 - Wed', @{ 'Day' = 1 }))
    $obj.Add([AgendaTrackSummary]::new('Day 4 - Thu', @{ 'Day' = 2 }))

    $trackList = @{}
    (Get-SessionsObject).sessions | ForEach-Object -Process {
      $_.tracks | ForEach-Object -Process {
        $trackList[$_.name] = $true
      }
    }
    $trackList.GetEnumerator() | ForEach-Object -Process {
      $obj.Add([AgendaTrackSummary]::new($_.Key, @{ 'Track' = $_.Key }))
    }

    return $obj;
  }
}

# AgendaTrackSummary
[SHiPSProvider(UseCache=$true)]
class AgendaTrackSummary : SHiPSDirectory
{
  [String]$Name;
  [Int]$Sessions;
  [String]$AgendaMarkdown
  Hidden [Hashtable]$Filter;

  AgendaTrackSummary([string]$name, [Hashtable]$filter): base($name)
  {
    $this.Name = $name
    $this.Filter = $filter
    $this.Sessions = (Get-Sessions -Filter $this.Filter | Measure-Object).Count;
    $this.AgendaMarkdown = $this.CreateMarkdown()
  }

  Hidden [string] CreateMarkdown() {
    $markdown = ""
    $lastDay = -1
    $lastStartTime = ""
    Get-Sessions -Filter $this.Filter | Sort-Object -Property start_time | ForEach-Object {
      $start = ConvertFrom-EpochTime -Value $_.start_time
      if ($lastDay -ne $start.Day) {
        $markdown += "# " + $start.ToString('ddd, d MMM') + "`n`n"
        $lastDay = $start.Day   # It's a new day!
        $lastStartTime = ""
      }
      if ($lastStartTime -ne $start.ToString('h:mm tt')) {
        $markdown += "## " + $start.ToString('h:mm tt') + "`n`n"
        $lastStartTime = $start.ToString('h:mm tt')
      }

      $obj =  [AgendaSession]::new($_.id, $_)
      $markdown += $obj.GetContent() + "`n`n"
    }

    if ($markdown -eq "") { $markdown = 'No agenda'}
    return $markdown
  }

  [object[]] GetChildItem()
  {
    $obj = New-Object System.Collections.ArrayList($null)
    Get-Sessions -Filter $this.Filter | ForEach-Object -Process {
      $obj.Add([AgendaSession]::new($_.Id, $_))
    }
    return $obj;
  }
}

# Leaf Nodes
# A Session on the agenda
[SHiPSProvider(UseCache=$true)]
class AgendaSession : SHiPSLeaf
{
  [String]$Id;
  [String]$Name;
  [datetime]$Start;
  [datetime]$End;
  [String]$Location;
  [String]$Description;
  [String]$Speakers

  Hidden [Object] $Data

  AgendaSession([string]$id, $data): base($id)
  {
    $this.Id = $Id
    $this.Data = $data

    $this.Name = $data.name
    $this.Description = Remove-HTML $data.overview
    $this.Start = ConvertFrom-EpochTime -Value $data.start_time
    $this.End = ConvertFrom-EpochTime -Value $data.end_time
    $this.Location = ($data.regions | Select-Object -First 1 | ForEach-Object { $_.name })

    $this.Speakers = $this.Data.item_ids | ForEach-Object -Process {
      $SpeakerID = $_
      Write-Output (Get-SpeakersObject).items | Where-Object { $_.id -eq $SpeakerId } | ForEach-Object { Write-Output $_.name }
    }
  }

  [string] GetContent()
  {
    return "### " + $this.Name + "`n`n" + `
      "Time: " + $this.Start.ToString('hh:mm tt') + "  Location: " + $this.Location + `
      "  Speakers: " + ($this.Speakers -join ", ") + "`n`n" + `
      $this.Description + "`n`n"
  }
}

# A Speaker
[SHiPSProvider(UseCache=$true)]
class Speaker : SHiPSLeaf
{
  [String]$Name;
  [String]$FirstName;
  [String]$LastName;
  [String]$Bio;
  [String[]]$SessionIDs;
  [String[]]$Sessions;
  [int]$NumSessions;
  [String[]]$SessionTimes;

  Speaker ([Int]$Id)
  {
    (Get-SpeakersObject).items | ForEach-Object -Process {
      if ($_.id -eq $Id) { $this.PopulateFromData($_) }
    }
  }

  Speaker ([string]$name, [Object]$data): base($name)
  {
    $this.PopulateFromData($data)
  }

  [void] PopulateFromData([Object]$data) {
    $this.Name = $data.name
    # VERY basic name splitting
    $NameArray = $this.Name -split " ", 2
    $this.FirstName = $NameArray[0]
    $this.LastName = $NameArray[1]
    $this.Bio = Remove-HTML -RawString $data.overview

    $this.Sessions = @()
    $this.SessionIDs = @()
    $this.SessionTimes = @()
    Get-Sessions -Filter @{ 'Speaker' = $data.Id} | ForEach-Object {
      $this.Sessions += $_.name
      $start = (ConvertFrom-EpochTime -Value $_.start_time).ToString("d MMM, hh:mm tt")
      $this.SessionIDs += $_.id
      $this.SessionTimes += $start
    }
    $this.NumSessions = $this.Sessions.Count
  }

  [string] GetContent()
  {
    $content = "# " + $this.Name + "`n`n## Bio`n`n" + $this.Bio + "`n`n## Sessions"
    For ($i = 0; $i -lt $this.SessionTimes.Count; $i++) {
      $content += "`n`n - (" + $this.SessionTimes[$i] + ") " + $this.Sessions[$i]
    }
    return $content
  }
}

# Private Functions

$Script:DataSource = Join-Path -Path $PSScriptRoot -ChildPath 'Data'

Function Get-SpeakersObject {
  if ($Script:SpeakerObject -eq $null) {
    $Script:SpeakerObject = Get-Content -Path (Join-Path -Path $Script:DataSource -ChildPath 'speakers.json') | ConvertFrom-Json
  }
  Write-Output $Script:SpeakerObject
}

Function Get-SessionsObject {
  if ($Script:SessionsObject -eq $null) {
    $Script:SessionsObject = Get-Content -Path (Join-Path -Path $Script:DataSource -ChildPath 'sessions.json') | ConvertFrom-Json
  }
  Write-Output $Script:SessionsObject
}

Function Get-Sessions($Filter) {
  (Get-SessionsObject).sessions | ForEach-Object -Process {
    $thisSession = $_
    $doOutput = $true

    if ($doOutput -and ($Filter['Track'] -ne $null)) {
      $doOutput = ($thisSession.tracks | Where-Object { $_.name -eq $Filter['Track'] }) -ne $null
    }
    if ($doOutput -and ($Filter['Day'] -ne $null)) {
      $Day = (ConvertFrom-EpochTime -Value $thisSession.start_time).Day
      $doOutput = ($Day -eq $Filter['Day'])
    }
    if ($doOutput -and ($Filter['Speaker'] -ne $null)) {
      $doOutput = ($thisSession.item_ids -contains $Filter['Speaker'])
    }

    if ($doOutput) { Write-Output $thisSession }
  }
}

Function ConvertFrom-EpochTime($Value) {
  $BaseTime = [DateTime]::new(1970,1,1,0,0,0,[DateTimeKind]::Utc).AddSeconds($Value)
  $ToTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById('Pacific Standard Time')
  Write-Output ([System.TimeZoneInfo]::ConvertTimeFromUtc($BaseTime, $ToTimeZone))
}

Function Remove-HTML($RawString) {
  $result = $RawString
  $result = $result -replace '<[^>]+>',''
  Write-Output $result
}
