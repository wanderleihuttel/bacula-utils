#!/bin/bash

#===============================================
# Script to disable schedule on holidays
# Author:  Wanderlei Hüttel
# Email:   wanderlei.huttel@gmail.com
# Version: 1.1 - 09/03/2020
#===============================================

# Put the execution in Crontab
# 00 18 * * 1-7 /etc/bacula/scripts/_disable_backup_holidays.sh > /dev/null

bconsole=$(which bconsole)
today=$(date +%m-%d)

# Ann array with holidays (%m-%d)
holidays=("01-01, 03-25, 03-27, 04-21, 05-01, 05-26, 09-07, 10-12, 11-02, 11-15, 12-25")

# Get schedules from Bacula
schedules=$(echo ".schedule" | ${bconsole} | sed '1,4d;' | grep -v "You have messages")

# Disable schedules
for holiday in $(echo "${holidays}" | tr "," "\n"); do
    # Check if today is a holiday
    if [ "${holiday}" == "${today}" ]; then
        echo -e "Today is a holiday! All schedules were disabled!\n"
        # Disable as schedules and finish
        for schedule in $(echo ${schedules}); do
            echo "disable schedule=${schedule}" | ${bconsole} > /dev/null
            echo "The schedule \"${schedule}\" are disable in ${today}!"
        done
        exit 0
    fi
done


# Enable schedules
echo -e "Is not holiday today! All schedules were enabled!\n"
for schedule in $( echo ${schedules} ); do
    echo "enable schedule=${schedule}" | ${bconsole} > /dev/null
    echo "The schedule \"${schedule}\" are enable in ${today}!"
done

exit 0
