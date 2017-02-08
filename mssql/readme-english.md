## Backup Database Microsoft SQL Server 2008 / 2012 using Bacula

### Copy files to bacula client scripts folder
```
Usually is C:\Program Files\Bacula\scripts
```
### Configure Fileset
```
FileSet {
  Name = "FileSet_MSSQL"
  Include {
    Options {
      signature = md5
       compression = gzip
       onefs = no
       ignorecase = yes
    }
    File = "C:/backup_mssql"
  }
}
```
### Configure Job
```
Job {
  Name = "Backup_MSSQL"
  JobDefs = "DefaultJob"
  Client = srv_windows-fd
  FileSet= "FileSet_MSSQL"
  Level = Full
  ClientRunBeforeJob  = "powershell C:/'Program Files'/Bacula/scripts/make_mssql_backup.ps1"
}
```

### Configure the variables in the script and run a backup
