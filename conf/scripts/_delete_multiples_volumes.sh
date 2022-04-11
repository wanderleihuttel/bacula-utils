#!/bin/bash
#######################################
bconsole=$(which bconsole)

clear
echo "
 --------------------------------------------
 Script to delete volumes in mass
 Author:  Wanderlei Hüttel
 Email:   wanderlei.huttel@gmail.com
 Version: 1.3 - 11/04/2022
 --------------------------------------------
"

$bconsole <<< "list pools" | grep "[+|\|]"
read -p "Enter the [NAME OF THE POOL] that you would like to delete the volumes: " pool
echo -e "Selected Pool: ${pool}\n"
read -p "Enter the [STATUS OF THE VOLUME] that you would like to check (Error, Used, Full, Append, Recycled): " volstatus

volumearray=($( $bconsole <<< "list media pool=${pool}" | grep "|" | grep -v "MediaId" | grep "$volstatus" | cut -d "|" -f3 | sed -E 's/\s+//g' ))
echo
for volumename in ${volumearray[@]}; do
    echo " $volumename" ;
done
echo

if [[ ${#volumearray[@]} == "0" ]]; then
    echo -e "No volumes found in the pool '$pool' with status '$volstatus'\n"
    echo -e "Operation aborted!\n"
    exit
else
    echo -e "${#volumearray[@]} volumes was found with status '$volstatus'\n"
fi

read -p "Are you sure you want to delete all ${#volumearray[@]} volumes? This operation is irreversible! (Y-Yes / N-No) " confirm
if [[ "${confirm,,}" == "y" ]]; then
     for volumename in ${volumearray[@]}; do
        echo "delete volume=$volumename pool=$pool yes" ;
        # Uncomment the line below to exclude the volumes in the catalog
        # $bconsole <<< "delete volume=$volumename pool=$pool yes"

        # Uncomment the line below and change the path of storage to remove volume from the disk also
        # rm -f /path/to/storage/$volumename
    done
    echo -e "Operation finished with success!\n"
else
    echo -e "Operation aborted!\n"
fi
