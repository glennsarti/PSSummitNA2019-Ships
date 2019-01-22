# Building a PS Summit SHiPS Module

## Step 0

> Close your computer and get out a pencil and paper

Map out your data model - Remember the DAG

```
Root
  |- Speakers
  |   |- Alice
  |   |- Bob
  |   +- Charlie
  |
  +- Agenda
      |- All
      |   |- Session 1
      |   |- Session 2
      |   +- Session 3
      |- Day 1 - Mon
      |   ...
      |- Day 2 - Tue
      |   ...
      |- Day 3 - Wed
      |   ...
      +- Day 4 - Thu
          ...
```

## Step 1

* Create Module Manifest

`RequiredModules = @('SHiPS')`

* Create Module Script file

  - Important `using namespace Microsoft.PowerShell.SHiPS`

  - Create the root object

Just enough so that we can load the module and map a PS Drive

## Step 2

* Create the first level directories

  - We can now see these directories in the root

As per the docs, remember that all SHIPS objects have a constructor with one string parameter which is unique within the parent

> ... types have a constructor with one string parameter, which represents as a node name. The name is mandatory and must be unique under the same parent node

## Step 3

* This module uses a static data file (JSON).  Create a private helper function to load that into memory to speed up searches

* Create the Speaker leaf objects

  - Public properties are seen by the user

  - Not no `Get-ChildItem` method

* Modify the `Speakers` object to output the `Speaker` objects in `Get-ChildItem`.  This is how objects are enumerated by the user

## Step 4

* Create AgendaTrackSummary and AgendaSession objects

  - You can use the same class, but with a different name and private/internal properties to modify what it looks like.  For example, Instead of creating one class for the Sessions on Monday and another for the sessions on Tuesday, we can just a class called AgendaTrack and then filter what sessions it shows.

  - This is an example of using a more complicated constructor.  But notice we still just pass throught the name via `: base($name)`

* Directories can have public properties as well, not just leafs

* We have to use the Session ID for Agenda sessions

  - Session Titles may not be unique

  - Session Titles may contain illegal characters for a Leaf Name

* Also added to the DAG, Agenda by category e.g. Automate All the Things or General

## Step 5

* Add `Get-Content` support to the Leaf objects.  Note that you can't Get-Content on directories

  - Additional method called `[string] GetContent()` which returns a string

## Step 6

* Add cross leaf connections

  - Must be very careful with connecting directories that you don't create circular references e.g.
      `An AgendaSession has speakers` but also `A Speaker has AgendaSessions`, so you could end up in a loop

  - However you can surface properties to the user that gives them hints to links but not creating a direct link.

    > Unfortunately right now, Leafs and Directories don't know "where" they are e.g. you can't get the PSDrive name so you can't create direct links, just hints

  - On Directories you can create properties to simulate Get-Content

  - You can instantiate Leafs and Directories yourself

## Step 7

* Add a formatting file

* Modify the module manifest to use the formatting file

`FormatsToProcess = @('PSSummitNA2019.Format.ps1xml')`

* Use the class names used in SHiPS to create your own default formatting for tables, lists etc.

[about_format.ps1xml](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_format.ps1xml?view=powershell-5.1)

[Writing a PowerShell Formatting File](https://docs.microsoft.com/en-us/powershell/developer/format/writing-a-powershell-formatting-file)

[SHiPS Default formatting](https://github.com/PowerShell/SHiPS/blob/master/src/Modules/SHiPS.formats.ps1xml)
