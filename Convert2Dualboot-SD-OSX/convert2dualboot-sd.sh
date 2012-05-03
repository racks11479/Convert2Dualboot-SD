#!/bin/sh

#Convert2SD-Dualboot by Racks11479
#I used Apk Manager 4.0 (C) 2010 by Daneshm90 as a base.
#Released under GPL 2.0
#Please keep credit intact if you plan on using the script elsewhere.
#v1.0 - Initial Release

PATH="$PATH:$PWD/tools"
export PATH
DATE=`date +%d-%m-%y`

pb () {
	ROM="rom-to-modify/*.zip"
	if [ -e $ROM ] ; then
 		mkdir tmp
		mkdir tmp/rd
		unzip $ROM -d tmp
		cd tmp/rd
		dd if=../ramdisk.img bs=64 skip=1 | gunzip -c | cpio -i

		INIT=init.encore.rc
		sed -i 's/mmcblk0p5/mmcblk1p2/' $INIT 
		sed -i 's/mmcblk0p6/mmcblk1p3/' $INIT

		cd ..

		rm ramdisk.img
		mkbootfs rd | gzip > nuRamdisk-new.gz
		mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img
		rm -r rd
		rm nuRamdisk-new.gz

		INIT=META-INF/com/google/android/updater-script
		sed -i 's/mmcblk0p5/mmcblk1p2/' $INIT
		sed -i 's/mmcblk0p1/mmcblk1p1/' $INIT
		sed -i 's,/system,/system1,g' $INIT  

		INIT=system/etc/vold.fstab
		sed -i 's/sdcard auto/sdcard 7/' $INIT 

		zip -r update_DualbootSD_primary_${DATE}.zip *	
		mv update_DualbootSD_primary_${DATE}.zip ../Primary-Mod/update_DualbootSD_primary_${DATE}.zip

		cd ..
		rm -r tmp
	else
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
	fi
}

ab () {
	ROM="rom-to-modify/*.zip"
	if [ -e $ROM ] ; then
 		mkdir tmp
		mkdir tmp/rd
		unzip $ROM -d tmp
		cd tmp/rd
		dd if=../ramdisk.img bs=64 skip=1 | gunzip -c | cpio -i

		INIT=init.encore.rc
		sed -i 's/mmcblk0p5/mmcblk1p5/' $INIT 
		sed -i 's/mmcblk0p6/mmcblk1p6/' $INIT

		cd ..

		rm ramdisk.img
		mkbootfs rd | gzip > nuRamdisk-new.gz
		mkimage -A ARM -T RAMDisk -n Image -d nuRamdisk-new.gz ramdisk.img
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

		zip -r update_DualbootSD_alternate_${DATE}.zip *	
		mv update_DualbootSD_alternate_${DATE}.zip ../Alternate-Mod/update_DualbootSD_alternate_${DATE}.zip
		cd ..
		rm -r tmp
	else
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
	fi
}

quit () {
		echo " "
		echo -e "\e[1;34mThank you for using Convert2Dualboot-SD!\e[0m"
		echo " "
	exit 0
}

restart () {
	echo 
	echo "*********************** Convert2Dualboot-SD for OSX **********************"
	echo " "
	echo -e "\e[1;32m--A tool to modify standard flashable ROM zips for Racks11479 DualbootSD--\e[0m"
	echo " "
	echo "  0    Prep for DualbootSD Primary Boot"
	echo "  1    Prep for DualbootSD Alternate Boot"
	echo "  2    Quit"
	echo " "
	echo "**************************************************************************"
	echo 
	printf "%s" "Please make your decision: "
	read ANSWER

	case "$ANSWER" in
		 0)   pb ;;
		 1)   ab ;;
		 2) quit ;;
		 *)
			echo "Unknown command: '$ANSWER'"
		;;
	esac
}

clear
printf "%s" "Do you want to clean out all your current projects (y/N)? "
read ROM
if [ "x$ROM" = "xy" ] || [ "x$ROM" = "xY" ] ; then
	rm -rf rom-to-modify
	rm -rf Primary-Mod
	rm -rf Alternate-Mod
	mkdir rom-to-modify
	mkdir Primary-Mod
	mkdir Alternate-Mod
fi
while [ "1" = "1" ] ;
do
	restart
done
exit 0
