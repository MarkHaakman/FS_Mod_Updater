# Farming Simulator Mod Updater

## What does it do?
This package contains a Batch script that

* checks Git repositories for the latest version of mods,
* installs mods in your mod folder,
* updates your current mods to the latest version from the Git repository.

## Who needs this?
If you are using a Farming Simulator mod which is developed on GitHub and want
to always use the latest version while only needing a few clicks to update
your mod.

## How to use it?
1. [Download](https://github.com/MarkHaakman/cpupdate/archive/master.zip)
the content of this repository and unzip the .zip file in a directory of your
choice.
2. Install [Git](https://git-scm.com/download/win) and
[7-Zip](http://www.7-zip.org/download.html). In an text editor, open the
`FS_Mod_Updater.bat`  script and set the paths to Git and 7-Zip to the correct
locations (Lines 15 -16).
3. Run the `FS_Mod_Updater.bat` script and choose which mod you would like to
update!
4. You could add support for other mods by adding a new mod to `mods.ini`.

## How get rid of it?
Just delete the unzipped directory.
