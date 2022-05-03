#!/bin/bash
# Backup PfSense
#
# Version 1.1 - 03/05/2020
#
# Working in 2.6.0-RELEASE (amd64)

USERNAME=admin
PASSWORD=pfsense
PROTOCOL=http        # http or https
ADDRESS=192.168.1.254
PORT=80
URL=${PROTOCOL}://${ADDRESS}:${PORT}
DESTINATION=/tmp/pfsense
FILENAME=config-${ADDRESS}-$(date +%Y%m%d%H%M%S).xml

if [[ ! -d $DESTINATION ]]; then
    mkdir -p $DESTINATION
fi


curl -s -L -k --cookie-jar cookies.txt ${URL}/ | \
     grep "name='__csrf_magic'" | \
     sed 's/.*value="\(.*\)".*/\1/' > csrf.txt
s1=$?

curl -s -L -k --cookie cookies.txt --cookie-jar cookies.txt \
     --data-urlencode "login=Login" \
     --data-urlencode "usernamefld=$USERNAME" \
     --data-urlencode "passwordfld=$PASSWORD" \
     --data-urlencode "__csrf_magic=$(cat csrf.txt)" \
     ${URL}/ > /dev/null
s2=$?

curl -s -L -k --cookie cookies.txt --cookie-jar cookies.txt ${URL}/diag_backup.php  \
     | grep "name='__csrf_magic'"   \
     | sed 's/.*value="\(.*\)".*/\1/' > csrf.txt
s3=$?

curl -s -L -k --cookie cookies.txt --cookie-jar cookies.txt \
     --data-urlencode "download=download" \
     --data-urlencode "donotbackuprrd=yes" \
     --data-urlencode "__csrf_magic=$(head -n 1 csrf.txt)" \
     ${URL}/diag_backup.php > ${DESTINATION}/${FILENAME}
s4=$?

(( status=s1+s2+s3+s4 ))

if [[ $status == 0 ]]; then
    echo "PfSense Backup OK $FILENAME"
    exit 0
else
    echo "PfSense Backup Error $FILENAME"
    exit 1
fi
