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
