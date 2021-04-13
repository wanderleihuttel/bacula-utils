#!/bin/bash

#==============================================
# Send message jobs to telegram bot
# Author:  Wanderlei Hüttel
# Email:   wanderlei.huttel@gmail.com
# Version: 1.5 - 24/02/2020
#==============================================

#==============================================
# Config 
bconsole=$(which bconsole)
curl=$(which curl)
bc=$(which bc)

# Debug Messages
debug=0 # 0-Disable debug messages / 1-Enable debug messages


# Telegram config
# Use @BotFather to create a bot an get the API token
# Send a message to the Bot @userinfobot to get your id
# Or send a message to a bot created and
# Open in browser the url https://api.telegram.org/bot${api_token}/getUpdates 
# and get the value of id of user where the message line is.

api_token="change_with_your_api_key"
id="change_with_your_user_id"
log="/var/log/bacula/telegram.log"


#==============================================
# Function to convert bytes for human readable
function human_bytes(){
    slist=" Bytes, KB, MB, GB, TB, PB, EB, ZB, YB"
    power=1
    val=$( echo "scale=2; $1 / 1" | ${bc})
    vint=$( echo $val / 1024 | ${bc} )
    while [ ! $vint = "0" ]; do
        let power=power+1
        val=$( echo "scale=2; $val / 1024" | ${bc})
        vint=$( echo $val / 1024 | ${bc} )
    done
    echo $val$( echo $slist  | cut -f $power -d, )
}
# end function


# Function do debug script
function message_debug(){
    if [ $debug -eq 1 ]; then
        echo -ne "${1}\n"
    fi
}
# end function


message_debug "Debug: human_bytes '$(human_bytes 1024)'"
message_debug "Debug: bconsole - '${bconsole}'"
message_debug "Debug: curl - '${curl}'"
message_debug "Debug: bc - '${bc}'"
message_debug "Debug: api_token - '${api_token}'"
message_debug "Debug: id - '${id}'"


#==============================================
# SQL query to get data from Job (MySQL)
query_mysql="select Job.Name, Job.JobId,(select Client.Name from Client where Client.ClientId = Job.ClientId) as Client, Job.JobBytes, Job.JobFiles, case when Job.Level = 'F' then 'Full' when Job.Level = 'I' then 'Incremental' when Job.Level = 'D' then 'Differential' end as Level, (select Pool.Name from Pool where Pool.PoolId = Job.PoolId) as Pool, (select Storage.Name  from JobMedia left join Media on (Media.MediaId = JobMedia.MediaId) left join Storage on (Media.StorageId = Storage.StorageId) where JobMedia.JobId = Job.JobId limit 1 ) as Storage, date_format( Job.StartTime , '%d/%m/%Y %H:%i:%s' ) as StartTime, date_format( Job.EndTime , '%d/%m/%Y %H:%i:%s' ) as EndTime, sec_to_time(TIMESTAMPDIFF(SECOND,Job.StartTime,Job.EndTime)) as Duration, Job.JobStatus, (select Status.JobStatusLong from Status where Job.JobStatus = Status.JobStatus) as JobStatusLong from Job where Job.JobId=$1;"
message_debug "Debug: query_mysql - '${query_mysql}'"


#==============================================
# SQL query to get data from Job (PostgreSQL)
query_pgsql="select Job.Name, Job.JobId,(select Client.Name from Client where Client.ClientId = Job.ClientId) as Client, Job.JobBytes, Job.JobFiles, case when Job.Level = 'F' then 'Full' when Job.Level = 'I' then 'Incremental' when Job.Level = 'D' then 'Differential' end as Level, (select Pool.Name from Pool where Pool.PoolId = Job.PoolId) as Pool, (select Storage.Name from JobMedia left join Media on (Media.MediaId = JobMedia.MediaId) left join Storage on (Media.StorageId = Storage.StorageId) where JobMedia.JobId = Job.JobId limit 1 ) as Storage, to_char(Job.StartTime, 'DD/MM/YY HH24:MI:SS') as StartTime, to_char(Job.EndTime, 'DD/MM/YY HH24:MI:SS') as EndTime, to_char(endtime-starttime,'HH24:MI:SS') as Duration, Job.JobStatus, (select Status.JobStatusLong from Status where Job.JobStatus = Status.JobStatus) as JobStatusLong from Job where Job.JobId=$1;"
message_debug "Debug: query_pgsql - '${query_pgsql}'"


#==============================================
# Check database driver (PostgreSQL or MySQL)
check_database=$(echo "show catalog" | ${bconsole} | grep -i "pgsql\|postgres\|postgresql" | wc -l)
message_debug "Debug: check_database - '${check_database}'"
if [ $check_database -eq 1 ]; then
   sql_query=$query_pgsql
   message_debug "Debug: database type - 'PostgreSQL'"
else
  sql_query=$query_mysql
   message_debug "Debug: database type - 'MySQL'"
fi


#==============================================
# Execute command in bconsole
var="$(cat <<EOF
gui on
sqlquery
${sql_query}
#DONT_DELETE_THIS_LINE#
exit
EOF
)"
message_debug "Debug: var - '$(echo ${var} | ${bconsole})'"


#==============================================
# Execute SQL and get data from bconsole
str=$(echo "$var" | ${bconsole} |  grep "[\|]" | grep -vi "JobId" | sed 's/[[:space:]]*|[[:space:]]*/|/g' | sed 's/^|//g')
JobName=$(echo ${str} | cut -d"|" -f1)
JobId=$(echo ${str} | cut -d"|" -f2)
Client=$(echo ${str} | cut -d"|" -f3)
JobBytes=$(human_bytes $(echo ${str} | cut -d"|" -f4 | sed 's/,//g'))
JobFiles=$(echo ${str} | cut -d"|" -f5)
Level=$(echo ${str} | cut -d"|" -f6)
Pool=$(echo ${str} | cut -d"|" -f7)
Storage=$(echo ${str} | cut -d"|" -f8)
StartTime=$(echo ${str} | cut -d"|" -f9)
EndTime=$(echo ${str} | cut -d"|" -f10)
Duration=$(echo ${str} | cut -d"|" -f11)
JobStatus=$(echo ${str} | cut -d"|" -f12)
Status=$(echo ${str} | cut -d"|" -f13)
message_debug "Debug: str - '${str}'"

#==============================================
# Emojis
# OK
# http://emojipedia.org/white-heavy-check-mark/
# Not OK
# http://emojipedia.org/cross-mark/
# Floppy Disk
# http://emojipedia.org/floppy-disk/
# Different header in case of error
if [ "${JobStatus}" == "T" ] ; then
   header=">>>>> 💾 BACULA BACKUP ✅ <<<<</n"  # OK
else
   header=">>>>> 💾 BACULA BACKUP ❌ <<<<</n"  # Error
fi
message_debug "Debug: header - '${header}'"

#==============================================
# Format output of message
message="${header}/nJobName=${JobName}/nJobid=${JobId}/nClient=${Client}/nJobBytes=${JobBytes}/nJobFiles=${JobFiles}/nLevel=${Level}/nPool=${Pool}/nStorage=${Storage}/nStartTime=${StartTime}/nEndTime=${EndTime}/nDuration=${Duration}/nJobStatus=${JobStatus}/nStatus=${Status}"
messagelog="Message: JobName=${JobName} | Jobid=${JobId} | Client=${Client} | JobBytes=${JobBytes} | Level=${Level} | Status=${Status}"
message=$(echo ${message} | sed 's/\/n/%0A/g')
url="https://api.telegram.org/bot${api_token}/sendMessage?chat_id=${id}&text=${message}"
message_debug "Debug: message - '${message}'"
message_debug "Debug: messagelog - '${messagelog}'"
message_debug "Debug: url - '${url}'"

#==============================================
# Try to send message during 10 minutes
# in case of error
count=1
while [ ${count} -le 20 ]; do

    echo "$(date +%d/%m/%Y\ %H:%M:%S) - Start message send (attempt ${count}) ..." >> ${log}
    echo "$(date +%d/%m/%Y\ %H:%M:%S) - ${messagelog}" >> ${log}
    ${curl} -s "${url}" > /dev/null
    ret=$?
    message_debug "Debug: ret - '${ret}'"

    if [ ${ret} -eq 0 ]; then
        echo "$(date +%d/%m/%Y\ %H:%M:%S) - Attempt ${count} executed successfully!" >> ${log}
        message_debug "Debug: count - '${count}' - Done"
        exit 0
    else
        echo "$(date +%d/%m/%Y\ %H:%M:%S) - Attempt ${count} failed!" >> ${log}
        echo "$(date +%d/%m/%Y\ %H:%M:%S) - Waiting 30 seconds before retry ..." >> ${log}
        message_debug "Debug: count - '${count}'"
        sleep 30
        (( count++ ))
    fi

done
