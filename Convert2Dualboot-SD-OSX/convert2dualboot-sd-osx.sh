#!/bin/sh

#Convert2Dualboot-SD OSX by Racks11479
#I used Apk Manager 4.0 by Daneshm90 as a base.
#Released under GNU GPL 2.0
#Please keep credit intact if you plan on using the script elsewhere.
#v1.0 - Initial Release
#v1.1 - Added gapps option

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
		clear
		echo " "
		echo "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
		sleep 3
		clear
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
		clear
		echo " "
		echo "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
		sleep 3
		clear
	fi
}

gp () {
	GAPPS="gapps-to-modify/*.zip"
	if [ -e $GAPPS ] ; then
		mkdir tmp
		unzip $GAPPS -d tmp
		cd tmp
		
		INIT=META-INF/com/google/android/updater-script
		sed -i 's,/system,/system1,g' $INIT
		
			if [ -e *-optional.sh ] ; then
				INIT=install-optional.sh
				sed -i 's,/system,/system1,g' $INIT
			else
				echo "\e[1;31minstall-optional.sh not found, skipping\e[0m"
				sleep 2
			fi

		zip -r gapps_DualbootSD_primary_${DATE}.zip *	
		mv gapps_DualbootSD_primary_${DATE}.zip ../Primary-Mod/gapps_DualbootSD_primary_${DATE}.zip
		cd ..
		rm -r tmp			
	else
		clear
		echo " "
		echo "\e[1;31mWarning: cannot find a valid gapps .zip file\e[0m"
		sleep 3
		clear
	fi
}

ga () {
	GAPPS="gapps-to-modify/*.zip"
	if [ -e $GAPPS ] ; then
		mkdir tmp
		unzip $GAPPS -d tmp
		cd tmp
		
		INIT=META-INF/com/google/android/updater-script
		sed -i 's,/system,/system2,g' $INIT
		
			if [ -e *-optional.sh ] ; then
				INIT=install-optional.sh
				sed -i 's,/system,/system2,g' $INIT
			else
				echo "\e[1;31minstall-optional.sh not found, skipping\e[0m"
				sleep 2
			fi

		zip -r gapps_DualbootSD_alternate_${DATE}.zip *	
		mv gapps_DualbootSD_alternate_${DATE}.zip ../Primary-Mod/gapps_DualbootSD_alternate_${DATE}.zip
		cd ..
		rm -r tmp
		rm -r /data/tmp			
	else
		clear
		echo " "
		echo "\e[1;31mWarning: cannot find a valid gapps .zip file\e[0m"
		sleep 3
		clear
	fi
}

quit () {
		clear
		echo " "
		echo "\e[1;34mThank you for using Convert2Dualboot-SD!\e[0m"
		echo " "
	exit 0
}

co () {
	if [ " " ] ; then
		clear
		echoSleep() { echo "."; sleep 1;}
		echo "\e[1;31mClearing out recent mods\e[0m"
		echoSleep; echoSleep; echoSleep; echoSleep; echoSleep
		rm -r rom-to-modify
		rm -r gapps-to-modify
		rm -r Primary-Mod
		rm -r Alternate-Mod
		mkdir rom-to-modify
		mkdir gapps-to-modify
		mkdir Primary-Mod
		mkdir Alternate-Mod
	fi
	clear
}

restart () {
	echo 
	echo "********************* Convert2Dualboot-SD for OSX ************************"
	echo " "
	echo "\e[1;32m--A tool to modify standard flashable ROM zips for Racks11479 DualbootSD--\e[0m"
	echo " "
	echo "  0    Prep for DualbootSD Primary Boot"
	echo "  1    Prep for DualbootSD Alternate Boot"
	echo "  2    Prep Gapps for DualbootSD Primary Boot"
	echo "  3    Prep Gapps for DualbootSD Alternate Boot"
	echo "  4    Clear out recent mods"
	echo "  5    Quit"
	echo " "
	echo "**************************************************************************"
	echo 
	printf "%s" "Please make your decision: "
	read ANSWER

	case "$ANSWER" in
		 0)   pb ;;
		 1)   ab ;;
		 2)   gp ;;
		 3)   ga ;;
		 4)   co ;;
		 5) quit ;;
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