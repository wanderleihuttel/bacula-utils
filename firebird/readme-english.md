## Backup Database Firebird using Bacula

### Copy files to bacula client scripts folder
```
Usually is C:\Program Files\Bacula\scripts
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
    File = "C:/firebird/backup/database.fbk"
    File = "C:/firebird/backup/database.log"
  }
}
```
### Configure Job
```
Job {
  Name = "Backup_Firebird"
  JobDefs = "DefaultJob"
  Client = srv_firebird-fd
  FileSet= "FileSet_Firebird"
  Level = Full
  ClientRunBeforeJob  = "powershell C:/'Program Files'/Bacula/scripts/make_firebird_backup.ps1"
  ClientRunAfterJob   = "powershell C:/'Program Files'/Bacula/scripts/delete_firebird_backup.ps1"
}
```

### Configure the variables in the script and run a backup
