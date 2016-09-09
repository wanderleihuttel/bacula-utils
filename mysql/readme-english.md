## Backup MySQL Databases

### Copy file to bacula client scripts folder
```
Usually is /etc/bacula/scripts
```

### Configure the variables
```
# Directory to store backups
DST=/path/to/mysql/backup/folder

# The MySQL username and password
DBUSER="root"
DBPASS=""

# A regex, passed to egrep -v, for which databases to ignore
IGNREG='^information_schema$|^performance_schema$|^bacula$|^mysql$'
```

### Configure Fileset
```
FileSet {
  Name = "FileSet_Firebird"
  Include {
    Options {
      signature = md5
       compression = gzip
       onefs = no
       ignorecase = yes
    }
    File = "/path/to/mysql/backup/folder"
  }
}
```
### Configure Job
```
Job {
  Name = "Backup_MySQL"
  JobDefs = "DefaultJob"
  Client = srv_mysql-fd
  FileSet= "FileSet_MySQL"
  Level = Full
  ClientRunBeforeJob  = "/etc/bacula/scripts/_backup_mysql.sh"
}
```

### Run a backup
