#!/bin/bash

echo "Usage _password_generator.sh [number of passwords to generate] [password size]"
echo "Default [number of passwords to generate] = 1"
echo "Default [passwords size] = 44"

# No parameters
if [ $# -eq 0 ]; then
   size=44
   number=1
elif [ $# -eq 1 ]; then
   number=$1
   size=44
elif [ $# -eq 2 ]; then
   number=$1
   size=$2
fi


#for i in $(eval echo {$A..$B})       do          volume=`printf "$PREFIX%04d" $i`


echo -e "size: $size"
for i in $(eval echo {1..$number}); 
  do 
    password=`tr -dc A-Za-z0-9_/ < /dev/urandom | head -c $size`
    #printf "password %02d: $password\n" $i
    printf "$password\n"
done
