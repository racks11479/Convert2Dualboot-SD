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
echo.
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
echo **************************************************************************
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
cls
FOR /F %%R IN ('DIR/B/ON "pri-to-modify\update*.zip"') DO set ROM=%%R
FOR /F %%R IN ('DIR/B/ON "pri-to-modify\cm*.zip"') DO set ROM=%%R
unzip pri-to-modify/%ROM% ramdisk.img -d tmp
unzip pri-to-modify/%ROM% META-INF/com/google/android/updater-script -d tmp
unzip pri-to-modify/%ROM% system/etc/vold.fstab -d tmp
cd tmp\rd
dd if=../ramdisk.img bs=64 skip=1 of=ramdisk
gunzip -c ramdisk | cpio -i
rm -r ramdisk
sed -i s/mmcblk0p5/mmcblk1p2/ init.encore.rc 
sed -i s/mmcblk0p6/mmcblk1p3/ init.encore.rc
cd ..
rm ramdisk.img
mkbootfs rd | gzip -9 > nuRamdisk-new.gz
echo.

mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img
echo.

rmdir /S /Q rd
rm nuRamdisk-new.gz

sed -i "s/mmcblk0p5/mmcblk1p2/" META-INF/com/google/android/updater-script
sed -i "s/mmcblk0p1/mmcblk1p1/" META-INF/com/google/android/updater-script
sed -i "s,/system,/system1,g" META-INF/com/google/android/updater-script  

sed -i "s/sdcard auto/sdcard 7/" system/etc/vold.fstab
cp -f ../pri-to-modify/%ROM% ../pri-to-modify/update_RDBSD_pri_%ROM%
zip -R -u ../pri-to-modify/update_RDBSD_pri_%ROM% *.*
mv -f ../pri-to-modify/update_RDBSD_pri_%ROM% ../Primary-Mod/update_RDBSD_pri_%ROM%
cd ..
rm -r tmp
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
cls
FOR /F %%R IN ('DIR/B/ON "alt-to-modify\update*.zip"') DO set ROM=%%R
FOR /F %%R IN ('DIR/B/ON "alt-to-modify\cm*.zip"') DO set ROM=%%R
unzip alt-to-modify/%ROM% ramdisk.img -d tmp
unzip alt-to-modify/%ROM% META-INF/com/google/android/updater-script -d tmp
unzip alt-to-modify/%ROM% system/etc/vold.fstab -d tmp
cd tmp\rd
dd if=../ramdisk.img bs=64 skip=1 of=ramdisk
gunzip -c ramdisk | cpio -i
rm -r ramdisk
sed -i s/mmcblk0p5/mmcblk1p2/ init.encore.rc 
sed -i s/mmcblk0p6/mmcblk1p3/ init.encore.rc
cd ..
rm ramdisk.img
mkbootfs rd | gzip -9 > nuRamdisk-new.gz
echo.

mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img
echo.

rmdir /S /Q rd
rm nuRamdisk-new.gz

sed -i "s/mmcblk0p5/mmcblk1p5/"  META-INF/com/google/android/updater-script
sed -i "s/mmcblk0p1/mmcblk1p1/"  META-INF/com/google/android/updater-script
sed -i "s,/system,/system2,g"  META-INF/com/google/android/updater-script
sed -i "s/uImage/uAltImg/"  META-INF/com/google/android/updater-script
sed -i "s/uRamdisk/uAltRam/"  META-INF/com/google/android/updater-script

sed -i "s/sdcard auto/sdcard 7/" system/etc/vold.fstab
cp -f ../alt-to-modify/%ROM% ../alt-to-modify/update_RDBSD_alt_%ROM%
zip -R -u ../alt-to-modify/update_RDBSD_alt_%ROM% *.*
mv -f ../alt-to-modify/update_RDBSD_alt_%ROM% ../alternate-Mod/update_RDBSD_alt_%ROM%
cd ..
rm -r tmp
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#Modify Gapps for Primary Boot
:gp
mkdir tmp
mkdir tmp\rd
set PREPATH=%PATH%
set PATH=%PATH%;.\tools;..\tools;..\..\tools
cls
FOR /F %%R IN ('DIR/B/ON "pri-to-modify\gapps*.zip"') DO set GAPPS=%%R
unzip pri-to-modify/%GAPPS% META-INF/com/google/android/updater-script -d tmp
unzip pri-to-modify/%GAPPS% install-optional.sh -d tmp

cd tmp

sed -i "s,/system,/system1,g" META-INF/com/google/android/updater-script
sed -i "s,/system,/system1,g" install-optional.sh

rmdir /S /Q rd
cp -f ../pri-to-modify/%GAPPS% ../pri-to-modify/gapps_RDBSD_pri_%GAPPS%
zip -R -u ../pri-to-modify/gapps_RDBSD_pri_%GAPPS% *.*
mv -f ../pri-to-modify/gapps_RDBSD_pri_%GAPPS% ../Primary-Mod/gapps_RDBSD_pri_%GAPPS%
cd ..
rm -r tmp
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#Modify Gapps for Alternate Boot
:ga
mkdir tmp
mkdir tmp\rd
set PREPATH=%PATH%
set PATH=%PATH%;.\tools;..\tools;..\..\tools
cls
FOR /F %%R IN ('DIR/B/ON "pri-to-modify\gapps*.zip"') DO set GAPPS=%%R
unzip pri-to-modify/%GAPPS% META-INF/com/google/android/updater-script -d tmp
unzip pri-to-modify/%GAPPS% install-optional.sh -d tmp

cd tmp

sed -i "s,/system,/system1,g" META-INF/com/google/android/updater-script
sed -i "s,/system,/system1,g" install-optional.sh

rmdir /S /Q rd
cp -f ../pri-to-modify/%GAPPS% ../pri-to-modify/gapps_RDBSD_pri_%GAPPS%
zip -R -u ../pri-to-modify/gapps_RDBSD_pri_%GAPPS% *.*
mv -f ../pri-to-modify/gapps_RDBSD_pri_%GAPPS% ../Primary-Mod/gapps_RDBSD_pri_%GAPPS%
cd ..
rm -r tmp
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#Clear out and reiniate all working folders
:co
set PREPATH=%PATH%
set PATH=%PATH%;.\tools;..\tools;..\..\tools
cls
echo .
echo Clearing out recent mod
sleep 3s
rmdir /S /Q tmp\rd
rmdir /S /Q tmp
rmdir /S /Q pri-to-modify
rmdir /S /Q alt-to-modify
rmdir /S /Q Primary-Mod
rmdir /S /Q Alternate-Mod
mkdir pri-to-modify
mkdir alt-to-modify
mkdir Primary-Mod
mkdir Alternate-Mod
set PATH=%PREPATH%
set PREPATH=
echo.
goto :menu


::#We're done... thank the user, clear up path modifications and temp folders
:Exit
set PATH=%PREPATH%
set PREPATH=
rmdir /S /Q tmp\rd
rmdir /S /Q tmp
echo Thank you for using Convert2Dualboot-SD!
sleep 5s