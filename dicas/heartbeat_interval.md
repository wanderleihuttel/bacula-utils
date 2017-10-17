#### Heartbeat Interval = intervalo de tempo

Para ativar essa opção, deve-se incluir a opção acima nos seguintes recursos:

### Arquivo bacula-dir.conf (servidor)

````
Director{
   ...
   Heartbeat Interval = 300 seconds
   ...
}

Storage{
   ...
   Heartbeat Interval = 300 seconds
   ...
}

Client{
   ...
   Heartbeat Interval = 300 seconds
   ...
}
````
### Arquivo bacula-sd.conf (servidor)
````
Storage{
   ...
   Heartbeat Interval = 300 seconds
   ...
}
````

### Arquivo bacula-fd.conf (cliente)
````
FileDaemon{
   ...
   Heartbeat Interval = 300 seconds
   ...
}
````
