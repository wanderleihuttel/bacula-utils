#!/bin/bash
# Script to disable schedule in holidays

# Crontab
# 00 18 * * 1-7 /etc/bacula/scripts/_disable_backup_holidays.sh > /dev/null

# Define an array of holidays (%m-%d)
array_holidays=( "01-01" "03-25" "03-27" "04-21" "05-01" "05-26" "09-07" "10-12" "11-02" "11-15" "12-25")
today=$(date +%m-%d)
for holiday in "${array_holidays[@]}"; do
   if [ "${holiday}" == "{$today}" ]; then
      for j in $(echo ".schedule" | bconsole | sed '1,4d;' | grep -v "You have messages"); do 
         echo "disable schedule=${j}" | bconsole > /dev/null
         echo "The schedule \"${j}\" was disabled today!"
      done
      exit 0
   fi
done
echo "reload" | bconsole > /dev/null
echo "Is not holiday today! Bacula will execute normal!"
exit 0
