### Resolver problemas de Datas no MySQL/MariaDB

Se ocorrer algum erro relativo à datas durante a atualização do catálogo ou após alguma atualização do MySQL/MariaDB, pode ser que a configuração do "SQL_MODE" não está permitindo datas com valores zerados.

````
Exemplo de Erros:
ERROR 1067 (42000) at line 5: Invalid default value for 'FirstWritten'
ERROR 1067 (42000) at line 6: Invalid default value for 'FirstWritten'
ERROR 1067 (42000) at line 7: Invalid default value for 'FirstWritten'
ERROR 1067 (42000) at line 8: Invalid default value for 'FirstWritten'
ERROR 1067 (42000) at line 9: Invalid default value for 'FirstWritten'
ERROR 1067 (42000) at line 29: Invalid default value for 'SchedTime'
````

Para resolver isso é preciso alterar o SQL_MODE. Para isso deve-se acessar o console do MySQL/MariaDB e verificar como está configurado o "sql_mode".

#### Acesse o console do MySQL
````
mysql -u root -pSUASENHA ou mysql -u root
````

#### Verificar o sql_mode
````
SELECT @@GLOBAL.sql_mode;

O resultado pode variar, mas vai ser algo parecido com isso:
ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
````

#### Alterar o arquivo mysql.cnf ou my.cnf
````
Procure o seu arquivo mysql.cnf ou my.cnf em /etc/mysql e abaixo da opção "[mysqld]", 
inclua a configuração "sql_mode" e cole a linha gerada anteriormente, 
removendo as opções de "NO_ZERO_IN_DATE" e "NO_ZERO_DATE"
sql_mode = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
````

#### Reiniciar o MySQL/MariaDB
````
/etc/init.d/mysql restart ou systemctl restart mysql.service
````


#### Verificar o sql_mode novamente
````
SELECT @@GLOBAL.sql_mode; 
ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION

Se não aparecer as opções NO_ZERO_IN_DATE e NO_ZERO_DATE é porque asconfigurações estão OK.
````
