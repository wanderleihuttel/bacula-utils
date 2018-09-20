#!/bin/bash
#################################################
# Automatic Baculum Install on Centos 7         #
# Author:  Wanderlei Hüttel                     #
# Email:   wanderlei.huttel@gmail.com           #
# Version: 1.3 - 15/08/2018                     #
#################################################

# Based on script https://github.com/carlosedulucas/baculum/blob/master/instalação do baculum.txt

echo ">>> Baculum install Centos ..."

echo ">>> Disabling any Baculum site ..."
a2dissite baculum*

echo ">>> Download the last version of Baculum ..."
wget -P /usr/src https://sourceforge.net/projects/bacula/files/bacula/9.2.1/bacula-gui-9.2.1.tar.gz
tar -xzvf /usr/src/bacula-gui-9.2.1.tar.gz  -C /usr/src/

echo ">>> Copying Baculum files to /var/www/baculum ..."
cp -R /usr/src/bacula-gui-9.2.1/baculum/ /var/www

echo ">>> Create Baculum users (default user: admin | default password: admin ..."
htpasswd -cb /var/www/baculum/protected/Web/baculum.users admin admin
\cp -f /var/www/baculum/protected/Web/baculum.users /var/www/baculum/protected/Web/Config
\cp -f /var/www/baculum/protected/Web/baculum.users /var/www/baculum/protected/API/Config

echo ">>> Grant permission to folder /var/www/baculum ..."
chown -R apache2.apache2 /var/www/baculum

echo ">>> Enabling site in apache ..."
\cp -f /var/www/baculum/examples/deb/baculum-web-apache.conf /etc/apache2/sites-available/baculum-web.conf
sed -i 's/\/usr\/share\/baculum\/htdocs/\/var\/www\/baculum/g' /etc/apache2/sites-available/baculum-web.conf
\cp -f /var/www/baculum/examples/deb/baculum-api-apache.conf /etc/apache2/sites-available/baculum-api.conf
sed -i 's/\/usr\/share\/baculum\/htdocs/\/var\/www\/baculum/g' /etc/apache2/sites-available/baculum-api.conf
a2ensite baculum-web.conf
a2ensite baculum-api.conf

echo ">>> Grant permissions in sudoers ..."
echo -e "apache2 ALL=NOPASSWD: /usr/sbin/bconsole\n\
apache2 ALL=NOPASSWD: /etc/bacula/\n\
apache2 ALL=NOPASSWD: /usr/sbin/bdirjson\n\
apache2 ALL=NOPASSWD: /usr/sbin/bbconsjson\n\
apache2 ALL=NOPASSWD: /usr/sbin/bfdjson\n\
apache2 ALL=NOPASSWD: /usr/sbin/bsdjson" > /etc/sudoers.d/baculum

echo ">>> Enable apache rewrite mode ..."
a2enmod rewrite

echo ">>> Restarting apache ..."
systemctl restart httpd

echo ">>> Done"
