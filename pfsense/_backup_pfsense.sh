#!/bin/bash
#
# Example: ./backup-pfsense.sh 192.168.1.1 
#


if [ -z $1 ]
then
  echo "Use: $0 [IP or ADDRESS]"
  exit 1
fi

USERNAME=admin
PASSWORD=pfsense
PROTOCOL=http        # http or https
ADDRESS=$1
PORT=443
URL=${PROTOCOL}://${ADDRESS}:${PORT}
DESTINATION=/tmp/pfsense
FILENAME=config-${ADDRESS}-`date +%Y%m%d%H%M%S`.xml

if [ ! -d $DESTINATION ]
then
  mkdir -p $DESTINATION
fi


curl -L -k --cookie-jar cookies.txt \
     ${URL}/ \
     | grep "name='__csrf_magic'" \
     | sed 's/.*value="\(.*\)".*/\1/' > csrf.txt


curl -L -k --cookie cookies.txt --cookie-jar cookies.txt \
     --data-urlencode "login=Login" \
     --data-urlencode "usernamefld=admin" \
     --data-urlencode "passwordfld=be#Gu8bu" \
     --data-urlencode "__csrf_magic=$(cat csrf.txt)" \
     ${URL}/ > /dev/null

curl -L -k --cookie cookies.txt --cookie-jar cookies.txt \
     ${URL}/diag_backup.php  \
     | grep "name='__csrf_magic'"   \
     | sed 's/.*value="\(.*\)".*/\1/' > csrf.txt

curl -L -k --cookie cookies.txt --cookie-jar cookies.txt \
     --data-urlencode "download=download" \
     --data-urlencode "donotbackuprrd=yes" \
     --data-urlencode "__csrf_magic=$(head -n 1 csrf.txt)" \
     ${URL}/diag_backup.php > ${DESTINATION}/${FILENAME}
     
