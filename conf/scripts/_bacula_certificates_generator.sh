#!/bin/bash
# Script to generate Bacula selfsign certificates
#
# Author:  Wanderlei Huttel
# Email:   wanderlei.huttel@gmail.com
version="1.0.2 - 17 Aug 2018"
#
# Based on article: http://www.bacula.pl/artykul/57/szyfrowanie-transmisji-danych-w-bacula/
# Requisites zip to create packages


#----------------------------------
# Variables configurable
#----------------------------------
ssl_dir="/opt/bacula/etc/ssl"
template_dir="/opt/bacula/etc"
numbits=2048
expires_in="10 years"

COUNTRY="BR"
STATE="Santa Catarina"
LOCALITY="Sao Bento do Sul"
ORGANIZATION="www.bacula.org"
EMAILADDRESS="bacula@bacula.org"



# Do not modificate these variables
openssl=$(which openssl)
fd_windows_dir="C:\\\\Program Files\\\\Bacula"
keys_dir="${ssl_dir}/keys"
certs_dir="${ssl_dir}/certs"
packs_dir="${ssl_dir}/packages"
index_txt="${ssl_dir}/index.txt"
index_attr="${ssl_dir}/index.txt.attr"
certificates_txt="${ssl_dir}/certificates.txt"
serial_file="${ssl_dir}/serial"
end_date=$(date +%Y%m%d%H%M%SZ -d +i"$expires_in")



#===============================================================================
# Init config
function init_config(){

    CN=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    read -p " Please inform the IP adress or FQDN from Bacula Server:: " -e -i $CN CN

    cp -f ${template_dir}/openssl.cnf.template ${ssl_dir}/openssl.cnf
    chmod 755 ${ssl_dir}/openssl.cnf

    sed -i "s|XXX_SSL_DIR_XXX|${ssl_dir}|g" ${ssl_dir}/openssl.cnf
    sed -i "s/XXX_ROOT_CA_XXX/root_cert.pem/g" ${ssl_dir}/openssl.cnf
    sed -i "s/XXX_ROOT_KEY_XXX/root_key.pem/g" ${ssl_dir}/openssl.cnf
    sed -i "s/XXX_COUNTRY_NAME_XXX/${COUTRY}/g" ${ssl_dir}/openssl.cnf
    sed -i "s/XXX_STATE_OR_PROVINCE_NAME_XXX/${STATE}/g" ${ssl_dir}/openssl.cnf
    sed -i "s/XXX_LOCALITY_NAME_XXX/${LOCALITY}/g" ${ssl_dir}/openssl.cnf
    sed -i "s/XXX_ORGANIZATION_NAME_XXX/${ORGANIZATION}/g" ${ssl_dir}/openssl.cnf
    sed -i "s/XXX_COMMON_NAME_XXX/${CN}/g" ${ssl_dir}/openssl.cnf
    sed -i "s/XXX_EMAIL_ADDRESS_XXX/${EMAILADDRESS}/g" ${ssl_dir}/openssl.cnf

    touch ${index_txt}
    touch ${index_attr}
    touch ${certificates_txt}
    echo "01" > ${serial_file}
    echo
    echo " ************************************************************"
    echo " Initial configuration terminated with success!"
    echo " ************************************************************"
    echo
}



#===============================================================================
# Generate CA Master Key and Certificate
function generate_ca()
{
    clear
    echo " ============================================================"
    echo " Generate CA Certificate and Key"
    echo " ============================================================"
    echo
    ${openssl} genrsa -out ${keys_dir}/root_key.pem ${numbits}
    ${openssl} rsa -check -noout -in ${keys_dir}/root_key.pem
    ${openssl} req -new -x509 -batch -config ${ssl_dir}/openssl.cnf -sha256 -key ${keys_dir}/root_key.pem -days 36500 -out ${certs_dir}/root_cert.pem
    #${openssl} x509 -text -noout -in ${certs_dir}/root_cert.pem
    #${openssl} verify ${certs_dir}/root_cert.pem
    echo
    echo " ************************************************************"
    echo " The CA certificate and key was generated with success!"
    echo " Certificate: ${ssl_dir}/root_cert.pem"
    echo " Key:         ${ssl_dir}/root_key.pem"
    echo " ************************************************************"
    echo
}



#===============================================================================
# Generate bacula daemons certificates
function generate_certificate()
{
    clear
    echo " ============================================================"
    echo " Generate Certificate and Key"
    echo " ============================================================"
    echo
    name=$1
    CN=$2

    check_exist=$(cat ${certificates_txt} | grep $name | wc -l)
    if [ $check_exist -gt 0 ]; then
        echo " ************************************************************"
        echo " The certificate name ${name} already exists!"
        echo " Please, choose a different name!"
        echo " ************************************************************"
        return 0
    fi

    daemon=$3
    serial=$(cat $serial_file)
    ${openssl} genrsa -out ${keys_dir}/${name}_key.pem ${numbits}
    ${openssl} rsa -check -noout -in ${keys_dir}/${name}_key.pem
    ${openssl} req -new -config ${ssl_dir}/openssl.cnf -sha256 -batch -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/CN=${CN}/emailAddress=${EMAILADDRESS}" \
               -key ${keys_dir}/${name}_key.pem -out ${certs_dir}/${name}_cert.csr
    ${openssl} ca -keyfile ${keys_dir}/root_key.pem -config ${ssl_dir}/openssl.cnf -batch -policy policy_anything -extensions usr_cert -enddate ${end_date} \
               -out ${certs_dir}/${name}_cert.pem -infiles ${certs_dir}/${name}_cert.csr
    #${openssl} x509 -text -noout -in ${certs_dir}/${name}_cert.pem
    #${openssl} verify ${certs_dir}/${name}_cert.pem
    echo -e "${serial}|${name}" >> ${certificates_txt}
    rm -f ${certs_dir}/${name}_cert.csr
    rm -f ${certs_dir}/${serial}.pem
    echo
    echo " ************************************************************"
    echo " The certificate and key was generated with success!"
    echo " Certificate: ${ssl_dir}/${name}_cert.pem"
    echo " Key:         ${ssl_dir}/${name}_key.pem"
    echo " ************************************************************"
    echo
    read -p " Press [enter] key to continue..." readenterkey
    clear
    case $daemon in
        1) config_director $name
           ;;
        2) config_storage $name
          ;;
        3) config_client $name
          ;;
    esac
}



#===============================================================================
# Revoke bacula certificates
function revoke_certificate()
{
    while :
        clear
        do
        echo " ============================================================"
        echo " Revoke an existing certificate"
        echo " ============================================================"
        echo
        echo " Select the existing certificate you want to revoke:"
        numberofcertificates=$(cat ${index_txt} | grep -c "^V")
        cat ${certificates_txt} | cut -d "|" -f2 | nl -s ') '
        i=$((${numberofcertificates}+1))
        echo "     ${i}) Exit"

        if [ "${numberofcertificates}" == "0" ]; then
           echo
           echo " ************************************************************"
           echo " There isn't any certificates to revoke!"
           echo " ************************************************************"
           echo
           return 0
        elif [ "${numberofcertificates}" == "1" ]; then
            read -p " Select one certificate [1]: " option
        else
            read -p " Select one certificate [1-${i}]: " option
        fi

        if [ "${option}" == "${i}" ] || [ "${option}" == ""]; then
            return 0
        fi

        certificatename=$(cat ${certificates_txt} | cut -d "|" -f2 | sed -n "${option}"p)
        certificateserial=$(cat ${certificates_txt} | grep ${certificatename} | cut -d"|" -f1)

        cert="${certs_dir}/${certificatename}_cert.pem"
        key="${keys_dir}/${certificatename}_key.pem"

        if [ -f "${cert}" ] && [ -f "${key}" ]; then
            sed -i "/${certificatename}/d" ${certificates_txt}
            sed -i -E "/[0-9]+Z[ \t]+${certificateserial}/d" ${index_txt}
            rm -f ${cert}
            rm -f ${key}
            rm -f ${packs_dir}/${certificatename}.zip

            echo
            echo " ************************************************************"
            echo " The certificate \"${certificatename}\" was revoked with success!"
            echo " ************************************************************"
            echo
            break
        fi
    done
}



#===============================================================================
# Generate Bacula Client TLS config
function config_client()
{
    name=$1
    echo " ============================================================"
    echo " Bacula TLS config for FileDaemon and Clients"
    echo " ============================================================"
    config="\n
  -------------------------------------------------------------------------------------\n
  # Include the lines below in file \"bacula-dir.conf\" in the \"Client\" resource\n
  -------------------------------------------------------------------------------------\n
  TlsEnable = true\n
  TlsRequire = true\n
  TlsCaCertificateFile = \"${certs_dir}/root_cert.pem\"\n
  TlsCertificate = \"${certs_dir}/${name}_cert.pem\"\n
  TlsKey = \"${keys_dir}/${name}_key.pem\"\n\n\n


  -------------------------------------------------------------------------------------\n
  # Include the lines below in file \"bacula-fd.conf\" in the \"Director\" resource and\n
  # in the \"FileDaemon\" resource. Repeat the lines in all specified resources\n
  # Linux Clients\n
  -------------------------------------------------------------------------------------\n
  TlsEnable = true\n
  TlsRequire = true\n
  TlsCaCertificateFile = \"${certs_dir}/root_cert.pem\"\n
  TlsCertificate = \"${certs_dir}/${name}_cert.pem\"\n
  TlsKey = \"${keys_dir}/${name}_key.pem\"\n\n\n


  -------------------------------------------------------------------------------------\n
  # Include the lines below in file \"bacula-fd.conf\" in the \"Director\" resource and\n
  # in the \"FileDaemon\" resource. Repeat the lines in all specified resources\n
  # Windows Clients\n
  -------------------------------------------------------------------------------------\n
  TlsEnable = true\n
  TlsRequire = true\n
  TlsCaCertificateFile = \"${fd_windows_dir}\\\\root_cert.pem\"\n
  TlsCertificate = \"${fd_windows_dir}\\\\${name}_cert.pem\"\n
  TlsKey = \"${fd_windows_dir}\\\\${name}_key.pem\""
    echo -e ${config}
    echo
    echo -e ${config} > ${packs_dir}/${name}.txt
    zip -j ${packs_dir}/${name}.zip ${packs_dir}/${name}.txt ${certs_dir}/root_cert.pem ${certs_dir}/${name}_cert.pem ${keys_dir}/${name}_key.pem > /dev/null
    rm -f ${packs_dir}/${name}.txt
    echo
    echo " ************************************************************"
    echo " A package with all certificates and a sample config was"
    echo " generated in ${packs_dir}"
    echo " Filename: ${name}.zip"
    echo " ************************************************************"
    echo
}



#===============================================================================
# Generate Bacula Storage TLS config
function config_storage()
{
    name=$1
    echo " ============================================================"
    echo " Bacula TLS config for StorageDaemon and Storages"
    echo " ============================================================"
    config="\n
  -------------------------------------------------------------------------------------\n
  # Include the lines below in file \"bacula-dir.conf\" in the \"Storage\" resource or\n
  # in the \"Autochanger\" resource\n
  -------------------------------------------------------------------------------------\n
  TlsEnable = true\n
  TlsRequire = true\n
  TlsCaCertificateFile = \"${certs_dir}/root_cert.pem\"\n
  TlsCertificate = \"${certs_dir}/${name}_cert.pem\"\n
  TlsKey = \"${keys_dir}/${name}_key.pem\"\n\n\n


  -------------------------------------------------------------------------------------\n
  # Include the lines below in file \"bacula-sd.conf\" in the \"Director\" resource and\n
  # in the \"Storage\" resource. Repeat the lines in all specified resources\n
  -------------------------------------------------------------------------------------\n
  TlsEnable = true\n
  TlsRequire = true   # Set false if you have clients without TLS\n
  TlsCaCertificateFile = \"${certs_dir}/root_cert.pem\"\n
  TlsCertificate = \"${certs_dir}/${name}_cert.pem\"\n
  TlsKey = \"${keys_dir}/${name}_key.pem\""
    echo -e ${config}
    echo
    echo -e ${config} > ${packs_dir}/${name}.txt
    zip -j ${packs_dir}/${name}.zip ${packs_dir}/${name}.txt ${certs_dir}/root_cert.pem ${certs_dir}/${name}_cert.pem ${keys_dir}/${name}_key.pem > /dev/null
    rm -f ${packs_dir}/${name}.txt
    echo
    echo " ************************************************************"
    echo " A package with all certificates and a sample config was"
    echo " generated in ${packs_dir}"
    echo " Filename: ${name}.zip"
    echo " ************************************************************"
    echo
}



#===============================================================================
# Generate  bacula tls config
function config_director()
{
    name=$1
    echo " ============================================================"
    echo " Bacula TLS config for DirectorDaemon and Bconsole"
    echo " ============================================================"
    config="\n
  -------------------------------------------------------------------------------------\n
  # Include the lines below in file \"bconsole.conf\" in the \"Director\" resource\n
  -------------------------------------------------------------------------------------\n
  TlsEnable = true\n
  TlsRequire = true\n
  TlsCaCertificateFile = \"${certs_dir}/root_cert.pem\"\n
  TlsCertificate = \"${certs_dir}/${name}_cert.pem\"\n
  TlsKey = \"${keys_dir}/${name}_key.pem\"\n\n\n


  -------------------------------------------------------------------------------------\n
  # Include the lines below in file \"bacula-dir.conf\" in the \"Director\" resource\n
  -------------------------------------------------------------------------------------\n
  TlsVerifyPeer = true\n
  TlsEnable = true\n
  TlsRequire = true\n
  TlsCaCertificateFile = \"${certs_dir}/root_cert.pem\"\n
  TlsCertificate = \"${certs_dir}/${name}_cert.pem\"\n
  TlsKey = \"${keys_dir}/${name}_key.pem\""
    echo -e ${config}
    echo
    echo -e ${config} > ${packs_dir}/${name}.txt
    zip -j ${packs_dir}/${name}.zip ${packs_dir}/${name}.txt ${certs_dir}/root_cert.pem ${certs_dir}/${name}_cert.pem ${keys_dir}/${name}_key.pem > /dev/null
    rm -f ${packs_dir}/${name}.txt
    echo
    echo " ************************************************************"
    echo " A package with all certificates and a sample config was"
    echo " generated in ${packs_dir}"
    echo " Filename: ${name}.zip"
    echo " ************************************************************"
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
        echo " Bacula selfsign certificates generator"
        echo " Author: Wanderlei Huttel"
        echo " Email:  wanderlei.huttel@gmail.com"
        echo " Version: ${version}"
        echo " =================================================="
        echo
        echo " What do you want to do?"
        echo "   1) Create CA certificate"
        echo "   2) Create Director certificate"
        echo "   3) Create Storage certificate"
        echo "   4) Create FileDaemon certificate"
        echo "   5) Revoke an existing certificate"
        echo "   6) Exit"
        read -p " Select an option [1-6]: " option
        echo
        case $option in
            1) # Generate CA
               generate_ca
               echo
               read -p " Press [enter] key to continue..." readenterkey
               ;;
            2) # Generate certificate for Director
               read -p " Inform Director name: " -e -i 'bacula-dir' name
               read -p " Inform Director address or FQDN: " -e -i 'localhost' address
               generate_certificate "${name}" "${address}" 1
               echo
               read -p " Press [enter] key to continue..." readenterkey
               ;;
            3) # Generate certificate for Storage
               address=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
               read -p " Inform Storage name: " -e -i 'bacula-sd' name
               read -p " Inform Storage address or FQDN: " -e -i ${address} address
               generate_certificate "${name}" "${address}" 2
               echo
               read -p " Press [enter] key to continue..." readenterkey
               ;;
            4) # Generate certificate for Client
               read -p " Inform Client name: " -e -i 'bacula-fd' name
               read -p " Inform Client address or FQDN: " -e -i 'localhost' address
               generate_certificate "${name}" "${address}" 3
               echo
               read -p " Press [enter] key to continue..." readenterkey
               ;;
            5) # Revoke an existing certificate
               revoke_certificate
               echo
               read -p " Press [enter] key to continue..." readenterkey
               ;;
            6) echo
               exit
               ;;
        esac
    done
}



#===============================================================================
# Detect Debian users running the script with "sh" instead of bash
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
    OS=debian
elif [[ -e /etc/centos-release || -e /etc/redhat-release ]]; then
    OS=centos
else
    echo "Looks like you aren't running this installer on Debian, Ubuntu or CentOS"
    exit
fi


# Check if ssl_dir exists, and if not, create folder structure
if [ ! -d ${ssl_dir} ]; then
    echo " =================================================="
    echo " Bacula selfsign certificates generator"
    echo " Author: Wanderlei Huttel"
    echo " Email:  wanderlei.huttel@gmail.com"
    echo " Version: ${version}"
    echo " =================================================="
    echo
    echo " It looks you do not have configured ${ssl_dir} directory"
    echo
    read -p " Press [enter] key to continue or CTRL+C to cancel..." readenterkey
    echo
    echo " Creating folder structure in ${ssl_dir} ..."
    echo
    echo
    mkdir -p ${ssl_dir}
    mkdir -p ${keys_dir}
    mkdir -p ${certs_dir}
    mkdir -p ${packs_dir}
    if [ "$(which wget)" == "" ] || [ "$(which zip)" == "" ]; then
        if [ "$OS" == "debian" ]; then
            apt-get install zip wget
        elif [ "$OS" == "centos" ]; then
            yum install -y zip wget
        fi
    fi

    if [ ! -f "${template_dir}/openssl.cnf.template" ]; then
        wget -c https://raw.githubusercontent.com/wanderleihuttel/bacula-utils/master/conf/openssl.cnf.template -O "${template_dir}/openssl.cnf.template"
    fi
    init_config
fi
menu
exit 0
