Passos para instalação do Bacula via compilação no Debian/Ubuntu
========================================

** MySQL e PostgreSQL**
**Autor:** Wanderley Hüttel
**Data da Atualização:**17/03/2016

> **Atenção!**
> Leia tudo antes de começar a instalar, só depois inicie a instalação.
> Se você obtiver algum erro durante a instalação, revise todo o material e verifique se não esqueceu de nenhum passo.
> Este tutorial foi testado no Debian e Ubuntu.


#### Vamos ao Tutorial

**Atualize a lista de pacotes:**
```
apt update
```

**Pacotes necessários para a compilação padrão + alguns utilitários:**
```
apt install vim make gcc build-essential libpq5 perl unp mc mtx libreadline6 \
libreadline6-dbg libreadline-gplv2-dev lzop liblzo2-dev python-lzo sudo gawk gdb \
libacl1 libacl1-dev git sysv-rc-conf ntfs-3g cifs-utils postfix mailutils lsscsi \
apache2 libapache2-mod-php
```
Quando solicitar a configuração do postfix, deixe como ```Site da Internet``` e o nome do e-mail do sistema como ```localhost```.

**Pacotes necessários para habilitar o BAT:**
```
apt install qt4-dev-tools qt4-qtconfig  libqt4-core libqt4-dev libqwt5-qt4 \
libqwt5-qt4-dev pkg-config
```
**Pacotes necessários para utilizar o banco de dados [MySQL:](https://www.mysql.com/ "Site oficial do MySQL")**
Cuidado com senhas como caracteres especiais, pois pode aprensentar problemas na criação dos scripts. Se for uma instalação fresca, prefira deixa a senha em branco.
```
apt install mysql-server libmysqlclient-dev php5-mysqlnd
```

**Pacotes necessários para instalação do banco de dados [MariaDB](https://mariadb.com/ "Site oficial do MariaDB"):**
Lembrando que o MariaDB não é homologado pelo Bacula, porém, funciona.
```
apt install mariadb-server libmariadbd-dev libmariadb-client-lgpl-dev \
libmariadb-client-lgpl-dev-compat
```
```
apt install libmysqlclient-dev php-mysqlnd
```
Caso opte por usar o banco MariaDB, é recomendado criar um link simbólico para facilitar a compilação:
```
ln -s /usr/include/mariadb /usr/include/mysql
```
**Pacotes para utilizar o banco de dados [PostgreSQL](https://www.postgresql.org/ "Site oficial do PostgreSQL"):**
```
apt install postgresql-9.4 postgresql-contrib-9.4 postgresql-client-9.4 \
postgresql-server-dev-9.4 php5-pgsql
```
**Pacotes do PHP (Necessários para o [Webacula](https://github.com/wanderleihuttel/webacula "Repositório no GitHub do Webacula") e [Bacula Web](http://www.bacula-web.org/ "Site do Bacula Web")):**
```
apt install php5 php5-gd php5-dev php5-mcrypt php5-curl
```
**Baixando e Compilando o Código Fonte do Bacula:**
Acesse o diretório ```/usr/src```
```
cd /usr/src
```
Utilizando o wget para baixar o arquivo contendo o código fonte:
```
wget --no-check-certificate https://sourceforge.net/projects/bacula/files/bacula/7.4.7/bacula-7.4.7.tar.gz
```
Descompactando o arquivo ```bacula-7.4.7.tar.gz```:
```
tar xvzf bacula-7.4.7.tar.gz
```
Acesse o diretório criado:
```
cd bacula-7.4.7
```
Utilizando o git para baixar o código fonte (sempre pega a versão mais recente, porém, as vezes pode conter alguns bugs):
```
git clone -b Branch-7.4 http://git.bacula.org/bacula.git bacula
```
Acesse o diretório criado:
```
cd bacula
```

> Agora é preciso definir o banco de dados que será utilizado, MySQL ou PostgreSQL.
> Utilize os comandos de acordo com o banco escolhido.

**Comando de pré-compilação para MySQL/MariaDB:**
```
./configure \
 --enable-smartalloc \
 --with-mysql \
 --with-db-user=bacula \
 --with-db-password=bacula \
 --with-db-port=3306 \
 --with-readline=/usr/include/readline \
 --sysconfdir=/etc/bacula \
 --bindir=/usr/bin \
 --sbindir=/usr/sbin \
 --with-scriptdir=/etc/bacula/scripts \
 --with-plugindir=/etc/bacula/plugins \
 --with-pid-dir=/var/run \
 --with-subsys-dir=/etc/bacula/working \
 --with-working-dir=/etc/bacula/working \
 --with-bsrdir=/etc/bacula/bootstrap \
 --with-systemd \
 --disable-conio \
 --disable-nls \
 --with-logdir=/var/log/bacula \
 --with-dump-email=email@dominio.com.br \
 --with-job-email=email@dominio.com.br
```
**Comando de pré-compilação para PostgreSQL:**
```
./configure \
 --enable-smartalloc \
 --with-postgresql \
 --with-db-user=bacula \
 --with-db-password=bacula \
 --with-db-port=5432 \
 --with-readline=/usr/include/readline \
 --sysconfdir=/etc/bacula \
 --bindir=/usr/bin \
 --sbindir=/usr/sbin \
 --with-scriptdir=/etc/bacula/scripts \
 --with-plugindir=/etc/bacula/plugins \
 --with-pid-dir=/var/run \
 --with-subsys-dir=/etc/bacula/working \
 --with-working-dir=/etc/bacula/working \
 --with-bsrdir=/etc/bacula/bootstrap \
 --with-systemd \
 --disable-conio \
 --disable-nls \
 --with-logdir=/var/log/bacula \
 --with-dump-email=email@dominio.com.br \
 --with-job-email=email@dominio.com.br
```
**Comando para efetuar a compilação e instalação:**
```
make -j 8
```
```
make install
```
```
make install-autostart
```

> **Passos para criação do banco de dados, usuários e permissões MySQL:**

**Configurar o MySQL para ter acesso a rede pelo Workbench (opcional):**
Editar o arquivo ```/etc/mysql/my.cnf``` e alterar a linha ```bind-address```:
De: ```bind-address = 127.0.0.1```
Para: ```bind-address = 0.0.0.0```

Reinicie o MySQL:
```
/etc/init.d/mysql restart
```

**Configurar os usuários no MySQL:**
Caso você não tenha definido uma senha:
```
mysql -u root
```
Caso tenha definido uma senha:
```
mysql -u root -p
```
```
grant all on *.* 'root'@'localhost' identified by 'bacula' with grant options;
```
```
GRANT SELECT ON mysql.proc to 'bacula';
```
```
flush privileges;
```
```
quit
```
Reinicie o MySQL:
```
/etc/init.d/mysql restart
```
**Criar as tabelas do Bacula do MySQL:**
```
cd /etc/bacula/scripts
```
Caso não tenha definido uma senha:
```
./create_mysql_database -u root
```
```
./make_mysql_tables
```
```
./grant_mysql_privileges
```

Caso tenha definido uma senha:
```
./create_mysql_database -u root -p
```
```
./make_mysql_tables -u root -p
```
```
./grant_mysql_privileges -u root -p
```
> **Passos para criação do banco de dados, usuários e permissões no PostgreSQL:**

**Criar as tabelas do Bacula no PostegreSQL:**
```
chmod 775 /etc/bacula
```
```
cd /etc/bacula/scripts
```
```
chown postgres create_postgresql_database
```
```
chown postgres make_postgresql_tables
```
```
chown postgres grant_postgresql_privileges
```
```
su postgres
```
```
./create_postgresql_database
```
```
./make_postgresql_tables
```
```
./grant_postgresql_privileges
```
```
exit
```
**Configirar o acesso ao PostgreSQL pelo Bacula:**
Editar o arquivo ```/etc/postgresql/9.4/main/pg_hba.conf``` e incluir a seguinte linha:
```
host    bacula      bacula      127.0.0.1/32          md5
```
Editar o arquivo ```/etc/postgresql/9.4/main/postgresql.conf``` e alterar a linha conforme mostrado abaixo:
```
listen_addresses = '*'
```
**Definindo a senha do usuário bacula no PostgreSQL:**
```
su postgres
```
```
psql
```
```
alter user bacula with password 'bacula';
```
```
alter role
```
```
\q
```
```
exit
```
**Iniciar o Bacula:**
```
bacula start
```

Se tudo ocorrer bem, o Bacula iniciará sem problemas e você já pode acessa-lo através do ```bconsole```e verá uma tela confoem abaixo:

```
root@bacula:/# bconsole
Connecting to Director 192.168.1.1:9101
1000 OK: 102 bacula-dir Version: 7.4.6 (10 March 2017)
Enter a period to cancel a command
* 
```



