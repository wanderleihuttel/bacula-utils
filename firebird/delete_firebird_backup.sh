#!/bin/bash

#==============================================
# Backup Database Firebird Linux
# Author:  Wanderlei Hüttel
# Email:   wanderlei.huttel@gmail.com
# Version: 1.0 - 04/12/2018
#==============================================


#==============================================
# Date/time when script starts


#==============================================
# Config 
rootFolder="/firebird"                      # Root folder of firebird database
backupFolder="${rootFolder}/backup"         # Backup Folder
fbBackup="database.fbk"                     # Backup file (.fbk)
fbLog="database.log"                        # Log file (.log)


#==============================================
# Verify if firebird dump and firebird log already exists in backup folder and exclude them
file1="${backupFolder}/${fbBackup}";
file2="${backupFolder}/${fbLog}";

if [ -f ${file1} ]; then 
   \rm ${file1}
   echo "Arquivo ${file1} excluido com sucesso!"
fi
   
if [ -f ${file2} ]; then 
   \rm ${file2}
   echo "Arquivo ${file2} excluido com sucesso!"
fi
exit 0
