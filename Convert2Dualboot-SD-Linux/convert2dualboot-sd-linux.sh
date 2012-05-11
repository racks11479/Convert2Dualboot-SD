#!/bin/sh

#Convert2Dualboot-SD Linux by Racks11479
#I used Apk Manager 4.0 by Daneshm90 as a base.
#Released under GNU GPL 2.0
#Please keep credit intact if you plan on using the script elsewhere.
#v1.0 - Initial Release
#v1.1 - Added gapps option
#v1.2 - Code & UI Cleanup, Modified how zips are handled to speed up script

PATH="$PATH:$PWD/tools"
export PATH
DATE=`date +%d-%m-%y`

spinner () {
		SP_STRING=${2:-"'|/=\'"}
		while [ -d /proc/$1 ]
		do
			printf "$SP_STRING"
			sleep 1
			SP_STRING=${SP_STRING#"${SP_STRING%?}"}${SP_STRING%?}
		done
}

pb () {
	ROM="rom-to-modify/*.zip"
	if [ -e $ROM ] ; then

 		clear
		echo " "
 		echo -e "\e[1;31mPrepping ROM files for Primary-Mod. Please be patient!\e[0m"
 		cp $ROM Primary-Mod/PriMod_ROM_${DATE}.zip & sleep 5 &
 		spinner "$!" "."
		
		mkdir -p tmp/rd

		unzip $ROM ramdisk.img -d tmp
		unzip $ROM META-INF/com/google/android/updater-script -d tmp
		unzip $ROM system/etc/vold.fstab -d tmp

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

		zip -r -u ../Primary-Mod/PriMod_ROM_${DATE}.zip

		cd ..
		rm -r tmp

		clear
		echo " "
		echo -e "\e[1;33mPrepping ROM for Primary Boot Finished!\e[0m"
		sleep 5
		clear
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
		sleep 5
		clear
	fi
}

ab () {
	ROM="rom-to-modify/*.zip"
	if [ -e $ROM ] ; then

 		clear
		echo " "
 		echo -e "\e[1;31mPrepping ROM files for Alternate-Mod. Please be patient!\e[0m"
 		cp $ROM Alternate-Mod/AltMod_ROM_${DATE}.zip & sleep 5 &
 		spinner "$!" "."
		
		mkdir -p tmp/rd

		unzip $ROM ramdisk.img -d tmp
		unzip $ROM META-INF/com/google/android/updater-script -d tmp
		unzip $ROM system/etc/vold.fstab -d tmp

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

		zip -r -u ../Alternate-Mod/AltMod_ROM_${DATE}.zip

		cd ..
		rm -r tmp

		clear
		echo " "
		echo -e "\e[1;33mPrepping ROM for Alternate Boot Finished!\e[0m"
		sleep 5
		clear
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid ROM .zip file\e[0m"
		sleep 5
		clear
	fi
}

gp () {
	GAPPS="gapps-to-modify/*.zip"
	if [ -e $GAPPS ] ; then
		
		clear
		echo " "
 		echo -e "\e[1;31mPrepping GAPPS files for Primary-Mod. Please be patient!\e[0m"
 		cp $GAPPS Primary-Mod/PriMod_Gapps_${DATE}.zip & sleep 5 &
 		spinner "$!" "."

		mkdir tmp
		unzip $GAPPS META-INF/com/google/android/updater-script -d tmp
		unzip $GAPPS install* -d tmp 2> /dev/null
		
		cd tmp
		
		sed -i 's,/system,/system1,g' META-INF/com/google/android/updater-script 2> /dev/null
		sed -i 's,/system,/system1,g' install* 2> /dev/null

		zip -r -u ../Primary-Mod/PriMod_Gapps_${DATE}.zip

		cd ..
		rm -r tmp

		clear
		echo " "
		echo -e "\e[1;33mPrepping GAPPS for Primary Boot Finished!\e[0m"
		sleep 5
		clear		
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid gapps .zip file\e[0m"
		sleep 5
		clear
	fi
}

ga () {
	GAPPS="gapps-to-modify/*.zip"
	if [ -e $GAPPS ] ; then
		
		clear
		echo " "
 		echo -e "\e[1;31mPrepping GAPPS files for Alternate-Mod. Please be patient!\e[0m"
 		cp $GAPPS Alternate-Mod/Alternate_Gapps_${DATE}.zip & sleep 5 &
 		spinner "$!" "."

		mkdir tmp
		unzip $GAPPS META-INF/com/google/android/updater-script -d tmp
		unzip $GAPPS install* -d tmp
		
		cd tmp
		
		sed -i 's,/system,/system2,g' META-INF/com/google/android/updater-script 2> /dev/null
		sed -i 's,/system,/system2,g' install* 2> /dev/null

		zip -r -u ../Alternate-Mod/Alternate_Gapps_${DATE}.zip

		cd ..
		rm -r tmp

		clear
		echo " "
		echo -e "\e[1;33mPrepping GAPPS for Alternate Boot Finished!\e[0m"
		sleep 5
		clear		
	else
		clear
		echo " "
		echo -e "\e[1;31mWarning: cannot find a valid gapps .zip file\e[0m"
		sleep 5
		clear
	fi
}

co () {
	if [ " " ] ; then
		clear
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
		echo -e "\e[1;34mThank you for using Convert2Dualboot-SD!\e[0m"
		echo " "
	exit 0
}

restart () {
	echo 
	echo "********************* Convert2Dualboot-SD for Linux **********************"
	echo " "
	echo -e "\e[1;32m--A tool to modify standard flashable ROM zips for Racks11479 DualbootSD--\e[0m"
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
