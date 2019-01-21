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
    return @()
  }
}

# Leaf Nodes
# A Speaker
[SHiPSProvider(UseCache=$true)]
class Speaker : SHiPSLeaf
{
  [String]$Name;
  [String]$FirstName;
  [String]$LastName;
  [String]$Bio;

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

Function Remove-HTML($RawString) {
  $result = $RawString
  $result = $result -replace '<[^>]+>',''
  Write-Output $result
}
