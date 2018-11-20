#!/bin/bash

#######################################
# Config Parameters
db_username="root"
db_password=""
db_name="bacula"
db_host="localhost"
row_count="RowCountMySQL.log"

echo "--------------------------------------------"
echo " Convert Bacula Catalog MySQL to PostgreSQL"
echo " Author:  Wanderlei Hüttel"
echo " Email:   wanderlei.huttel@gmail.com"
echo " Version: 1.3 - 20/11/2018"
echo
echo "--------------------------------------------"
echo "Please inform your database credentials..."
read -p  "MySQL db_name:     " -i "${db_name}" -e db_name
read -p  "MySQL db_username: " -i "${db_username}" -e db_username
read -p  "MySQL db_host:     " -i "${db_host}" -e db_host
read -p "MySQL db_password ${db_username}: " -s db_password
echo 
echo "--------------------------------------------"

mysql=$(which mysql)
mysqldump=$(which mysqldump)

# List of Bacula Tables
tables="BaseFiles CDImages Client Counters Device File FileSet Filename Job JobHisto JobMedia Location LocationLog Log Media MediaType Path PathHierarchy PathVisibility Pool RestoreObject Snapshot Status Storage UnsavedFiles Version"

#######################################
# Check if the password is not empty
if [ ! -z ${db_password} ]; then
    db_password="-p${db_password}"
fi

#######################################
#
echo
echo "Dumping MySQL tables ..."
echo "--------------------------------------------"
echo "Table           Time"
echo "--------------------------------------------"
totalstarttime=$(date -u +%s)
for table in ${tables}; do
    starttime=$(date -u +%s)

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
                 -h ${db_host} -u ${db_username} ${db_password} ${db_name} ${table} | \
                 sed -e 's/0000-00-00 00:00:00/1970-01-01 00:00:00/g' | \
                 sed -e 's/\\0//g' | \
                 sed -e 's/\\"/"/g' | \
                 sed -e 's/\\\\/\\/g' | \
                 sed -e "s/\\\'/\'\'/g" | \
                 sed -e "s/_binary//g" \
                 >> "${table}.sql"
                 echo "COMMIT;" >> "${table}.sql"

    endtime=$(date -u +%s)
    elapsedtime=$(expr ${endtime} - ${starttime})
    printf "%-15s %8s\n" ${table} $(date -ud @${elapsedtime} +%H:%M:%S)
done
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
for table in ${tables} ; do
    sql_query="select '$table' as tabela, count(*) as total from $table;"
    ${mysql} -h ${db_host} -u ${db_username} -D ${db_name} ${db_password} -N  -B -e "$sql_query" \
    | sed 's/\t/\|/g' | tr '[:upper:]' '[:lower:]' >> ${row_count}
done

sed -i 's/\s//g' ${row_count}
sed -i '/^$/d' ${row_count}
sort ${row_count} -o ${row_count}
echo "Total tables row count"
echo "--------------------------------------------"
echo "Table           Row Count"
echo "--------------------------------------------"
output=$(<${row_count})
output=$(echo -e $output | sed 's/[|]/\t/g')
printf "%-15s %8s\n" $output
echo "--------------------------------------------"
echo
echo "Done"
