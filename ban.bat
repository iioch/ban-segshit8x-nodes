@ECHO Off
setlocal enabledelayedexpansion 
Title ## Ban segshit8x-nodes ##
mode con:cols=100 lines=1500
COLOR 8F
pushd %~dp0
echo.
REM SET BANTIME HERE
SET BANTIME=5186000
set /a DAYS=24*3600
set /a BANTIMEINDAYS=%BANTIME% / %DAYS%
echo Ban time is set to %BANTIME% seconds or %BANTIMEINDAYS% days
echo write ban.ps1
echo.
REM THIS WRITES A ban.ps1 FILE
echo # helper to turn PSCustomObject into a list of key/value pairs > ban.ps1
echo function Get-ObjectMembers { >> ban.ps1
echo [CmdletBinding()] >> ban.ps1
echo Param( >> ban.ps1
echo [Parameter(Mandatory=$True, ValueFromPipeline=$True)] >> ban.ps1
echo [PSCustomObject]$obj >> ban.ps1
echo ) >> ban.ps1
echo $obj ^| Get-Member -MemberType NoteProperty ^| ForEach-Object { >> ban.ps1
echo $key = $_.Name >> ban.ps1
echo [PSCustomObject]@{Key = $key; Value = $obj."$key"} >> ban.ps1
echo } >> ban.ps1
echo } >> ban.ps1
echo. >> ban.ps1
echo # Script starts here. >> ban.ps1
echo $BAN_TIME = %BANTIME%; >> ban.ps1
echo. >> ban.ps1
echo # Download the latest nodes snapshot >> ban.ps1
echo $request = "https://bitnodes.21.co/api/v1/snapshots"; >> ban.ps1
echo. >> ban.ps1
echo $firstSnapshotUrl = Invoke-WebRequest $request ^| >> ban.ps1
echo ConvertFrom-Json  ^| >> ban.ps1
echo select -expand results  ^|  >> ban.ps1
echo select url -First 1 # Select the first snapshot. >> ban.ps1
echo. >> ban.ps1
echo $COUNT=0 >> ban.ps1
echo. >> ban.ps1
echo Invoke-WebRequest $firstSnapshotUrl.url ^|   # Download the snapshot JSON >> ban.ps1
echo ConvertFrom-Json ^| >> ban.ps1
echo select -expand nodes ^|  # Iterate each node >> ban.ps1
echo Get-ObjectMembers  ^|  >> ban.ps1
echo foreach { >> ban.ps1
echo if ($_.Value[1] -like '*Satoshi:1.1*' -or $_.Value[1] -like '*(2x*') { >> ban.ps1
echo $IP = $_.Key; >> ban.ps1
echo $IP = $IP -replace ":\d{1,5}$" #Strip port number off the end >> ban.ps1
echo. >> ban.ps1
echo Write-Host "Banning $IP due to agent " $_.Value[1] >> ban.ps1
echo. >> ban.ps1
echo # Call into bitcoin-cli and ban. >> ban.ps1
echo $AllArgs = @('setban', $IP, 'add', $BAN_TIME) >> ban.ps1
echo & "C:\Program Files\Bitcoin\daemon\bitcoin-cli" $AllArgs >> ban.ps1
echo. >> ban.ps1
echo $COUNT = $COUNT + 1 >> ban.ps1
echo } >> ban.ps1
echo } >> ban.ps1
echo.  >> ban.ps1
echo Write-Host "Found and banned $COUNT nodes."; >> ban.ps1
echo.
echo execute ban.ps1
echo.
REM THIS EXECUTES THE ban.ps1 FILE
Powershell.exe -executionpolicy remotesigned -File ban.ps1
echo.
echo.
echo banning finished - you can close this window
echo.
pause
