#### Maximum Concurrent Jobs = Número de Jobs Simultâneos
Para ativar essa opção, deve-se incluir a opção acima nos seguintes recursos:

### Arquivo bacula-dir.conf (servidor)

````
Director{
   ...
   Maximum Concurrent Jobs = 10
   ...
}

Storage{
   ...
   Maximum Concurrent Jobs = 10
   ...
}

Client{
   ...
   Maximum Concurrent Jobs = 10
   ...
}
````
### Arquivo bacula-sd.conf (servidor)
````
Storage{
   ...
   Maximum Concurrent Jobs = 10
   ...
}

Device{
   ...
   Maximum Concurrent Jobs = 10
   ...
}

````

### Arquivo bacula-fd.conf (cliente)
````
FileDaemon{
   ...
   Maximum Concurrent Jobs = 10
   ...
}
````


Fonte: http://www.bacula.org/9.0.x-manuals/en/problems/Tips_Suggestions.html#SECTION003170000000000000000
