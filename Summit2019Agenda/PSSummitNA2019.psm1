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
    return @()
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
