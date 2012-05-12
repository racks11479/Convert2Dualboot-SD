#!/bin/sh

#Convert2Dualboot-SD Android by Racks11479
#I used Apk Manager by Daneshm90 as a base.
#Released under GNU GPL 2.0
#Please keep credit intact if you plan on using the script elsewhere.
#v1.0 - Initial Release
#v1.1 - Added gapps option
#v1.2 - Code & UI Cleanup, Modified how zips are handled to speed up script

DATE=`date +%d-%m-%y`
BIN="/sdcard/c2dsd/tools/bin"
TMP="/sdcard/c2dsd/tools/tmp"
C2DSD="/sdcard/c2dsd"

spinner () {
		SP_STRING=${2:-"'|/=\'"}
		while [ -d /proc/$1 ]
		do
			printf "$SP_STRING"
			sleep 1.5
			SP_STRING=${SP_STRING#"${SP_STRING%?}"}${SP_STRING%?}
		done
}

pb () {
	ROM="rom-to-modify/*.zip"
	if [ -e $ROM ] ; then
	
		busybox mount -o loop,rw $C2DSD/tools.img $C2DSD/tools
		
 		clear
 		echo -e "\e[1;31mPrepping ROM files for Primary-Mod. Please be patient!\e[0m"
 		cp $ROM Primary-Mod/PriMod_ROM_${DATE}.zip &
 		spinner "$!" "."
 		
		$BIN/busybox unzip $ROM ramdisk.img -d $TMP
		$BIN/busybox unzip $ROM META-INF/com/google/android/updater-script -d $TMP
		$BIN/busybox unzip $ROM system/etc/vold.fstab -d $TMP
		mkdir $TMP/rd
		cd $TMP/rd
		
		dd if=../ramdisk.img bs=64 skip=1 | gunzip -c | cpio -i

		INIT=init.encore.rc
		sed -i 's/mmcblk0p5/mmcblk1p2/' $INIT 
		sed -i 's/mmcblk0p6/mmcblk1p3/' $INIT

		cd ..
		
		rm ramdisk.img
		$BIN/mkbootfs rd | gzip > nuRamdisk-new.gz
		$BIN/mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img
		rm -r rd
		rm nuRamdisk-new.gz

		INIT=META-INF/com/google/android/updater-script
		sed -i 's/mmcblk0p5/mmcblk1p2/' $INIT
		sed -i 's/mmcblk0p1/mmcblk1p1/' $INIT
		sed -i 's,/system,/system1,g' $INIT  

		INIT=system/etc/vold.fstab
		sed -i 's/sdcard auto/sdcard 7/' $INIT 
		
		$BIN/zip -r -u /sdcard/c2dsd/Primary-Mod/PriMod_ROM_${DATE}.zip

		rm -r $TMP/*
		cd $C2DSD
		
		busybox umount tools
		
		clear
		echo " "
		echo -e "\e[1;33mPrepping ROM for Primary Boot Finished!\e[0m"
		sleep 3
		clear
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
		sleep 3
		clear
	fi
}

ab () {
	ROM="rom-to-modify/*.zip"
	if [ -e $ROM ] ; then
	
		busybox mount -o loop,rw $C2DSD/tools.img $C2DSD/tools
		
 		clear
 		echo -e "\e[1;31mPrepping ROM files for Alternate-Mod. Please be patient!\e[0m"
 		cp $ROM Alternate-Mod/AltMod_ROM_${DATE}.zip &
 		spinner "$!" "."
 		
		$BIN/busybox unzip $ROM ramdisk.img -d $TMP
		$BIN/busybox unzip $ROM META-INF/com/google/android/updater-script -d $TMP
		$BIN/busybox unzip $ROM system/etc/vold.fstab -d $TMP
		mkdir $TMP/rd
		cd $TMP/rd
		
		dd if=../ramdisk.img bs=64 skip=1 | gunzip -c | cpio -i

		INIT=init.encore.rc
		sed -i 's/mmcblk0p5/mmcblk1p5/' $INIT 
		sed -i 's/mmcblk0p6/mmcblk1p6/' $INIT

		cd ..
		
		rm ramdisk.img
		$BIN/mkbootfs rd | gzip > nuRamdisk-new.gz
		$BIN/mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img
		rm -r rd
		rm nuRamdisk-new.gz

		INIT=META-INF/com/google/android/updater-script
		sed -i 's/mmcblk0p5/mmcblk1p5/' $INIT
		sed -i 's/mmcblk0p1/mmcblk1p1/' $INIT
		sed -i 's,/system,/system2,g' $INIT
		sed -i 's/uImage/uAltImg/' $INIT
		sed -i 's/uRamdisk/uAltRam/' $INIT

		INIT=system/etc/vold.fstab
		sed -i 's/sdcard auto/sdcard 7/' $INIT 
		
		$BIN/zip -r -u /sdcard/c2dsd/Alternate-Mod/AltMod_ROM_${DATE}.zip

		rm -r $TMP/*
		cd $C2DSD
		
		busybox umount tools
		
		clear
		echo " "
		echo -e "\e[1;33mPrepping ROM for Alternate Boot Finished!\e[0m"
		sleep 3
		clear
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
		sleep 3
		clear
	fi
}

gp () {
	GAPPS="gapps-to-modify/*.zip"
	if [ -f $GAPPS ] ; then

		busybox mount -o loop,rw $C2DSD/tools.img $C2DSD/tools
		
		clear
		echo " "
 		echo -e "\e[1;31mPrepping GAPPS files for Primary-Mod. Please be patient!\e[0m"
 		cp $GAPPS Primary-Mod/PriMod_Gapps_${DATE}.zip &
 		spinner "$!" "."
 		
		$BIN/busybox unzip $GAPPS META-INF/com/google/android/updater-script -d $TMP
		$BIN/busybox unzip $GAPPS install* -d $TMP
		
		cd $TMP
		
		sed -i 's,/system,/system1,g' META-INF/com/google/android/updater-script 2> /dev/null
		sed -i 's,/system,/system1,g' install* 2> /dev/null

		$BIN/zip -r -u /sdcard/c2dsd/Primary-Mod/PriMod_Gapps_${DATE}.zip
		
		rm -r $TMP/*
		cd $C2DSD
		
		busybox umount tools
		
		clear
		echo " "
		echo -e "\e[1;33mPrepping GAPPS for Primary Boot Finished!\e[0m"
		sleep 3
		clear
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid gapps .zip file\e[0m"
		sleep 3
		clear
	fi
	done
}

ga () {
	GAPPS="gapps-to-modify/*.zip"
	if [ -f $GAPPS ] ; then

		busybox mount -o loop,rw $C2DSD/tools.img $C2DSD/tools
		
		clear
		echo " "
 		echo -e "\e[1;31mPrepping GAPPS files for Alternate-Mod. Please be patient!\e[0m"
 		cp $GAPPS Alternate-Mod/AltMod_Gapps_${DATE}.zip &
 		spinner "$!" "."
 		
		$BIN/busybox unzip $GAPPS META-INF/com/google/android/updater-script -d $TMP
		$BIN/busybox unzip $GAPPS install* -d $TMP
		
		cd $TMP
		
		sed -i 's,/system,/system2,g' META-INF/com/google/android/updater-script 2> /dev/null
		sed -i 's,/system,/system2,g' install* 2> /dev/null

		$BIN/zip -r -u /sdcard/c2dsd/Alternate-Mod/AltMod_Gapps_${DATE}.zip
		
		rm -r $TMP/*
		cd $C2DSD
		
		busybox umount tools
		
		clear
		echo " "
		echo -e "\e[1;33mPrepping GAPPS for Alternate Boot Finished!\e[0m"
		sleep 3
		clear
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid gapps .zip file\e[0m"
		sleep 3
		clear
	fi
	done
}

co () {
	if [ " " ] ; then
		clear
		echo " "
		echo -e "\e[1;31mClearing out recent mods\e[0m"
		sleep 5 &
		spinner "$1" "."
		rm -rf rom-to-modify
		rm -rf gapps-to-modify
		rm -rf Primary-Mod
		rm -rf Alternate-Mod
		mkdir rom-to-modify
		mkdir gapps-to-modify
		mkdir Primary-Mod
		mkdir Alternate-Mod
		clear
	fi
}

quit () {
		clear
		echo " "
		echo -e "\e[1;33mThank you for using Convert2Dualboot-SD!\e[0m"
		echo " "
	exit 0
}

restart () {
	echo 
	echo "******************** Convert2Dualboot-SD for Android *********************"
	echo " "
	echo -e "\e[1;33m--A tool to modify standard flashable ROM zips for Racks11479 DualbootSD--\e[0m"
	echo " "
	echo "  1    Prep ROM for DualbootSD Primary Boot"
	echo "  2    Prep ROM for DualbootSD Alternate Boot"
	echo "  3    Prep Gapps for DualbootSD Primary Boot"
	echo "  4    Prep Gapps for DualbootSD Alternate Boot"
	echo "  5    Clear out recent mods"
	echo "  0    Quit"
	echo " "
	echo "**************************************************************************"
	echo 
	printf "%s" "Please make your decision: "
	read ANSWER

	case "$ANSWER" in
		 1)   pb ;;
		 2)   ab ;;
		 3)   gp ;;
		 4)   ga ;;
		 5)   co ;;
		 0) quit ;;
		 *)
			echo " "
			echo -e "\e[1;31mUnknown command: '$ANSWER' Please select from the list above.\e[0m"
			echo " "
			sleep 6
		;;
	esac
	clear
}

clear

while [ " " ] ;
do
	restart
done
