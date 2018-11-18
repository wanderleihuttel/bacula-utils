### Script do convert MySQL to PostgreSQL
Based on Bacula Manual
https://www.bacula.org/9.2.x-manuals/en/main/Installing_Configuring_Post.html#SECTION004450000000000000000

This script is used to convert a Bacula Database from MySQL to PostgreSQL.
It was tested using MySQL 5.6 and 5.7 to a PostgreSQL 9.4 and 9.6 and Bacula 9.0.5

#### 1st step - Configure the parameters in script 'mysql_to_postresql.sh'
````
db_user="root"
db_password=""
db_name="bacula"
dir_backup="/tmp/bacula"  # This directory must exists
````

#### 2nd step - Run the script 'mysql_to_postresql.sh' to generate the database dump
The script will generate the dump of the tables individually and a file called 'RowCountMySQL.log' with the total of records by table.
This file will be used later to compare the number of records imported in PostgreSQL


#### 3rd step - Configure the parameters in script 'import_postgresql.sh'
````
db_user="bacula"
db_name="bacula"
dir_backup="/tmp/bacula"  # This directory must exists
````

#### 4th step - Create a file '/root/.pgpass' with PostgreSQL credentials and apply permission only for root 600.
````
# File Example (use your credentials)
# hostname:port:database:username:password
localhost:5432:bacula:bacula:bacula
````

#### 5th step - Run the script 'import_postgresql.sh' to import MySQL dump to PostgreSQL.
If everything works fine, you can compare the files 'RowCountMySQL.log' and 'RowCountPg.log'.
If the number of records of every table in MySQL and PostgreSQL are the same you can be proud, 
the migration was finished with success!





### Troubleshooting
I had some problems in the 'Log' table, most of which was because of the wrong encoding, coming from Windows backup errors. 
I manually edited the table, correcting the errors and tried to import only this table again.


