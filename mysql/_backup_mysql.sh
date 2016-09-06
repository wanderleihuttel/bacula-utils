#!/bin/bash
# Backup MySQL Databases

# Directory to store backups
DST=/usr/local/backup_mysql

# The MySQL username and password
DBUSER="root"
DBPASS=""

# A regex, passed to egrep -v, for which databases to ignore
IGNREG='^information_schema$|^performance_schema$|^bacula$|^mysql$'

# Date to create folder
DATE=$(date  +%Y-%m-%d)

# Check if password exist
if [ -n "$DBPASS" ]
then
    PASSWD="-p$DBPASS"
else
    PASSWD=""
fi

# Remove older backups
cd ${DST}
find ${DST} -type f -name *.sql -exec rm -f {} \;
rmdir $DST/* 2>/dev/null

# Create folder with the current date
mkdir -p ${DST}/${DATE}

# Create MySQL Backups
for db in $(echo 'show databases;' | mysql --silent -u ${DBUSER} ${PASSWD} | egrep -v ${IGNREG}) ; do
   echo -n "Backing up ${db}... "
   mysqldump --opt -u ${DBUSER} $db --routines --triggers > ${DST}/${DATE}/${db}.sql
   echo "Done"
done

exit 0
