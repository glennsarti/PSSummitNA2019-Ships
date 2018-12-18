using namespace Microsoft.PowerShell.SHiPS

# Root
[SHiPSProvider(UseCache=$true)]
class Root : SHiPSDirectory
{
  Root([string]$name): base($name)
  {
    $Script:GithubToken = $ENV:GithubToken
    $Script:GHOwner = $null

    $Script:FileCacheDir = Join-Path -Path $ENV:TEMP -ChildPath 'github_ps_provider'
    $Script:UseFileCache = ($ENV:UseGithubShipsCache -eq "True")

    if ($Script:UseFileCache) {
      # use the file cache is dangerous if you aren't aware of saved credentials
      Write-Warning ("Using the FileCache will save your Github Token, on disk in clear text. " + `
                    "You _PROBABLY_ don't want this.  The cache is really only used when " + `
                    "developing the module because hitting APIs is slow.")
      if (-not(Test-Path -Path $Script:FileCacheDir)) {
        New-Item -Path $Script:FileCacheDir -ItemType Directory -Confirm:$false | Out-Null
      }
    }
  }

  [object[]] GetChildItem()
  {
    $obj =  @()

    $obj += [Repositories]::new();

    return $obj;
  }
}

# Directory Nodes
# Repositories
[SHiPSProvider(UseCache=$true)]
class Repositories : SHiPSDirectory
{
  Repositories() : base($this.GetType())
  {
  }

  [object[]] GetChildItem()
  {
    $obj = New-Object System.Collections.ArrayList($null)

    Get-GHRepositories | ForEach-Object {
      $obj.Add([Repository]::new($_.name, $_))
    }

    return $obj;
  }
}

[SHiPSProvider(UseCache=$true)]
class Repository : SHiPSDirectory
{
  [String]$Name;
  [bool]$Private;
  [String]$Description;
  Hidden [object] $Data;

  Repository([string]$name, [object]$data): base($name)
  {
    $this.Data = $data
    $this.ExtractFromData()
  }

  Hidden [void] ExtractFromData() {
    $this.Name = $this.Data.name
    $this.Private = $this.Data.private
    $this.Description = $this.Data.description
  }

  [object[]] GetChildItem()
  {
    $obj = New-Object System.Collections.ArrayList($null)

    Get-GHBranches -Owner (Get-GHOwner) -RepoName $this.Name | ForEach-Object -Process {
      $obj.Add([Branch]::new($_.name, $this.Name, $_))
    }

    return $obj;
  }
}

[SHiPSProvider(UseCache=$true)]
class Branch : SHiPSDirectory
{
  [String]$Name;
  Hidden [object] $Data;
  Hidden [string] $RepoName;

  Branch([string]$name, [string]$reponame, [object]$data): base($name)
  {
    $this.Data = $data
    $this.RepoName = $reponame
    $this.ExtractFromData()
  }

  Hidden [void] ExtractFromData() {
    $this.Name = $this.Data.name
  }

  [object[]] GetChildItem()
  {
    $obj = New-Object System.Collections.ArrayList($null)

    $content = Get-GHContent -Owner (Get-GHOwner) -RepoName $this.RepoName -Branch $this.Name
    if (-not($content -is [Array])) { $content = @($content) }

    $content | ForEach-Object -Process {
      $item = $_
      switch ($_.type) {
        'file' {
          $obj.Add([GHFile]::new($item.name, $item.path, $this.Name, $this.RepoName, $item))
        }
        'dir' {
          $obj.Add([GHDirectory]::new($item.name, $item.path, $this.Name, $this.RepoName, $item))
        }
        'symlink' {
          $obj.Add([GHSymlink]::new($item.name, $item.path, $this.Name, $this.RepoName, $item))
        }
        'submodule' {
          $obj.Add([GHSubmodule]::new($item.name, $item.path, $this.Name, $this.RepoName, $item))
        }
      }
    }

    return $obj;
  }
}

[SHiPSProvider(UseCache=$true)]
class GHDirectory : SHiPSDirectory
{
  [String]$Name;
  [String]$Type;
  Hidden [object] $Data;
  Hidden [string] $BranchName;
  Hidden [string] $RepoName;
  Hidden [string] $GHPath;

  GHDirectory([string]$Name, [string]$GHPath, [string]$BranchName, [string]$RepoName, [object]$data): base($name)
  {
    $this.Data = $data
    $this.RepoName = $RepoName
    $this.BranchName = $BranchName
    $this.Name = $name
    $this.GHPath = $GHPath
    $this.Type = 'Directory'
  }

  [object[]] GetChildItem()
  {
    $obj = New-Object System.Collections.ArrayList($null)

    $content = Get-GHContent -Owner (Get-GHOwner) -RepoName $this.RepoName -Branch $this.BranchName -ContentPath $this.GHPath
    if (-not($content -is [Array])) { $content = @($content) }

    $content | ForEach-Object -Process {
      $item = $_
      switch ($_.type) {
        'file' {
          $obj.Add([GHFile]::new($item.name, $item.path, $this.BranchName, $this.RepoName, $item))
        }
        'dir' {
          $obj.Add([GHDirectory]::new($item.name, $item.path, $this.BranchName, $this.RepoName, $item))
        }
        'symlink' {
          $obj.Add([GHSymlink]::new($item.name, $item.path, $this.BranchName, $this.RepoName, $item))
        }
        'submodule' {
          $obj.Add([GHSubmodule]::new($item.name, $item.path, $this.BranchName, $this.RepoName, $item))
        }
      }
    }

    return $obj;
  }
}

[SHiPSProvider(UseCache=$true)]
class BaseGHLeafObject : SHiPSLeaf
{
  [String]$Name;
  [String]$Type;
  Hidden [object] $Data;
  Hidden [string] $BranchName;
  Hidden [string] $RepoName;
  Hidden [string] $GHPath;

  BaseGHLeafObject([string]$Name, [string]$GHPath, [string]$BranchName, [string]$RepoName, [object]$data): base($name)
  {
    $this.Name = $name
    $this.Data = $data
    $this.RepoName = $reponame
    $this.BranchName = $BranchName
    $this.GHPath = $GHPath
  }
}

class GHFile : BaseGHLeafObject
{
  [int]$Size;
  Hidden [string]$DownloadURL;

  GHFile([string]$Name, [string]$GHPath, [string]$BranchName, [string]$RepoName, [object]$data):
    base($name, $GHPath, $BranchName, $RepoName, $data)
  {
    $this.Size = $this.Data.size
    $this.DownloadURL = $this.Data.download_url
    $this.Type = 'File'
  }

  [string] GetContent() {
    return (Invoke-DownloadGithubAPI -AbsoluteUri $this.DownloadURL)
  }
}

class GHSymlink : BaseGHLeafObject
{
  [int]$Size;

  GHSymlink([string]$Name, [string]$GHPath, [string]$BranchName, [string]$RepoName, [object]$data):
    base($name, $GHPath, $BranchName, $RepoName, $data)
  {
    $this.Size = $this.Data.size
    $this.Type = 'Symlink'
  }
}


class GHSubmodule : BaseGHLeafObject
{
  [String]$URL;

  GHSubmodule([string]$Name, [string]$GHPath, [string]$BranchName, [string]$RepoName, [object]$data):
    base($name, $GHPath, $BranchName, $RepoName, $data)
  {
    $this.URL = $this.Data.submodule_git_url
    $this.Type = 'Submodule'
  }
}

#---------------------------------------
# Private Helper Functions
#
# Reference
# https://developer.github.com/v3

Function Invoke-GithubAPI {
  [CmdletBinding()]

  Param(
    [Parameter(Mandatory=$True, ParameterSetName='RelativeURI')]
    [String]$RelativeUri,

    [Parameter(Mandatory=$True, ParameterSetName='AbsoluteURI')]
    [String]$AbsoluteUri,

    [Parameter(Mandatory=$False)]
    [switch]$Raw
  )

  if ($PsCmdlet.ParameterSetName -eq 'RelativeURI') {
    $uri = "https://api.github.com" + $RelativeUri

    if ($uri -match "\?") {
      $uri += "&access_token=" + $script:GithubToken
    } else {
      $uri += "?access_token=" + $script:GithubToken
    }
  } else {
    $uri = $AbsoluteUri
  }

  $result = ""
  $cacheFile = Join-Path -Path $Script:FileCacheDir -ChildPath (New-MD5 $uri)
  if ($Script:UseFileCache -and (Test-Path -Path $cacheFile)) {
    $result = Get-Content -Raw $cacheFile | ConvertFrom-JSON
  } else {
    Write-Verbose ("Querying " + (Protect-Output $uri))
    $oldPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    $result = Invoke-WebRequest -Uri $uri -UseBasicParsing
    $ProgressPreference = $oldPreference

    if ($Script:UseFileCache) {
      $result |
        Select-Object Content, RelationLink |
        ConvertTo-JSON -Depth 10 |
        Set-Content -Force -Confirm:$False -Path $cacheFile
    }
  }
  if ($Raw) {
    Write-Output $result
  } else {
    Write-Output $result.Content | ConvertFrom-JSON
  }
}

Function Invoke-DownloadGithubAPI {
  [CmdletBinding()]

  Param(
    [Parameter(Mandatory=$True)]
    [String]$AbsoluteUri
  )

  $oldPreference = $ProgressPreference
  $ProgressPreference = 'SilentlyContinue'
  $result = Invoke-WebRequest -Uri $AbsoluteUri -UseBasicParsing
  $ProgressPreference = $oldPreference

  Write-Output $result.Content
}

Function Invoke-GithubAPIWithPaging($RelativeUri) {
  $response = Invoke-GithubAPI -RelativeUri $RelativeUri -Raw
  $result = $response.Content | ConvertFrom-Json
  if (!($result -is [Array])) { $result = @($result) }
  $nextLink = $response.RelationLink.next
  do {
    if ($nextLink -ne $null) {
      $response = Invoke-GithubAPI -AbsoluteUri $nextLink -Raw
      $result = $result + ($response.Content | ConvertFrom-Json)
      $nextLink = $response.RelationLink.next
    }
  }
  while ($nextLink -ne $null)

  Write-Output $result
}

Function Get-GHRepositories() {
  Invoke-GithubAPIWithPaging '/user/repos?affiliation=owner'
}

Function Get-GHBranches($Owner, $RepoName) {
  Invoke-GithubAPIWithPaging "/repos/${Owner}/${RepoName}/branches"
}

Function Get-GHContent($Owner, $RepoName, $Branch, $ContentPath = "") {
  Invoke-GithubAPIWithPaging "/repos/${Owner}/${RepoName}/contents/${ContentPath}?ref=${Branch}"
}

Function Get-GHOwner() {
  if ([String]::IsNullOrEmpty($Script:GHOwner)) {
    $result = Invoke-GithubAPI -RelativeUri '/user'
    $Script:GHOwner = $result.login
  }
  Write-Output $Script:GHOwner
}

Function Protect-Output($value) {
  $value = $value -replace $script:GithubToken, "xxxxx"
  Write-Output $value
}
## Debug Only
Function New-MD5($String) {
  $StringBuilder = New-Object System.Text.StringBuilder
  [System.Security.Cryptography.HashAlgorithm]::Create('MD5').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) | % {
    [Void]$StringBuilder.Append($_.ToString("x2"))
  }
  $StringBuilder.ToString()
}
