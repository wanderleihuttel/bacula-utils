## Backup de Banco de Dados MySQL

### Copiar o arquivo para o diretório scripts
```
Geralmente é /etc/bacula/scripts
```

### Configurar as variáveis
```
# Diretório onde armazenar os backups
DST=/path/to/mysql/backup/folder

# Usuário e senha MySQL
DBUSER="root"
DBPASS=""

# Regex, passado para o egrep -v, para ignorar os bancos de dados
IGNREG='^information_schema$|^performance_schema$|^bacula$|^mysql$'
```

### Configurar o Fileset
```
FileSet {
  Name = "FileSet_MySQL"
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
### Configurar o Job
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

### Executar o backup
