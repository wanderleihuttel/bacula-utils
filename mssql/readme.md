## Backup de Banco de Dados MSSQL Server 2008 / 2012 usando o Bacula

### Copiar os arquivos para o diretório scripts
```
Geralmente é C:\Program Files\Bacula\scripts
```
### Configurar o Fileset
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
### Configurar o Job
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

### Configurar as variáveis do script e executar o backup
