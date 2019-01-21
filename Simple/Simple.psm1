using namespace Microsoft.PowerShell.SHiPS

# Root
class Parent : SHiPSDirectory
{
  Parent([string]$name): base($name) { }
  [object[]] GetChildItem()
  {
    return [Child]::new("Child");
  }
}

class Child : SHiPSLeaf
{
  Child($name): base($name) { }
}
