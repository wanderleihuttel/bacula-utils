#!/bin/bash

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Function to convert bytes for human readable
b2h(){
    # Spotted Script @: http://www.linuxjournal.com/article/9293?page=0,1
    SLIST=" bytes, KB, MB, GB, TB, PB, EB, ZB, YB"
    POWER=1
    VAL=$( echo "scale=2; $1 / 1" | bc)
    VINT=$( echo $VAL / 1024 | bc )
    while [ ! $VINT = "0" ]
    do
        let POWER=POWER+1
        VAL=$( echo "scale=2; $VAL / 1024" | bc)
        VINT=$( echo $VAL / 1024 | bc )
    done
    echo $VAL$( echo $SLIST  | cut -f$POWER -d, )
}
# end function 

# Variables
HOUR=$(date +%d/%m/%Y\ %H:%M:%S)


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Config 
DBHOST="localhost"
DBPORT="5432"
DBNAME="bacula"
DBUSER="bacula"
DBPASSWD="bacula"
# Use @BotFather to create a bot an get the API token
# Telegram config
API_TOKEN="CHANGE_WITH_YOUR_API_KEY"
# Send a message to bot and 
# Open in browser the url https://api.telegram.org/bot${API_TOKEN}/getUpdates and get the id value os user
ID="CHANGE_WITH_YOUR_USER_ID"
LOG="/var/log/telegram.log"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# SQL query to get data from Job (PostreSQL)
sql_query="select Job.Name, Job.JobId,(select Client.Name from Client where Client.ClientId = Job.ClientId) as Client, Job.JobBytes, Job.JobFiles, case when Job.Level = 'F' then 'Full' when Job.Level = 'I' then 'Incremental' when Job.Level = 'D' then 'Differential' end as Level, (select Pool.Name from Pool where Pool.PoolId = Job.PoolId) as Pool, (select Storage.Name  from JobMedia left join Media on (Media.MediaId = JobMedia.MediaId) left join Storage on (Media.StorageId = Storage.StorageId) where JobMedia.JobId = Job.JobId limit 1 ) as Storage, to_char(Job.StartTime, 'DD/MM/YY HH24:MI:SS') as StartTime, to_char(Job.EndTime, 'DD/MM/YY HH24:MI:SS') as EndTime, to_char(endtime-starttime,'HH24:MI:SS') as Duration, Job.JobStatus, (select Status.JobStatusLong from Status where Job.JobStatus = Status.JobStatus) as JobStatusLong from Job where Job.JobId=$1;"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Execute SQL and get data from Job table
str=`psql -d $DBNAME -U $DBUSER -h $DBHOST -p $DBPORT -c "$sql_query" --no-align -t`
JobName=`echo $str | cut -d"|" -f1`
JobId=`echo $str | cut -d"|" -f2`
Client=`echo $str | cut -d"|" -f3`
JobBytes=`b2h $(echo $str | cut -d"|" -f4)`
JobFiles=`echo $str | cut -d"|" -f5`
Level=`echo $str | cut -d"|" -f6`
Pool=`echo $str | cut -d"|" -f7`
Storage=`echo $str | cut -d"|" -f8`
StartTime=`echo $str | cut -d"|" -f9`
EndTime=`echo $str | cut -d"|" -f10`
Duration=`echo $str | cut -d"|" -f11`
JobStatus=`echo $str | cut -d"|" -f12`
Status=`echo $str | cut -d"|" -f13`


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Emojis
# OK
# http://emojipedia.org/white-heavy-check-mark/
# Not OK
# http://emojipedia.org/cross-mark/
# Floppy Disk
# http://emojipedia.org/floppy-disk/
# Different header in case of error
if [ "$JobStatus" == "T" ] ; then
   HEADER=">>>>> 💾 BACULA BACKUP ✅ <<<<</n"  # OK
else
   HEADER=">>>>> 💾 BACULA BACKUP ❌ <<<<</n"  # Error
fi


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Format output of message
MESSAGE="$HEADER/nJobName=$JobName/nJobid=$JobId/nClient=$Client/nJobBytes=$JobBytes/nJobFiles=$JobFiles/nLevel=$Level/nPool=$Pool/nStorage=$Storage/nStartTime=$StartTime/nEndTime=$EndTime/nDuration=$Duration/nJobStatus=$JobStatus/nStatus=$Status"
MESSAGELOG="Message: JobName=$JobName | Jobid=$JobId | Client=$Client | JobBytes=$JobBytes | Level=$Level | Status=$Status"
MESSAGE=`echo $MESSAGE | sed 's/\/n/%0A/g'`
URL="https://api.telegram.org/bot${API_TOKEN}/sendMessage?chat_id=${ID}&text=$MESSAGE"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Loop multiple tries
COUNT=1
while [ $COUNT -le 20 ]; do

   echo "$(date +%d/%m/%Y\ %H:%M:%S) - Start message send (attempt $COUNT) ..." >> $LOG
   echo "$(date +%d/%m/%Y\ %H:%M:%S) - $MESSAGELOG" >> $LOG
   /usr/bin/curl -s "$URL" > /dev/null
   RET=$?

   if [ $RET -eq 0 ]; then
     echo "$(date +%d/%m/%Y\ %H:%M:%S) - Attempt $COUNT executed successfully!" >> $LOG 
     exit 0
   else
     echo "$(date +%d/%m/%Y\ %H:%M:%S) - Attempt $COUNT failed!" >> $LOG 
     echo "$(date +%d/%m/%Y\ %H:%M:%S) - Waiting 30 seconds before retry ..." >> $LOG
     sleep 30
     (( COUNT++ ))
   fi

done
