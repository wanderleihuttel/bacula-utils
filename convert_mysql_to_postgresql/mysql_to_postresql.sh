#!/bin/bash

#######################################
# Config Parameters
db_user="root"
db_password=""
db_name="bacula"
dir_backup="/tmp/bacula"
row_count="${dir_backup}/RowCountMySQL.log"

mysql=`which mysql`
mysqldump=`which mysqldump`

tables="BaseFiles CDImages Client Counters Device File FileSet Filename Job JobHisto JobMedia Location LocationLog Log Media MediaType Path PathHierarchy PathVisibility Pool RestoreObject Snapshot Status Storage UnsavedFiles Version"

#######################################
# Check if the password is not empty
if [ ! -z ${db_password} ]; then
  db_password="-p${db_password}"
fi

#######################################
# 
echo "--------------------------------------------"
echo " Convert Bacula Catalog MySQL to PostgreSQL"
echo " Author:  Wanderlei Hüttel"
echo " Email:   wanderlei.huttel@gmail.com"
echo " Version: 1.1 - 25/10/2017"
echo "--------------------------------------------"
starttimeglobal=`date +%s`
for table in ${tables}; do
   starttime=`date +%s`

   echo "\set AUTOCOMMIT OFF" >> "${table}.sql"
   ${mysqldump} --no-create-info \
                --no-create-db \
                --complete-insert \
                --compatible=postgresql \
                --skip-quote-names \
                --disable-keys \
                --lock-tables \
                --compact \
                --skip-opt \
                --quick \
                -u ${db_user} ${db_password} ${db_name} ${table} | \
                sed -e 's/0000-00-00 00:00:00/1970-01-01 00:00:00/g' | \
                sed -e 's/\\0//g' | \
                sed -e 's/\\"/"/g' | \
                sed -e 's/\\\\/\\/g' | \
                sed -e "s/\\\'/\'\'/g" >> "${table}.sql"
                echo "COMMIT;" >> "${table}.sql"

   endtime=`date +%s`
   totaltime=`expr ${endtime} - ${starttime} + 10800`
   printf "Dump table %-15s Time: %8s\n" ${table} `date -d @${totaltime} +%H:%M:%S`
done
endtimeglobal=`date +%s`
totaltimeglobal=`expr ${endtimeglobal} - ${starttimeglobal} + 10800`
echo "" > ${row_count}
echo "--------------------------------------------"
echo "Total row count tables"
echo "--------------------------------------------"
echo "0|MySQL" > ${row_count}
for table in ${tables} ; do
   sql_query="select '$table' as tabela, count(*) as total from $table;"
   ${mysql} -u ${db_user} -D ${db_name} ${db_password} -N  -B -e "$sql_query" | sed 's/\t/\|/g' | tr '[:upper:]' '[:lower:]' >> ${row_count}
done
sed -i 's/\s//g' ${row_count}
sed -i '/^$/d' ${row_count}
sort ${row_count} -o ${row_count}
sed -i 's/0|MySQL/MySQL/g' ${row_count}
cat ${row_count}
echo "--------------------------------------------"
echo "Total dump tables          Time: `date -d @${totaltimeglobal} +%H:%M:%S`"
echo "--------------------------------------------"
