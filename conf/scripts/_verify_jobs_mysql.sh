#!/bin/bash
# Script to Verify Jobs in Bacula

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Config 
DBHOST="localhost"
DBPORT="3306"
DBNAME="bacula"
DBUSER="bacula"
DBPASSWD="bacula"

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# SQL query to get data from Job (MySQL)

sql_query="SELECT Job.JobId, Job.Name, Job.Type, Job.Level,Client.Name, Job.JobStatus, FileSet.FileSet,
(SELECT DISTINCT Storage.Name FROM JobMedia LEFT JOIN Media ON (JobMedia.MediaId = Media.MediaId) 
LEFT JOIN Storage ON (Media.StorageId = Storage.StorageId)  WHERE JobMedia.JobId = Job.JobId
) AS Storage 
FROM Job, Client, FileSet
WHERE Job.ClientId = Client.ClientId and Job.FileSetId = FileSet.FileSetId
AND Job.EndTime > (NOW() - INTERVAL 1 DAY) AND Job.JobStatus = 'T' ORDER BY RAND() LIMIT 5;"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Execute SQL and get data from Job table
query=`mysql -u $DBUSER -p$DBPASSWD -D $DBNAME -h $DBHOST -P $DBPORT -N -t -e "$sql_query"`
c=10
echo -ne "$query" | grep -v "\-\-\-" | while read row; do
  JobId=`echo $row | cut -d"|" -f2 | sed 's/^ \(.*\) $/\1/'`;
  Client=`echo $row | cut -d"|" -f6 | sed 's/^ \(.*\) $/\1/'`;
  Fileset=`echo $row | cut -d"|" -f8 | sed 's/^ \(.*\) $/\1/'`;
  Storage=`echo $row | cut -d"|" -f9 | sed 's/^ \(.*\) $/\1/'`;
  echo "run job=Verify_VolumeToCatalog client=$Client fileset=$Fileset jobid=$JobId storage=$Storage priority=$c yes" | bconsole
  (( c++ ))
done
