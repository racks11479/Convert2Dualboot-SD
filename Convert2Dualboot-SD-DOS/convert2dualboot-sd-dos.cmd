::#Convert2Dualboot-SD DOS by DizzyDen for Racks11479
::#I used Apk Manager 4.0 by Daneshm90 as a base.
::#Released under GNU GPL 2.0
::#Please keep credit intact if you plan on using the script elsewhere.
::#v1.0 - Initial Release
::#v1.1 - Added gapps option
::#v1.2 - Code & UI Cleanup, Added "ROM & GAPPS" option. Modified how zips are handled to speed up script. Restructured layout.

@echo off
::#Setup the menu for the batch file
:menu
cls
echo.&echo.&echo.&echo.&echo.&echo.&
echo ********************* Convert2Dualboot-SD for DOS **********************
echo.
echo  A tool to modify standard flashable ROM zips for Racks11479 DualbootSD
echo.
echo   1    Prep ROM for DualbootSD Primary
echo   2    Prep ROM for DualbootSD Alternate
echo   3    Prep GAPPS for DualbootSD Primary Boot
echo   4    Prep GAPPS for DualbootSD Alternate Boot
echo   5    Prep "ROM & GAPPS" for DualbootSD Primary
echo   6    Prep "ROM & GAPPS" for DualbootSD Alternate
echo   7    Clear out recent mods
echo   0    Quit
echo.
echo ********************* Convert2Dualboot-SD for DOS **********************
echo.
echo Please make your decision: 
choice /C 12345670 /N 

If Errorlevel 8 GoTo :Exit
If Errorlevel 7 GoTo :co
If Errorlevel 6 Call :Both&GoTo :ab
If Errorlevel 5 Call :Both&GoTo :pb
If Errorlevel 4 GoTo :ga
If Errorlevel 3 GoTo :gp
If Errorlevel 2 GoTo :ab
If Errorlevel 1 GoTo :pb
If Errorlevel 0 GoTo :Exit


::#Modify ROM for Primary Boot
:pb
mkdir tmp
mkdir tmp\rd
set PREPATH=%PATH%
set PATH=.\tools;..\tools;..\..\tools;%PATH%
cls
if exist modify-for-pri\*gapp*.zip FOR /F %%R IN ('DIR/B/ON "modify-for-pri\*gapps*.zip"') DO mv -f modify-for-pri/%%R tmp/%%R >nul
if exist modify-for-pri\*.zip FOR /F %%R IN ('DIR/B/ON modify-for-pri\*.zip') DO set ROM=%%R
If NOT exist modify-for-pri\*.zip (
	cls
	echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo ***** ROM file not found *****
	sleep 10s
	) Else (
	unzip -oq modify-for-pri/%ROM% ramdisk.img -d tmp
	unzip -oq modify-for-pri/%ROM% META-INF/com/google/android/updater-script -d tmp
	unzip -oq modify-for-pri/%ROM% system/etc/vold.fstab -d tmp
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
	cp -f ../modify-for-pri/%ROM% ../modify-for-pri/RDBSD_Pri_%ROM% > nul
	zip -ruq ../modify-for-pri/RDBSD_Pri_%ROM% *.*
	cd ..
	mv -f modify-for-pri/RDBSD_Pri_%ROM% Primary-Mod > nul
	)
if exist tmp\*gapps*.zip mv -f tmp/*gapps*.zip modify-for-pri > nul
rm -fr tmp
set PATH=%PREPATH%
set PREPATH=
echo.
If defined Both GoTo :gp
goto :menu


::#Modify ROM for Alternate Boot
:ab
mkdir tmp
mkdir tmp\rd
set PREPATH=%PATH%
set PATH=.\tools;..\tools;..\..\tools;%PATH%
cls
if exist modify-for-alt\*gapp*.zip FOR /F %%R IN ('DIR/B/ON "modify-for-alt\*gapps*.zip"') DO mv -f modify-for-alt/%%R tmp/%%R >nul
if exist modify-for-alt\*.zip FOR /F %%R IN ('DIR/B/ON modify-for-alt\*.zip') DO set ROM=%%R
If NOT exist modify-for-alt\*.zip (
	cls
	echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo ***** ROM file not found *****
	sleep 10s
	) Else (
	unzip -oq modify-for-alt/%ROM% ramdisk.img -d tmp
	unzip -oq modify-for-alt/%ROM% META-INF/com/google/android/updater-script -d tmp
	unzip -oq modify-for-alt/%ROM% system/etc/vold.fstab -d tmp
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
	cp -f ../modify-for-alt/%ROM% ../modify-for-alt/RDBSD_Alt_%ROM% > nul
	zip -ruq ../modify-for-alt/RDBSD_Alt_%ROM% *.*
	cd ..
	mv -f modify-for-alt/RDBSD_Alt_%ROM% Alternate-Mod > nul
	)
if exist tmp\*gapps*.zip mv -f tmp\*gapps*.zip modify-for-alt > nul
rm -fr tmp
set PATH=%PREPATH%
set PREPATH=
echo.
If defined Both GoTo :ga
goto :menu


::#Modify Gapps for Primary Boot
:gp
if defined Both set Both=
mkdir tmp
set PREPATH=%PATH%
set PATH=.\tools;..\tools;..\..\tools;%PATH%
cls
If exist modify-for-pri\*gapp*.zip FOR /F %%R IN ('DIR/B/ON "modify-for-pri\*gapps*.zip"') DO set GAPPS=%%R
If NOT exist modify-for-pri\*gapp*.zip (
	cls
	echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo ***** GApps file not found *****
	sleep 10s
	) Else (
	unzip -oq modify-for-pri/%GAPPS% META-INF/com/google/android/updater-script -d tmp
	unzip -oq modify-for-pri/%GAPPS% install-optional.sh -d tmp
	
	cd tmp
	
	sed -i "s,/system,/system1,g" META-INF/com/google/android/updater-script
	sed -i "s,/system,/system1,g" install-optional.sh
	
	cp -f ../modify-for-pri/%GAPPS% ../modify-for-pri/RDBSD_Pri_%GAPPS%
	zip -ruq ../modify-for-pri/RDBSD_Pri_%GAPPS% *.*
	mv -f ../modify-for-pri/RDBSD_Pri_%GAPPS% ../Primary-Mod/RDBSD_Pri_%GAPPS%
	cd ..
	)
rm -fr tmp
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#Modify Gapps for Alternate Boot
:ga
if defined Both set Both=
mkdir tmp
set PREPATH=%PATH%
set PATH=.\tools;..\tools;..\..\tools;%PATH%
cls
If exist modify-for-alt\*gapp*.zip FOR /F %%R IN ('DIR/B/ON "modify-for-alt\*gapps*.zip"') DO set GAPPS=%%R
If NOT exist modify-for-alt\*gapp*.zip (
	cls
	echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo ***** GApps file not found *****
	sleep 10s
	) Else (
	unzip -oq modify-for-alt/%GAPPS% META-INF/com/google/android/updater-script -d tmp
	unzip -oq modify-for-alt/%GAPPS% install-optional.sh -d tmp
	
	cd tmp
	
	sed -i "s,/system,/system2,g" META-INF/com/google/android/updater-script
	sed -i "s,/system,/system2,g" install-optional.sh
	
	cp -f ../modify-for-alt/%GAPPS% ../modify-for-alt/RDBSD_Alt_%GAPPS%
	zip -ruq ../modify-for-alt/RDBSD_Alt_%GAPPS% *.*
	mv -f ../modify-for-alt/RDBSD_Alt_%GAPPS% ../Alternate-Mod/RDBSD_Alt_%GAPPS%
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
set PATH=.\tools;..\tools;..\..\tools;%PATH%
cls
echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
echo Clearing out recent mods
if exist tmp\nul rmdir /S /Q tmp
if exist modify-for-pri\nul rmdir /S /Q modify-for-pri
if exist modify-for-alt\nul rmdir /S /Q modify-for-alt
if exist Primary-Mod\nul rmdir /S /Q Primary-Mod
if exist Alternate-Mod\nul rmdir /S /Q Alternate-Mod
if not exist modify-for-pri\nul mkdir modify-for-pri
sleep 1s
if not exist modify-for-alt\nul mkdir modify-for-alt
sleep 1s
if not exist Primary-Mod\nul mkdir Primary-Mod
sleep 1s
if not exist Alternate-Mod\nul mkdir Alternate-Mod
sleep 1s
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

:Both
Set Both=Y