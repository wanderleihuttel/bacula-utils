#!/bin/bash
# A menu driven shell script sample template 
## ----------------------------------
# Step #1: Define variables
# ----------------------------------
RED='\033[0;41;30m'
STD='\033[0;0;39m'
BLUE='\033[1;40;34m'
GREEN='\033[1;40;32m'
YELLOW='\033[0;40;33m'
bconsole=$(which bconsole)
POOL=""
DEVICE=""
DEVICES="/etc/autochanger.conf"

# ----------------------------------
# Step #2: User defined function
# ----------------------------------
pause(){
   read -p "Press [Enter] key to continue..." fackEnterKey
}
############################################################################################
# List pools
list_pool(){
   clear
   echo "+----------------------------+"
   echo "| Pools                      |"
   echo "+----------------------------+"

   pools=(`echo "llist pool" | $bconsole | grep "Name:" | cut -d":" -f2 | sed 's/\s//g' | sort`)
   count=0
   for i in ${pools[@]}; do count=`expr $count + 1`; printf "%3s) %s\n" $count $i; done
   echo ""
   pause
}
 

############################################################################################
# List volume by pool
list_volumes(){
   clear
   select_pool
   count=0
   volumes=(`echo "llist volume pool=$POOL" | $bconsole | grep "VolumeName:" | cut -d":" -f2 | sed 's/\s//g' | sort`)
   echo "+----------------------------+"
   echo "| Volumes                    |"
   echo "+----------------------------+"
   for i in ${volumes[@]}; do count=`expr $count + 1`; printf "%3s) %s\n" $count $i; done
   if [ ${#volumes[@]} -eq 0 ]; then
      echo "The Pool \"$POOL\" does not contain any volumes!"
   fi
   echo ""
   pause
}

############################################################################################
# Select pools
select_pool(){
   #clear
   echo "+----------------------------+"
   echo "| Pools                      |"
   echo "+----------------------------+"

   pools=(`echo "llist pool" | $bconsole | grep "Name:" | cut -d":" -f2 | sed 's/\s//g' | sort`)
   count=0
   for i in ${pools[@]}; do count=`expr $count + 1`; printf "%3s) %s\n" $count $i; done
   echo -ne "Choose a pool (1-$count): "
   read pool_option


   while [ -n $pool_option ]; do
       if [ $pool_option -ge 1 ]  && [ $pool_option -le ${#pools[@]} ]; then
          pool_name=${pools[$pool_option-1]};
          break
       else
          echo -ne "Choose a pool (1-$count): ";
          read pool_option
       fi
   done

   POOL=$pool_name
   echo -ne "\nPool selected:   $pool_name\n\n"
}
 
############################################################################################
# Select device
select_device(){
   #clear
   echo "+----------------------------+"
   echo "| Devices                    |"
   echo "+----------------------------+"

   devices=(`cat $DEVICES | grep -i "d:" | sed  's/d://gI'`)
   count=0
   for i in ${devices[@]}; do count=`expr $count + 1`; printf "%3s) %s\n" $count $i; done
   echo -ne "Choose a device (1-$count): "
   read device_option

   while [ -n $device_option ]; do
       if [ $device_option -ge 1 ]  && [ $device_option -le ${#devices[@]} ]; then
          device_name=${devices[$device_option-1]};
          break
       else
          echo -ne "Choose a device (1-$count): ";
          read device_option
       fi
   done

   DEVICE=$device_name
   echo -ne "\nDevice selected: $device_name\n\n"
}
 


############################################################################################
# Create volumes 
create_single_volume(){
   clear
   select_pool 
   select_device
   count=0
   volumes=(`echo "llist volume pool=$POOL" | $bconsole | grep "VolumeName:" | cut -d":" -f2 | sed 's/\s//g' | sort`)
   echo "+----------------------------+"
   echo "| Volumes                    |"
   echo "+----------------------------+"
   for i in ${volumes[@]}; do count=`expr $count + 1`; printf "%3s) %s\n" $count $i; done
   echo -ne "\nType the volume name: ";
   read volume_name
   if [ "x$volume_name" != "x" ]; then
      echo "label media pool=$POOL volume=$volume_name slot=0" | $bconsole
      mv /backup/$volume_name $DEVICE
      ln -s $DEVICE/$volume_name /backup/$volume_name
      chmod 775 $DEVICE/$volume_name
   fi
   pause
}
 

############################################################################################
# Create multiples volumes 
create_multiples_volumes(){
   clear
   select_pool 
   select_device
   count=0
   volumes=(`echo "llist volume pool=$POOL" | $bconsole | grep "VolumeName:" | cut -d":" -f2 | sed 's/\s//g' | sort`)
   echo "+----------------------------+"
   echo "| Volumes                    |"
   echo "+----------------------------+"
   for i in ${volumes[@]}; do count=`expr $count + 1`; printf "%3s) %s\n" $count $i; done
   echo -ne "\nType the prefix of volume name: ";
   read prefix_name
   echo -ne "\nType the start number of volume: ";
   read start_volume
   echo -ne "\nType the amount of volumes to create: ";
   read count_volume
   a=$start_volume
   b=`expr $a + $count_volume - 1`
   echo ""
   if [ "x$prefix_name" != "x" ]; then
      for i in $(eval echo {$a..$b}) ; do
        volume_name=`printf "$prefix_name%04d" $i`
        echo "label media pool=$POOL volume=$volume_name slot=0" | $bconsole
        mv /backup/$volume_name $DEVICE
        ln -s $DEVICE/$volume_name /backup/$volume_name
        chmod 775 $DEVICE/$volume_name
      done
         
   fi
   pause
}
 
############################################################################################
# Recreate symlinks 
create_symlink(){
   clear
   echo "+----------------------------+"
   echo "| Symbolic Links             |"
   echo "+----------------------------+"
   vdevice=(`cat $DEVICES | grep -i "v:" | sed  's/v://gI'`)
   devices=(`cat $DEVICES | grep -i "d:" | sed  's/d://gI'`)
   count=0
   find $vdevice -type l -delete
   for i in ${devices[@]}; do 
      count=`expr $count + 1`; 
      for v in `find $i -type f | sort`; do 
        volume_name=`basename $v`;
        echo "$v => $vdevice/$volume_name"
        ln -s $v $vdevice/$volume_name
      done
      echo ""
   done
   pause
}
 
############################################################################################
# Help
show_help(){
   clear
   echo "+----------------------------+"
   echo "| Help                       |"
   echo "+----------------------------+"
   echo "1) This script is used to manage a Bacula Autochanger with multiples disks "
   echo "   with symlinks for a single folder"
   echo ""
   echo ""
   echo "2) Create the file /etc/autochanger.conf with devices"
   echo "  # Example "
   echo "  # D = Phisical Device (real volume storage)"
   echo "  # V = Virtual Device (fake storage, folder with the symlinks for the real storage)"
   echo "  V:/backup"
   echo "  D:/mnt/disco01"
   echo "  D:/mnt/disco02"
   echo "  D:/mnt/disco03"
   echo ""
   echo ""
   echo "3) The volume labels must have a prefix followed by 4 digits number "
   echo "  Example:"
   echo "  Volume Name: Volume-Daily-0001, VolumeWeekly-0015, Volume_Monthly_0034, Volume0007"
   echo "  Prefix       Volume-Daily-,     VolumeWeekly-,     Volume_Monthly_,     Volume"
   echo "  This is useful to create multiples volumes at the same time"
   echo ""
   echo ""
   pause

}
############################################################################################
# function to display menus
show_menus() {
   clear
   echo "+----------------------------+"
   echo "| Bacula Autochanger Manager |"
   echo "| Version 0.1                |"
   echo "| Author Wanderlei Hüttel    |"
   echo "+----------------------------+"
   echo "----------------------------"
   echo " Menu options"
   echo "----------------------------"
   echo "1) Create a single volume"
   echo "2) Create multiples volumes"
   echo "3) Recreate symbolic links"
   echo "4) List pools"
   echo "5) List volumes by pool"
   echo "h) Help"
   echo "q) Quit"

}
 
############################################################################################
# Menu read options
read_options(){
   local choice
   read -p "Enter your choice (1-4): " choice
   echo ""
   case $choice in
      1) create_single_volume ;;
      2) create_multiples_volumes ;;
      3) create_symlink ;;
      4) list_pool ;;
      5) list_volumes ;;
    "h") show_help ;;
    "q") exit 0;;
      *) echo -ne "${RED}Error...${STD}" && sleep 1
   esac
}
 
############################################################################################
# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 
############################################################################################
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
   show_menus
   read_options
done
