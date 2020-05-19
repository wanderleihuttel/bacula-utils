#!/bin/bash
# Script to install Bacula with packages
#
# Author:  Wanderlei Huttel
# Email:   wanderlei@bacula.com.br
version="1.0.7 - 19 May 2020"


#===============================================================================
# Read bacula key
function read_bacula_key()
{
    clear
    echo " --------------------------------------------------"
    echo " Inform your Bacula Key"
    echo " This key is obtained with a registration in Bacula.org."
    echo " https://www.bacula.org/bacula-binary-package-download/"
    read -p " Please, fill with your Bacula Key: " bacula_key
}


#===============================================================================
# Download Bacula Key
function download_bacula_key()
{
    wget -c https://www.bacula.org/downloads/Bacula-4096-Distribution-Verification-key.asc -O /tmp/Bacula-4096-Distribution-Verification-key.asc
    if [ "$OS" == "debian" -o "$OS" == "ubuntu" ]; then
        apt-key add /tmp/Bacula-4096-Distribution-Verification-key.asc
    elif [ "$OS" == "centos" ]; then
        rpm --import /tmp/Bacula-4096-Distribution-Verification-key.asc
    else
        echo "Is not possible to install the Bacula Key"
    fi
    rm -f /tmp/Bacula-4096-Distribution-Verification-key.asc
}



#===============================================================================
# Download Bacula Key
function create_bacula_repository()
{
    while :
    do
    clear
    echo " --------------------------------------------------"
    echo " Inform the Bacula version"
    url="https://www.bacula.org/packages/${bacula_key}/debs/"
    IFS=$'\n'
    versions=$(curl --silent --fail -r 0-0 "${url}" | grep -o '<a.*>.*/</a>' | sed 's/\(<a.*">\|\/<\/a>\)//g')
    for i in ${versions}; do
        echo "   - $i";
    done
    read -p " Type your the Bacula Version: " bacula_version
    
    if [ "$OS" == "debian" -o "$OS" == "ubuntu" ]; then
        url="http://www.bacula.org/packages/${bacula_key}/debs/${bacula_version}/${codename}/amd64"
        echo "# Bacula Community
deb ${url} ${codename} main" > /etc/apt/sources.list.d/bacula-community.list
    
    elif [ "$OS" == "centos" ]; then
        url="https://www.bacula.org/packages/${bacula_key}/rpms/${bacula_version}/el${codename}/x86_64/"
        echo "[Bacula-Community]
name=CentOS - Bacula - Community
baseurl=${url}
enabled=1
protect=0
gpgcheck=0" > /etc/yum.repos.d/bacula-community.repo
    else
        echo "Is not possible to install the Bacula Key"
    fi

    if wget --spider ${url} 2>/dev/null; then
        break
    else
        echo " Unfortunately this version (${bacula_version}) still not available for this OS."
        echo " Please, choose another one!"
        read -p " Press [enter] key to continue..." readenterkey
    fi

    done
}



#===============================================================================
# Install MySQL
function install_with_mysql()
{
    wget -c https://repo.mysql.com/RPM-GPG-KEY-mysql -O /tmp/RPM-GPG-KEY-mysql --no-check-certificate
    if [ "$OS" == "debian" -o "$OS" == "ubuntu" ]; then
        apt-key add /tmp/RPM-GPG-KEY-mysql
        echo "deb http://repo.mysql.com/apt/debian/ ${codename} mysql-apt-config
deb http://repo.mysql.com/apt/debian/ ${codename} mysql-5.7
deb http://repo.mysql.com/apt/debian/ ${codename} mysql-tools
deb http://repo.mysql.com/apt/debian/ ${codename} mysql-tools-preview
deb-src http://repo.mysql.com/apt/debian/ ${codename} mysql-5.7" > /etc/apt/sources.list.d/mysql.list
        apt-get update
        apt-get install -y mysql-community-server
        apt-get install -y bacula-mysql
        systemctl enable mysql
        systemctl start mysql
        
    elif [ "$OS" == "centos" ]; then
        rpm --import /tmp/RPM-GPG-KEY-mysql
        wget -c http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm -O /tmp/mysql57-community-release-el7-9.noarch.rpm
        rpm -ivh /tmp/mysql57-community-release-el7-9.noarch.rpm
        yum install -y mysql-community-server
        mysqld --initialize-insecure --user=mysql
        systemctl enable mysqld
        systemctl start mysqld
        yum install -y bacula-mysql
    fi

    /opt/bacula/scripts/create_mysql_database
    /opt/bacula/scripts/make_mysql_tables
    /opt/bacula/scripts/grant_mysql_privileges

    systemctl enable bacula-fd.service
    systemctl enable bacula-sd.service
    systemctl enable bacula-dir.service

    systemctl start bacula-fd.service
    systemctl start bacula-sd.service
    systemctl start bacula-dir.service

    for i in $(ls /opt/bacula/bin); do 
        ln -s /opt/bacula/bin/$i /usr/sbin/$i; 
    done
    sed '/[Aa]ddress/s/=\s.*/= localhost/g' -i  /opt/bacula/etc/bconsole.conf
    echo
    echo "Bacula with MySQL installed with success!"
    echo
}

# Install PostgreSQL
function install_with_postgresql()
{
    if [ "$OS" == "debian" -o "$OS" == "ubuntu" ]; then
        apt-get update
        apt-get install -y postgresql postgresql-client
        apt-get install -y bacula-postgresql

    elif [ "$OS" == "centos" ]; then
        yum install -y postgresql-server
        yum install -y bacula-postgresql --exclude=bacula-mysql
        postgresql-setup initdb
    fi

    systemctl enable postgresql
    systemctl start postgresql
    su - postgres -c "/opt/bacula/scripts/create_postgresql_database"
    su - postgres -c "/opt/bacula/scripts/make_postgresql_tables"
    su - postgres -c "/opt/bacula/scripts/grant_postgresql_privileges"

    systemctl enable bacula-fd.service
    systemctl enable bacula-sd.service
    systemctl enable bacula-dir.service

    systemctl start bacula-fd.service
    systemctl start bacula-sd.service
    systemctl start bacula-dir.service

    for i in $(ls /opt/bacula/bin); do
        ln -s /opt/bacula/bin/$i /usr/sbin/$i;
    done
    sed '/[Aa]ddress/s/=\s.*/= localhost/g' -i  /opt/bacula/etc/bconsole.conf
    echo
    echo "Bacula with PostgreSQL installed with success!"
    echo
}

#===============================================================================
# Menu
function menu()
{
    while :
        do
        clear
        echo " =================================================="
        echo " Bacula Community Package Install"
        echo " Author: Wanderlei Huttel"
        echo " Email:  wanderlei@bacula.com.br"
        echo " OS Supported: Debian | Ubuntu | CentOS"
        echo " Version: ${version}"
        echo " =================================================="
        echo
        echo " What do you want to do?"
        echo "   1) Install Bacula with PostgreSQL"
        echo "   2) Install Bacula with MySQL"
        echo "   3) Exit"
        read -p " Select an option [1-3]: " option
        echo
        case $option in
            1) # Install Bacula with PostgreSQL
               install_with_postgresql
               read -p "Press [enter] key to continue..." readenterkey
               ;;
            2) # Install Bacula with MySQL
               install_with_mysql
               read -p "Press [enter] key to continue..." readenterkey
               ;;
            3) echo
               exit
               ;;
        esac
    done
}


#===============================================================================
# Detect Debian users running the script with "sh" instead of bash
OS=""
codename=""
bacula_key=""
export DEBIAN_FRONTEND=noninteractive
clear
if readlink /proc/$$/exe | grep -q "dash"; then
    echo "This script needs to be run with bash, not sh"
    exit
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "Sorry, you need to run this as root"
    exit
fi

if [[ -e /etc/debian_version ]]; then
    OS=$(cat /etc/os-release  | egrep "^ID=" | sed 's/.*=//g')
    codename=$(cat /etc/os-release | grep "VERSION_CODENAME" | sed 's/.*=//g')
elif [[ -e /etc/centos-release || -e /etc/redhat-release ]]; then
    setenforce 0
    sudo sed -i "s/enforcing/disabled/g" /etc/selinux/config
    sudo sed -i "s/enforcing/disabled/g" /etc/sysconfig/selinux
    firewall-cmd --permanent --zone=public --add-port=9101-9103/tcp
    systemctl restart firewalld
    OS=centos
    codename=$(cat /etc/os-release | grep "VERSION_ID" | sed 's/[^0-9]//g')
else
    echo "Looks like you aren't running this installer on Debian, Ubuntu or CentOS"
    exit
fi

if [ "$OS" == "debian" -o "$OS" == "ubuntu" ]; then
    apt-get install -y zip wget apt-transport-https bzip2 curl
elif [ "$OS" == "centos" ]; then
    yum install -y zip wget apt-transport-https bzip2 curl
fi

download_bacula_key
read_bacula_key
create_bacula_repository
menu
