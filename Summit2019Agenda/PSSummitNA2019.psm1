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

    return $obj;
  }
}
