#!/bin/sh

#Convert2Dualboot-SD Android by Racks11479
#I used Apk Manager by Daneshm90 as a base.
#Released under GNU GPL 2.0
#Please keep credit intact if you plan on using the script elsewhere.
#v1.0 - Initial Release

PATH="$PATH:/mnt/tools"
export PATH
DATE=`date +%d-%m-%y`
TOOLS="/data/tmp/tools"
RD="/data/tmp/rd"
SD="/sdcard/c2dsd/tmp"

pb () {
	ROM="rom-to-modify/*.zip"
	if [ -e $ROM ] ; then
 		mkdir -p $TOOLS
 		cp tools/* $TOOLS
 		mkdir $RD
 		mkdir tmp
		$TOOLS/busybox unzip $ROM -d tmp
		cp tmp/ramdisk.img $RD
		rm tmp/ramdisk.img
		cd $RD
		mkdir tmp
		cd tmp
		
		dd if=../ramdisk.img bs=64 skip=1 | gunzip -c | cpio -i

		INIT=init.encore.rc
		sed -i 's/mmcblk0p5/mmcblk1p2/' $INIT 
		sed -i 's/mmcblk0p6/mmcblk1p3/' $INIT

		cd $RD

		rm ramdisk.img
		$TOOLS/mkbootfs tmp | gzip > nuRamdisk-new.gz
		$TOOLS/mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img
		cp ramdisk.img $SD
		
		cd $SD

		INIT=META-INF/com/google/android/updater-script
		sed -i 's/mmcblk0p5/mmcblk1p2/' $INIT
		sed -i 's/mmcblk0p1/mmcblk1p1/' $INIT
		sed -i 's,/system,/system1,g' $INIT  

		INIT=system/etc/vold.fstab
		sed -i 's/sdcard auto/sdcard 7/' $INIT 

		$TOOLS/zip -r update_DualbootSD_primary_${DATE}.zip *	
		mv update_DualbootSD_primary_${DATE}.zip ../Primary-Mod/update_DualbootSD_primary_${DATE}.zip

		cd ..
		rm -r $SD
		rm -r /data/tmp
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
		sleep 2
	fi
}

ab () {
	ROM="rom-to-modify/*.zip"
	if [ -e $ROM ] ; then
 		mkdir -p $TOOLS
 		cp tools/* $TOOLS
 		mkdir $RD
 		mkdir tmp
		$TOOLS/busybox unzip $ROM -d tmp
		cp tmp/ramdisk.img $RD
		rm tmp/ramdisk.img
		cd $RD
		mkdir tmp
		cd tmp
		
		dd if=../ramdisk.img bs=64 skip=1 | gunzip -c | cpio -i

		INIT=init.encore.rc
		sed -i 's/mmcblk0p5/mmcblk1p5/' $INIT 
		sed -i 's/mmcblk0p6/mmcblk1p6/' $INIT

		cd $RD

		rm ramdisk.img
		$TOOLS/mkbootfs tmp | gzip > nuRamdisk-new.gz
		$TOOLS/mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img
		cp ramdisk.img $SD
		
		cd $SD

		INIT=META-INF/com/google/android/updater-script
		sed -i 's/mmcblk0p5/mmcblk1p5/' $INIT
		sed -i 's/mmcblk0p1/mmcblk1p1/' $INIT
		sed -i 's,/system,/system2,g' $INIT
		sed -i 's/uImage/uAltImg/' $INIT
		sed -i 's/uRamdisk/uAltRam/' $INIT

		INIT=system/etc/vold.fstab
		sed -i 's/sdcard auto/sdcard 7/' $INIT 

		$TOOLS/zip -r update_DualbootSD_alternate_${DATE}.zip *	
		mv update_DualbootSD_alternate_${DATE}.zip ../Alternate-Mod/update_DualbootSD_alternate_${DATE}.zip

		cd ..
		rm -r $SD
		rm -r /data/tmp
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
		sleep 2
	fi
}

quit () {
		clear
		echo " "
		echo -e "\e[1;34mThank you for using Convert2Dualboot-SD!\e[0m"
		echo " "
	exit 0
}

co () {
	if [ " " ] ; then
		clear
		echoSleep() { echo "."; sleep 1;}
		echo -e "\e[1;31mClearing out recent mods\e[0m"
		echoSleep; echoSleep; echoSleep; echoSleep; echoSleep
		rm -rf rom-to-modify
		rm -rf Primary-Mod
		rm -rf Alternate-Mod
		mkdir rom-to-modify
		mkdir Primary-Mod
		mkdir Alternate-Mod
	fi
	clear
}

restart () {
	echo 
	echo "******************** Convert2Dualboot-SD for Android *********************"
	echo " "
	echo -e "\e[1;32m--A tool to modify standard flashable ROM zips for Racks11479 DualbootSD--\e[0m"
	echo " "
	echo "  0    Prep for DualbootSD Primary Boot"
	echo "  1    Prep for DualbootSD Alternate Boot"
	echo "  2    Clear out recent mods"
	echo "  3    Quit"
	echo " "
	echo "**************************************************************************"
	echo 
	printf "%s" "Please make your decision: "
	read ANSWER

	case "$ANSWER" in
		 0)   pb ;;
		 1)   ab ;;
		 2)   co ;;
		 3) quit ;;
		 *)
			echo "Unknown command: '$ANSWER'"
		;;
	esac
}

clear

while [ " " ] ;
do
	restart
done
