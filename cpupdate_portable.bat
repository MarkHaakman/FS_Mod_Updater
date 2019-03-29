@echo off
:: Farming Simulator Mod Updater with Git
::
:: This script installs or updates mods for Farming Simulator which can be downloaded from a Git repository.
:: Copy this file to a folder of your choice and run it from time to time.
::
:: Original cpupdate (version 1.5): copyright by 2016-2018 M. Busche, elpatron@mailbox.org
:: Original code by elpatron68 can be found at https://github.com/elpatron68/cpupdate/
::
:: =============================================================================
:: USER SETTINGS
:: =============================================================================
:: You have to replace these paths with the full path to git.exe and 7z.exe.
::
set gitexe="C:\Program Files\Git\bin\git.exe"
set zipexe="C:\Program Files\7-Zip\7z.exe"
:: =============================================================================
:: If you want the command window to close after run: set autoclose="YES".
:: Otherwise you have to hit a keystroke after the run - which enables you
:: to see what happened.
::
:: set autoclose="YES"
set autoclose="NO"
:: =============================================================================
:: Set Farming Simulator version
::
set fsversion=2019
:: set fsversion=2017
:: =============================================================================
:: END OF USER SETTINGS
:: =============================================================================
:: References:
::
:: Colors: https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
:: Lots of other code stolen from https://stackoverflow.com and other helpful sites.
::
:: Original cpupdate 1.5: copyright by 2016-2018 M. Busche, elpatron@mailbox.org
:: Original code by elpatron68 can be found at https://github.com/elpatron68/cpupdate/
:: =============================================================================
setlocal enabledelayedexpansion

:: Colored text only Win10+
for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
set WINVER=%WINVER:Version =%
if "%WINVER:~0,3%"=="10." (
    set colored=1
) else (
    set colored=0
)

:: Title
if %colored% == 1 (
    echo [97mFarming Simulator Mod Updater[0m
) else (
    echo Farming Simulator Mod Updater
)
echo.

:: Check of Git and 7-Zip are accesible.
%gitexe% --version > NUL
if not %errorlevel%==1 set gitok="-1"
%zipexe% >NUL
if %errorlevel%==9009 goto zipok="-1"
if "%gitok%"=="-1" goto gitziperror
if "%zipok%"=="-1" goto gitziperror

:: Set `Documents` folder.
for /f "skip=2 tokens=2*" %%A in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"') do set "UserDocs=%%B"

::
:: Ask user which mod should be updated.
::
echo Type the name of one of the supported mods you would like to update:
cmd /c .\includes\ini.bat /i gitRepoName mods.ini
set /p gitRepoName="Enter name: "

:: Retrieve the mod paramters from mods.ini
for /F "tokens=* USEBACKQ" %%F IN (`.\includes\ini.bat /s %gitRepoName% /i gitUrl mods.ini`) DO (
    set gitUrl=%%F
)
for /F "tokens=* USEBACKQ" %%F IN (`.\includes\ini.bat /s %gitRepoName% /i modLocationFromRepoRoot mods.ini`) DO (
    set modLocationFromRepoRoot=%%F
)
set modDestinationName=FS19_%gitRepoName%

:: Set mod directory.
SETLOCAL
for /f "delims=" %%i in ('cscript .\includes\getFSModFolder.vbs "%UserDocs%\My Games\FarmingSimulator%fsversion%\gameSettings.xml" //Nologo') do set moddir=%%i

:: Set file destination.
if defined moddir (
    set destination=%moddir%\%modDestinationName%.zip
) else (
    set destination=%UserDocs%\my games\FarmingSimulator%fsversion%\mods\%modDestinationName%.zip
)
echo Your destination is: %destination%

:: Check of this a fresh installation or an update.
if exist "%destination%" (
    set freshinstall="no"
) else (
    set freshinstall="yes"
    echo No previous version found, switching to fresh install mode...
)

:: Extract moddesc.xml from ZIPFILE.
if %freshinstall%=="no" (
    del /q "%TEMP%\moddesc.xml" 2>NUL
    %zipexe% e "%destination%" -o"%TEMP%" moddesc.xml -r -aoa > NUL 2>&1
)
:: Get current mod version with vbs script.
if exist .\%gitRepoName%version.txt (
    del /q .\%gitRepoName%version.txt 1,2>NUL
)

:: Extract moddesc.xml from zip file.
if %freshinstall%=="no" (
    cscript ".\includes\getModVersion.vbs" "%TEMP%\moddesc.xml" //Nologo >.\%gitRepoName%version.txt
)

:: Sleep for 2 seconds.
ping 127.0.0.1 -n 2 > nul

:: Read version from the output file.
if exist .\%gitRepoName%version.txt (
    set /p version=<.\%gitRepoName%version.txt
    set freshinstall="no"
    del /q .\%gitRepoName%version.txt 1,2>NUL
) else (
    set freshinstall="yes"
    set version="0"
)

if %freshinstall%=="no" (
    if %colored% == 1 (
        echo [44mYour currently installed version of %gitRepoName% is: %version%[0m
    ) else (
        echo Your currently installed version of %gitRepoName% is: %version%
    )
)

:: Delete old checkout folder.
rd /s/q .\%gitRepoName% 2> NUL

:: Git clone.
echo Cloning %gitRepoName%...
%gitexe% clone --depth 1 -q %gitUrl%

:: Get new mod version information.
cscript ".\includes\getModVersion.vbs" ".\%gitRepoName%%modLocationFromRepoRoot%modDesc.xml" //Nologo >.\%gitRepoName%version.txt
set /p newversion=<.\%gitRepoName%version.txt
if %colored% == 1 (
    echo [44m%gitRepoName% version from Git: %newversion%[0m
) else (
    echo %gitRepoName% version from Git: %newversion%
)

if exist .\%gitRepoName%version.txt (
    del /q .\%gitRepoName%version.txt 1,2>NUL
)

:: Check if there is an update.
if "%newversion%"=="%version%" if %freshinstall%=="no" (
    if %colored% == 1 (
        echo [44mNo update of %gitRepoName% found, exiting.[0m
    ) else (
        echo No update of %gitRepoName% found, exiting.
    )
    rd /s/q .\%gitRepoName% 2> NUL
    goto ende
) else (
    echo We have found an update.
)

:: Copy the cloned directory to mod folder.
%zipexe% a -r -tzip "%destination%" .\%gitRepoName%%modLocationFromRepoRoot%\* >NUL 2>&1

:: Delete Git clone directory.
rd /s/q .\%gitRepoName% 2> NUL
if %freshinstall% == "no" (
    if %colored% == 1 (
            echo [44mSucessfully updated %gitRepoName% from %version% to %newversion%.[0m
        ) else (
            echo Sucessfully updated %gitRepoName% from %version% to %newversion%.
        )
) else (
    if %colored% == 1 (
            echo [44mSucessfully installed %gitRepoName% version %newversion%[0m
        ) else (
            echo Sucessfully installed %gitRepoName% version %newversion%
        )
)
goto ende

:gitziperror
if "%gitok%"=="-1" (
    echo Git for Windows has to be installed and reside in PATH!
    echo Download: https://git-scm.com/download/win
)
if "%zipok%"=="-1" (
    echo 7-Zip has to be installed and reside in PATH!
    echo Download: http://www.7-zip.org/download.html
)
goto ende

:: Close script.
:ende
echo.
if %autoclose%=="NO" (
    echo ^(Press any key to exit..^)
    pause >NUL
)
