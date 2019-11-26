## Backup do Firewall PFSENSE

### Copiar o arquivo para o diretório scripts
```
Geralmente é /etc/bacula/scripts
```

### Configurar as variáveis
```

USERNAME=admin
PASSWORD=pfsense
PROTOCOL=http        # http or https
ADDRESS=$1
PORT=443
URL=${PROTOCOL}://${ADDRESS}:${PORT}
DESTINATION=/tmp/pfsense
FILENAME=config-${ADDRESS}-`date +%Y%m%d%H%M%S`.xml


### Configurar o Fileset
```
FileSet {
  Name = "pfsense-fs"
  Include {
    Options {
      signature = md5
       compression = gzip
       onefs = no
       ignorecase = yes
    }
    File = "/tmp/pfsense"
  }
}
```
### Configurar o Job
```
Job {
  Name = "Backup_pfsense_192.168.1.1"
  JobDefs = "DefaultJob"
  Client = bacula-fd
  FileSet= "pfsense-fs"
  Level = Full
  ClientRunBeforeJob  = "/etc/bacula/scripts/_backup_pfsense.sh 192.168.1.1"
}
```

### Executar o backup


