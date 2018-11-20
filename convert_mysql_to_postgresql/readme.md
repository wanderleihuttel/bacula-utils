### Script do convert MySQL to PostgreSQL
Based on Bacula Manual
https://www.bacula.org/9.2.x-manuals/en/main/Installing_Configuring_Post.html#SECTION004450000000000000000

This script is used to convert a Bacula Database from MySQL to PostgreSQL.
It was tested using MySQL 5.6 and 5.7 to a PostgreSQL 9.4 and 9.6 and Bacula 9.0.8 and Bacula 9.2.2

This migration script was simulated in a environment using a compiled Bacula with MySQL running for years. The configuration files was the same.

The Bacula Daemons was stopped and Bacula was compiled again and was configured like a fresh Bacula environment but now with PostgreSQL. 

So, after the Bacula with PostgreSQL was running OK, I've stopped Bacula Daemons again and run the scripts below to cleanup the PostgreSQL database, for make sure that was a fresh install. 
(Even if you only start Bacula Director, Bacula save data into database from config files)
- drop_postgresql_database
- create_postgresql_database
- make_postgresql_tables
- grant_postgresql_privileges


#### 1st step - Download the scripts (mysql_to_postresql.sh and import_postgresql.sh) and save in a directory
````
mkdir /usr/src/bacula_migration
cd /usr/src/bacula_migration
wget -c https://raw.githubusercontent.com/wanderleihuttel/bacula-utils/master/convert_mysql_to_postgresql/mysql_to_postresql.sh
wget -c https://raw.githubusercontent.com/wanderleihuttel/bacula-utils/master/convert_mysql_to_postgresql/import_postgresql.sh
````

#### 2nd step - Run the script 'mysql_to_postresql.sh' to generate the database dump
The script will ask for your MySQL credentials and if they OK he script will generate the dump of the tables individually
and a file called 'RowCountMySQL.log' with the total of records by table.
This file will be used later to compare the number of records imported in PostgreSQL


#### 3rd step - Configure the parameters in script 'import_postgresql.sh' or keep the default ones
````
db_user="bacula"
db_name="bacula"
````

#### 4th step - Create a file '/root/.pgpass' with PostgreSQL credentials and apply permission only for root 600.
````
touch /root/.pgpass
chmod 600 /root/.pgpass
# File Example (use your credentials)
# hostname:port:database:username:password
localhost:5432:bacula:bacula:bacula
````

#### 5th step - Run the script 'import_postgresql.sh' to import MySQL dump to PostgreSQL.
If everything works fine, you can compare the files 'RowCountMySQL.log' and 'RowCountPg.log'.
If the number of records of every table in MySQL and PostgreSQL are the same you can be proud,
the migration was finished with success!


#### 6th step - Take a look in the files with '.log' extension to check if no errors ocurred
If the content of this log files is similar of "psql:File.sql:2:WARNING: there is no transaction in progress".
The migration was completed with success, if not, is necessary to discovery why the errors ocurred


### Troubleshooting
I had some problems in the 'Log' table, most of which was because of the wrong encoding, coming from Windows backup errors.
I manually edited the table (in MySQL side), correcting the errors, generate the dump again and tried to import only this table.
