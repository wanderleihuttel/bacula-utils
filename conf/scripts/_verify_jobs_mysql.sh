#!/bin/bash
# Script to Verify Jobs in Bacula

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Bacula Database Config
DBHOST="localhost"
DBPORT="3306"
DBNAME="bacula"
DBUSER="bacula"
DBPASSWD="bacula"

BCONSOLE="/sbin/bconsole"
MYSQL="/usr/bin/mysql"

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Check day of Week
# The normal backups are executed from monday-friday 
# If verify jobs run on monday, sql needs to get jobs from last friday
WEEKDAY=$(date +%w)
if [ $WEEKDAY -eq 1 ] ; then
   NUMBEROFDAYS=3
else
   NUMBEROFDAYS=1
fi


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# SQL query to get data from Job (MySQL)
if [ $# -eq 1 ]; then
   sql_query="SELECT Job.JobId, Job.Name, Client.Name as Client, FileSet.FileSet,
   (SELECT DISTINCT Storage.Name FROM JobMedia LEFT JOIN Media ON (JobMedia.MediaId = Media.MediaId)
   LEFT JOIN Storage ON (Media.StorageId = Storage.StorageId)  WHERE JobMedia.JobId = Job.JobId
   ) AS Storage
   FROM Job, Client, FileSet
   WHERE Job.ClientId = Client.ClientId and Job.FileSetId = FileSet.FileSetId
   AND Job.JobStatus = 'T' AND Job.Jobid = $1";
else
   sql_query="SELECT Job.JobId, Job.Name, Client.Name as Client, FileSet.FileSet,
   (SELECT DISTINCT Storage.Name FROM JobMedia LEFT JOIN Media ON (JobMedia.MediaId = Media.MediaId) 
   LEFT JOIN Storage ON (Media.StorageId = Storage.StorageId)  WHERE JobMedia.JobId = Job.JobId
   ) AS Storage 
   FROM Job, Client, FileSet
   WHERE Job.ClientId = Client.ClientId and Job.FileSetId = FileSet.FileSetId
   AND Job.EndTime > (NOW() - INTERVAL $NUMBEROFDAYS DAY) AND Job.JobStatus = 'T' ORDER BY RAND() LIMIT 5;"
fi
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Verify Jobs Used
#verify_array=( "Verify_Data" "Verify_VolumeToCatalog") 
verify_array=( "Verify_Data") 


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Execute SQL and get data from Job table
query=`echo "$sql_query" | $MYSQL -u $DBUSER -p$DBPASSWD -D $DBNAME -h $DBHOST -P $DBPORT  -N -t`
c=10

echo "$query" | grep -v "\-\-\-" | while read row; do
  JobId=`echo $row | cut -d"|" -f2 | sed 's/^ \(.*\) $/\1/'`;
  JobName=`echo $row | cut -d"|" -f3 | sed 's/^ \(.*\) $/\1/'`;
  Client=`echo $row | cut -d"|" -f4 | sed 's/^ \(.*\) $/\1/'`;
  Fileset=`echo $row | cut -d"|" -f5 | sed 's/^ \(.*\) $/\1/'`;
  Storage=`echo $row | cut -d"|" -f6 | sed 's/^ \(.*\) $/\1/'`;
  Verify_Job=`printf '%s\n' "${verify_array[@]}" | shuf -n1`
  JobIdRun=`echo "run job=$Verify_Job  client=$Client  fileset=$Fileset  jobid=$JobId  storage=$Storage  priority=$c  yes" | $BCONSOLE | grep "JobId" | sed 's/[^0-9]*//g'`
  # Execute the job in bconsole
  echo "run job=$Verify_Job  client=$Client  fileset=$Fileset  jobid=$JobId  storage=$Storage  priority=$c  yes"
  (( c++ ))
  sleep 1 
  # The MySQL command update Job name including the Job that was verified
  if [ "$JobIdRun" != "" ]; then
     $MYSQL -u $DBUSER -p$DBPASSWD -D $DBNAME -h $DBHOST -P $DBPORT -e "update Job set Name = '$JobName (V)' where JobId = $JobIdRun;"
  fi
done
