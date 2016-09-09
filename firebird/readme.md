## Backup de Banco de Dados Firebird

### Copiar os arquivos para o diretório scripts
```
Geralmente é C:\Program Files\Bacula\scripts
```
### Configurar o Fileset
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
### Configurar o Job
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

### Configurar as variáveis do script e executar o backup
