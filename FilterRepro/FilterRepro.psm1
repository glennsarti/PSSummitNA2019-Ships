using namespace Microsoft.PowerShell.SHiPS

[SHiPSProvider(UseCache=$false)]
class Root : SHiPSDirectory
{
  Root([string]$name): base($name)
  {
  }

  [object[]] GetChildItem()
  {
    $obj =  @()

    $obj += [ExampleDirectory]::new();

    return $obj;
  }
}

[SHiPSProvider(UseCache=$false)]
class ExampleDirectory : SHiPSDirectory
{
  ExampleDirectory() : base($this.GetType())
  {
  }

  [object[]] GetChildItem()
  {
    $childNames = @('alpha', 'beta', 'gamma', 'delta')
    $obj = New-Object System.Collections.ArrayList($null)

    $filter = $this.ProviderContext.Filter
    Write-Host "Using filter '${filter}'" -ForegroundColor Magenta

    $childNames | ForEach-Object {
      if (($filter -eq '') -or ($_ -match $filter)) {
        $obj.Add([ExampleNode]::new($_))
      }
    }

    return $obj;
  }
}

[SHiPSProvider(UseCache=$false)]
class ExampleNode : SHiPSLeaf
{
  ExampleNode([string]$name): base($name)
  {
    Write-Host "Creating ${name} leaf object" -ForegroundColor Magenta
    $this.Name = $name
  }
}
