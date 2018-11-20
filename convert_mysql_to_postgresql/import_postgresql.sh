#!/bin/bash

#######################################
# Config Parameters

# Create file /root/.pgpass with PostgreSQL credentials

# begin of file
# #hostname:port:database:username:password
# localhost:5432:bacula:bacula:bacula
# end of file

sequence="sequence.sql"
db_user="bacula"
db_name="bacula"
row_count="RowCountPg.log"
psql=$(which psql)
# List of Bacula Tables
# tables (Status and Version) are not imported, they are generated during make_postgresql_tables script
tables="BaseFiles CDImages Client Counters Device File FileSet Filename Job JobHisto JobMedia Location LocationLog Log Media MediaType Path PathHierarchy PathVisibility Pool RestoreObject Snapshot Storage UnsavedFiles"

#######################################
# Start Import
echo "-----------------------------------------------"
echo " Import Bacula Catalog from MySQL to PostgreSQL"
echo " Author:  Wanderlei Hüttel"
echo " Email:   wanderlei.huttel@gmail.com"
echo " Version: 1.3 - 20/11/2018"
echo "-----------------------------------------------"
echo
echo "Importing MySQL tables ..."
echo "--------------------------------------------"
echo "Table           Time"
echo "--------------------------------------------"

totalstarttime=$(date -u +%s)
for table in ${tables}; do 
   log="${table}.log"
   starttime=$(date -u +%s)
   ${psql} -U ${db_user} -d ${db_name} -f "${table}.sql" > /dev/null 2>> ${log}
   endtime=$(date -u +%s)
   elapsedtime=$(expr ${endtime} - ${starttime})
   printf "%-15s %8s\n" ${table} $(date -ud @${elapsedtime} +%H:%M:%S)
done


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
totalendtime=$(date -u +%s)
totalelapsedtime=$(expr ${totalendtime} - ${totalstarttime})

echo "--------------------------------------------"
echo "Elapsed time:   $(date -ud @${totalelapsedtime} +%H:%M:%S)"
echo "--------------------------------------------"
echo 
echo 
echo "" > ${row_count}

#######################################
# Count rows by tables
tables="BaseFiles CDImages Client Counters Device File FileSet Filename Job JobHisto JobMedia Location LocationLog Log Media MediaType Path PathHierarchy PathVisibility Pool RestoreObject Snapshot Status Storage UnsavedFiles Version"
echo "Total tables row count"
echo "--------------------------------------------"
echo "Table           Row Count"
echo "--------------------------------------------"

sql_query="select table_name  from information_schema.tables where table_catalog = 'bacula' and table_schema = 'public' and table_name not like 'webacula_%' order by table_name"
for table in ${tables}; do 
   sql_query="select '$table' tabela, count(*) total from $table;"; 
   ${psql} -U ${db_user} ${db_name} -t -c "$sql_query" | tr '[:upper:]' '[:lower:]' >> ${row_count}; 
done
sed -i 's/\s//g' ${row_count}
sed -i '/^$/d' ${row_count}
sort ${row_count} -o ${row_count}
output=$(<${row_count})
output=$(echo -e $output | sed 's/[|]/\t/g')
printf "%-15s %8s\n" $output
echo "--------------------------------------------"
echo
echo

#######################################
# Update break line in table LogText
echo "--------------------------------------------"
echo "Updating break line in table LogText..."
${psql} -U ${db_user} ${db_name} -c "UPDATE Log SET LogText = replace(LogText,'\n',E'\n');";
echo "--------------------------------------------"
echo 
echo "Done"
