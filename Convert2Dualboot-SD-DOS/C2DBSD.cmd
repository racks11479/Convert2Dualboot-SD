::#Convert2Dualboot-SD DOS by DizzyDen for Racks11479
::#I used Apk Manager 4.0 by Daneshm90 as a base.
::#Released under GNU GPL 2.0
::#Please keep credit intact if you plan on using the script elsewhere.
::#v1.0 - Initial Release
::#v1.1 - Added gapps option

@echo off
::#Setup the menu for the batch file
:menu
cls
echo.&echo.&echo.&echo.&echo.&echo.&
echo ********************* Convert2Dualboot-SD for DOS **********************
echo.
echo  A tool to modify standard flashable ROM zips for Racks11479 DualbootSD
echo.
echo   1    Prep for DualbootSD Primary Boot
echo   2    Prep for DualbootSD Alternate Boot
echo   3    Prep Gapps for DualbootSD Primary Boot
echo   4    Prep Gapps for DualbootSD Alternate Boot
echo   5    Clear out recent mods
echo   0    Quit
echo.
echo ********************* Convert2Dualboot-SD for DOS **********************
echo.
echo Please make your decision: 
choice /C 123450 /N 

If Errorlevel 6 GoTo :Exit
If Errorlevel 5 GoTo :co
If Errorlevel 4 GoTo :ga
If Errorlevel 3 GoTo :gp
If Errorlevel 2 GoTo :ab
If ERRORLEVEL 1 GoTo :pb
If Errorlevel 0 GoTo :Exit


::#Modify ROM for Primary Boot
:pb
mkdir tmp
mkdir tmp\rd
set PREPATH=%PATH%
set PATH=%PATH%;.\tools;..\tools;..\..\tools
mkdir pri-to-modify\gapps
cls
if exist pri-to-modify\*gapp*.zip FOR /F %%R IN ('DIR/B/ON "pri-to-modify\*gapps*.zip"') DO mv -f pri-to-modify/%%R pri-to-modify/gapps/%%R >nul
if exist pri-to-modify\*.zip FOR /F %%R IN ('DIR/B/ON pri-to-modify\*.zip') DO set ROM=%%R
If NOT exist pri-to-modify\*.zip (
	cls
	echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo ***** ROM file not found *****
	sleep 10s
	) Else (
	unzip -oq pri-to-modify/%ROM% ramdisk.img -d tmp
	unzip -oq pri-to-modify/%ROM% META-INF/com/google/android/updater-script -d tmp
	unzip -oq pri-to-modify/%ROM% system/etc/vold.fstab -d tmp
	cd tmp\rd
	dd if=../ramdisk.img bs=64 skip=1 of=ramdisk > nul
	gunzip -c ramdisk | cpio -i > nul
	rm -r ramdisk > nul
	sed -i s/mmcblk0p5/mmcblk1p2/ init.encore.rc
	sed -i s/mmcblk0p6/mmcblk1p3/ init.encore.rc
	cd ..
	rm ramdisk.img > nul
	mkbootfs rd | gzip -9 > nuRamdisk-new.gz
	echo.
	
	mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img > nul
	echo.
	
	rmdir /S /Q rd
	rm nuRamdisk-new.gz
	
	sed -i s/mmcblk0p5/mmcblk1p2/ META-INF/com/google/android/updater-script
	sed -i s/mmcblk0p1/mmcblk1p1/ META-INF/com/google/android/updater-script
	sed -i "s,/system,/system1,g" META-INF/com/google/android/updater-script
	
	sed -i "s/sdcard auto/sdcard 7/" system/etc/vold.fstab
	cp -f ../pri-to-modify/%ROM% ../pri-to-modify/update_RDBSD_pri_%ROM% > nul
	zip -ruq ../pri-to-modify/update_RDBSD_pri_%ROM% *.*
	cd ..
	mv -f pri-to-modify/update_RDBSD_pri_%ROM% Primary-Mod > nul
	)
if exist pri-to-modify\gapps\*.zip mv -f pri-to-modify/gapps/*.zip pri-to-modify > nul
rm -fr tmp
rm -fr pri-to-modify/gapps
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#Modify ROM for Alternate Boot
:ab
mkdir tmp
mkdir tmp\rd
set PREPATH=%PATH%
set PATH=%PATH%;.\tools;..\tools;..\..\tools
mkdir alt-to-modify\gapps
cls
if exist alt-to-modify\*gapp*.zip FOR /F %%R IN ('DIR/B/ON "alt-to-modify\*gapps*.zip"') DO mv -f alt-to-modify/%%R alt-to-modify/gapps/%%R >nul
if exist alt-to-modify\*.zip FOR /F %%R IN ('DIR/B/ON alt-to-modify\*.zip') DO set ROM=%%R
If NOT exist alt-to-modify\*.zip (
	cls
	echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo ***** ROM file not found *****
	sleep 10s
	) Else (
	unzip -oq alt-to-modify/%ROM% ramdisk.img -d tmp
	unzip -oq alt-to-modify/%ROM% META-INF/com/google/android/updater-script -d tmp
	unzip -oq alt-to-modify/%ROM% system/etc/vold.fstab -d tmp
	cd tmp\rd
	dd if=../ramdisk.img bs=64 skip=1 of=ramdisk > nul
	gunzip -c ramdisk | cpio -i > nul
	rm -r ramdisk > nul
	sed -i s/mmcblk0p5/mmcblk1p2/ init.encore.rc
	sed -i s/mmcblk0p6/mmcblk1p3/ init.encore.rc
	cd ..
	rm ramdisk.img > nul
	mkbootfs rd | gzip -9 > nuRamdisk-new.gz
	echo.
	
	mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img > nul
	echo.
	
	rmdir /S /Q rd
	rm nuRamdisk-new.gz
	
	sed -i s/mmcblk0p5/mmcblk1p5/ META-INF/com/google/android/updater-script
	sed -i s/mmcblk0p1/mmcblk1p1/ META-INF/com/google/android/updater-script
	sed -i "s,/system,/system2,g" META-INF/com/google/android/updater-script
	sed -i s/uImage/uAltImg/ META-INF/com/google/android/updater-script
	sed -i s/uRamdisk/uAltRam/ META-INF/com/google/android/updater-script
	
	sed -i "s/sdcard auto/sdcard 7/" system/etc/vold.fstab
	cp -f ../alt-to-modify/%ROM% ../alt-to-modify/update_RDBSD_alt_%ROM% > nul
	zip -ruq ../alt-to-modify/update_RDBSD_alt_%ROM% *.*
	cd ..
	mv -f alt-to-modify/update_RDBSD_alt_%ROM% Alternate-Mod > nul
	)
if exist pri-to-modify\gapps\*.zip mv -f pri-to-modify/gapps/*.zip pri-to-modify > nul
rm -fr tmp
rm -fr alt-to-modify/gapps
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#Modify Gapps for Primary Boot
:gp
mkdir tmp
set PREPATH=%PATH%
set PATH=%PATH%;.\tools;..\tools;..\..\tools
cls
FOR /F %%R IN ('DIR/B/ON "pri-to-modify\gapps*.zip"') DO set GAPPS=%%R
If NOT exist pri-to-modify\%GAPPS% (
	cls
	echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo ***** GApps file not found *****
	sleep 10s
	) Else (
	unzip -oq pri-to-modify/%GAPPS% META-INF/com/google/android/updater-script -d tmp
	unzip -oq pri-to-modify/%GAPPS% install-optional.sh -d tmp
	
	cd tmp
	
	sed -i "s,/system,/system1,g" META-INF/com/google/android/updater-script
	sed -i "s,/system,/system1,g" install-optional.sh
	
	cp -f ../pri-to-modify/%GAPPS% ../pri-to-modify/gapps_RDBSD_pri_%GAPPS%
	zip -ruq ../pri-to-modify/gapps_RDBSD_pri_%GAPPS% *.*
	mv -f ../pri-to-modify/gapps_RDBSD_pri_%GAPPS% ../Primary-Mod/gapps_RDBSD_pri_%GAPPS%
	cd ..
	)
rm -fr tmp
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#Modify Gapps for Alternate Boot
:ga
mkdir tmp
set PREPATH=%PATH%
set PATH=%PATH%;.\tools;..\tools;..\..\tools
cls
FOR /F %%R IN ('DIR/B/ON "alt-to-modify\gapps*.zip"') DO set GAPPS=%%R
If NOT exist alt-to-modify\%GAPPS% (
	cls
	echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo ***** GApps file not found *****
	sleep 10s
	) Else (
	unzip oq alt-to-modify/%GAPPS% META-INF/com/google/android/updater-script -d tmp
	unzip oq alt-to-modify/%GAPPS% install-optional.sh -d tmp
	
	cd tmp
	
	sed -i "s,/system,/system2,g" META-INF/com/google/android/updater-script
	sed -i "s,/system,/system2,g" install-optional.sh
	
	cp -f ../alt-to-modify/%GAPPS% ../alt-to-modify/gapps_RDBSD_alt_%GAPPS%
	zip -ruq ../alt-to-modify/gapps_RDBSD_alt_%GAPPS% *.*
	mv -f ../alt-to-modify/gapps_RDBSD_alt_%GAPPS% ../alternate-Mod/gapps_RDBSD_alt_%GAPPS%
	cd ..
	)
rm -fr tmp
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#Clear out and reiniate all working folders
:co
set PREPATH=%PATH%
set PATH=%PATH%;.\tools;..\tools;..\..\tools
cls
echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
echo Clearing out recent mods
sleep 3s
if exist tmp\nul rmdir /S /Q tmp
if exist pri-to-modify\nul rmdir /S /Q pri-to-modify
if exist alt-to-modify\nul rmdir /S /Q alt-to-modify
if exist Primary-Mod\nul rmdir /S /Q Primary-Mod
if exist Alternate-Mod\nul rmdir /S /Q Alternate-Mod
if not exist pri-to-modify\nul mkdir pri-to-modify
if not exist alt-to-modify\nul mkdir alt-to-modify
if not exist Primary-Mod\nul mkdir Primary-Mod
if not exist Alternate-Mod\nul mkdir Alternate-Mod
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#We're done... thank the user, clear up path modifications and temp folders
:Exit
set PATH=%PREPATH%
set PREPATH=
if exist tmp\nul rmdir /S /Q tmp
cls
echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
echo Thank you for using Convert2Dualboot-SD!
tools\sleep 5s