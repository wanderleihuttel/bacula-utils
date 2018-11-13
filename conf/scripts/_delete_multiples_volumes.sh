#!/bin/bash
#######################################
bconsole=$(which bconsole)

clear
echo "--------------------------------------------"
echo " Script to delete volumes in mass"
echo " Author:  Wanderlei Hüttel"
echo " Email:   wanderlei.huttel@gmail.com"
echo " Version: 1.1 - 12/11/2018"
echo "--------------------------------------------"
echo ""

echo "list pools" | ${bconsole} | grep "[+|\|]"
read -p "Enter the name of the Pool that you would like to delete the volumes: " pool
echo "Selected Pool: ${pool}"
echo ""
read -p "Enter the status of the volumes you would like to check (Error, Used, Full, Append, Recycled): " volstatus

arraycount=$(echo "list media pool=${pool}" | ${bconsole}  | grep "|" | grep -v "MediaId" | grep "${volstatus}" | cut -d "|" -f3 | sed 's/ //g' | wc -l)
echo ""
for volname in $(echo "list media pool=${pool}" | ${bconsole}  | grep "|" | grep -v "MediaId" | grep "${volstatus}" | cut -d "|" -f3 | sed 's/ //g'); do
    echo " ${volname}" ;
done
echo ""

if [ ${arraycount} == "0" ]; then
    echo -e "No volumes found with status '${volstatus}'\n"
    echo -e "Operation aborted!\n"
    exit
else
    echo -e "${arraycount} volumes was found with status '${volstatus}'\n"
fi

read -p "Are you sure you want to delete all ${arraycount} volumes? This operation is irreversible! (Y-Yes / N-No) " confirm
if [ "${confirm}" == "y" ] || [ "${confirm}" == "Y" ]; then
    for volname in $(echo "list media pool=${pool}" | ${bconsole}  | grep "|" | grep -v "MediaId" | grep "${volstatus}" | cut -d "|" -f3 | sed 's/ //g'); do
        echo "delete volume=${volname} pool=${pool} yes" ;
        # Uncomment the line below to exclude the volumes in the catalog
        #echo "delete volume=${volname} pool=${pool} yes" | ${bconsole} ;

        # Uncomment the line below and change the path of storage to remove volume from the disk also
        # rm -f /path/to/storage/${volname}
    done
    echo -e "Operation finished with success!\n"
else
    echo -e "Operation aborted!\n"
fi
