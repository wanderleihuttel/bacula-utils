#!/bin/bash

#==============================================
# Backup Database Firebird Linux
# Author:  Wanderlei Hüttel
# Email:   wanderlei.huttel@gmail.com
# Version: 1.0 - 04/12/2018
#==============================================


#==============================================
# Date/time when script starts
starttime=$(date +%s)


#==============================================
# Set full path for Firebird gbak
gbak="/opt/firebird/bin/gbak"


#==============================================
# Config 
rootFolder="/firebird"                      # Root folder of firebird database
databaseFolder="${rootFolder}/database"     # Database Folder
backupFolder="${rootFolder}/backup"         # Backup Folder
fbDatabase="database.fdb"                   # Database file (.fdb)
fbBackup="database.fbk"                     # Backup file (.fbk)
fbLog="database.log"                        # Log file (.log)
fbUser="sysdba"                             # Firebird user
fbPassword="masterkey"                      # Firebird password

# Example of folder structure
# rootFolder -|
#             |- databaseFolder
#             |- backupFolder


#==============================================
# Verify if firebird dump and firebird log already exists in backup folder and exclude them
file1="${backupFolder}/${fbBackup}";
file2="${backupFolder}/${fbLog}";

if [ -f $file1 ]; then 
   \rm $file1
fi
   
if [ -f $file2 ]; then 
   \rm $file2
fi


#==============================================
# Start firebird backup
echo "gbak -B ${databaseFolder}/${fbDatabase} ${backupFolder}/${fbBackup} -Y ${backupFolder}/${fbLog} -user ${fbUser} -pass ${fbPassword}"
${gbak} -B ${databaseFolder}/${fbDatabase} ${backupFolder}/${fbBackup} -Y ${backupFolder}/${fbLog} -user ${fbUser} -pass ${fbPassword}
endtime=$(date +%s)
totaltime=$(expr ${endtime} - ${starttime})
echo "Firebird dump database started in:  $(date -d @${starttime} +%H:%M:%S)"
echo "Firebird dump database finished in: $(date -d @${endtime} +%H:%M:%S)"
echo "Elapsed time:                       $(date -ud @${totaltime} +%H:%M:%S)"
exit 0
