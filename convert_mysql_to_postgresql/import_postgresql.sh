#!/bin/bash

#######################################
# Config Parameters

# Create file /root/.pgpass with PostgreSQL credentials

# begin of file
# #hostname:port:database:username:password
# localhost:5432:bacula:bacula:bacula
# end of file

dir_backup="/tmp/bacula"
sequence="${dir_backup}/sequence.sql"
db_user="bacula"
db_name="bacula"
row_count="${dir_backup}/RowCountPg.log"
psql=`which psql`
#tables="BaseFiles CDImages Client Counters Device File FileSet Filename Job JobHisto JobMedia Location LocationLog Log Media MediaType Path PathHierarchy PathVisibility Pool RestoreObject Snapshot Status Storage UnsavedFiles Version"
tables="BaseFiles CDImages Client Counters Device File FileSet Filename Job JobHisto JobMedia Location LocationLog Log Media MediaType Path PathHierarchy PathVisibility Pool RestoreObject Snapshot Storage UnsavedFiles"

cd ${dir_backup}

#######################################
# Start Import
echo "-----------------------------------------------"
echo " Import Bacula Catalog from MySQL to PostgreSQL"
echo " Author:  Wanderlei Hüttel"
echo " Email:   wanderlei.huttel@gmail.com"
echo " Version: 1.1 - 25/10/2017"
echo "-----------------------------------------------"
starttimeg=`date +%s`
for table in ${tables}; do 
   log="${table}.log"
   starttime=`date +%s`
   ${psql} -U ${db_user} -d ${db_name} -f "${table}.sql" > /dev/null 2>> ${log}
   endtime=`date +%s`
   totaltime=`expr ${endtime} - ${starttime} + 10800`
   printf "Time to restore table %-20s %8s\n" ${table} `date -d @${totaltime} +%H:%M:%S`
done
endtimeg=`date +%s`
totaltimeg=`expr ${endtimeg} - ${starttimeg} + 10800`


#######################################
# Update sequences
echo "
SELECT SETVAL('basefiles_baseid_seq', (SELECT MAX(baseid) FROM basefiles));
SELECT SETVAL('client_clientid_seq', (SELECT MAX(clientid) FROM client));
SELECT SETVAL('device_deviceid_seq', (SELECT MAX(deviceid) FROM device));
SELECT SETVAL('file_fileid_seq', (SELECT MAX(fileid) FROM file));
SELECT SETVAL('filename_filenameid_seq', (SELECT MAX(filenameid) FROM filename));
SELECT SETVAL('fileset_filesetid_seq', (SELECT MAX(filesetid) FROM fileset));
SELECT SETVAL('job_jobid_seq', (SELECT MAX(jobid) FROM job));
SELECT SETVAL('jobmedia_jobmediaid_seq', (SELECT MAX(jobmediaid) FROM jobmedia));
SELECT SETVAL('location_locationid_seq', (SELECT MAX(locationid) FROM location));
SELECT SETVAL('locationlog_loclogid_seq', (SELECT MAX(loclogid) FROM locationlog));
SELECT SETVAL('log_logid_seq', (SELECT MAX(logid) FROM log));
SELECT SETVAL('media_mediaid_seq', (SELECT MAX(mediaid) FROM media));
SELECT SETVAL('mediatype_mediatypeid_seq', (SELECT MAX(mediatypeid) FROM mediatype));
SELECT SETVAL('path_pathid_seq', (SELECT MAX(pathid) FROM path));
SELECT SETVAL('pool_poolid_seq', (SELECT MAX(poolid) FROM pool));
SELECT SETVAL('restoreobject_restoreobjectid_seq', (SELECT MAX(restoreobjectid) FROM restoreobject));
SELECT SETVAL('snapshot_snapshotid_seq', (SELECT MAX(snapshotid) FROM snapshot));
SELECT SETVAL('storage_storageid_seq', (SELECT MAX(storageid) FROM storage));
" > ${sequence}
${psql} -U ${db_user} -d ${db_name} -f ${sequence} > /dev/null 2>> sequence.log
printf "Total time to restore all tables %18s\n" `date -d @${totaltimeg} +%H:%M:%S`

#######################################
# Count rows by tables
tables="BaseFiles CDImages Client Counters Device File FileSet Filename Job JobHisto JobMedia Location LocationLog Log Media MediaType Path PathHierarchy PathVisibility Pool RestoreObject Snapshot Status Storage UnsavedFiles Version"
echo "0|PostgreSQL" > ${row_count}
echo "-----------------------------------------------"
echo "Total row count tables"
echo "-----------------------------------------------"
sql_query="select table_name  from information_schema.tables where table_catalog = 'bacula' and table_schema = 'public' and table_name not like 'webacula_%' order by table_name"
for table in ${tables}; do 
   sql_query="select '$table' tabela, count(*) total from $table;"; 
   ${psql} -U ${db_user} ${db_name} -t -c "$sql_query" | tr '[:upper:]' '[:lower:]' >> ${row_count}; 
done
sed -i 's/\s//g' ${row_count}
sed -i '/^$/d' ${row_count}
sort ${row_count} -o ${row_count}
sed -i 's/0|PostgreSQL/PostreSQL/g' ${row_count}
cat ${row_count}


#######################################
# Update break line in table LogText
${psql} -U ${db_user} ${db_name} -c "UPDATE Log SET LogText = replace(LogText,'\n',E'\n');";

