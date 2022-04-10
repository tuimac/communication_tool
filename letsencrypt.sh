#!/bin/bash

# You need to change here.
DOMAIN='comm.tuimac.com'
MAIL='tuimac.devadm01@gmail.com'

# Just Let's encrypt directory
BASEDIR='/etc/letsencrypt/archive/'${DOMAIN}

function createCerts(){
    [[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }
    wget -r --no-parent -A 'epel-release-*.rpm' https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/
    rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-*.rpm
    yum-config-manager --enable epel*
    amazon-linux-extras install epel -y
    yum install -y certbot python2-certbot-nginx expect
    expect -c "
    set timeout 15
    spawn certbot certonly
    expect \"Select the appropriate number \[1-2\] then \[enter\] (press 'c' to cancel):\"
    send \"1\n\"
    expect \" (Enter 'c' to cancel):\"
    send \"${MAIL}\n\"
    expect \"(Y)es\/(N)o:\"
    send \"Y\n\"
    expect \"(Y)es\/(N)o:\"
    send \"Y\n\"
    expect \"Please enter in your domain name(s) (comma and\/or space separated)  (Enter 'c' to cancel):\"
    send \"${DOMAIN}\n\"
    expect \"Congratuation!*\"
    exit 0"
    mkdir -p nginx/letsencrypt
    cp ${BASEDIR}/fullchain1.pem nginx/letsencrypt/fullchain.pem
    cp ${BASEDIR}/privkey1.pem nginx/letsencrypt/privkey.pem
}

function renewCerts(){
    certbot renew --no-self-upgrade
    cp ${BASEDIR}/fullchain1.pem nginx/letsencrypt/fullchain.pem
    cp ${BASEDIR}/privkey1.pem nginx/letsencrypt/privkey.pem
}

function userguide(){
    echo -e "usage: ./letsencrypt.sh.sh [help | create | delete]"
    echo -e "
optional arguments:
create              Create Let's Encrypt certifications.
delete              Delete  Let's Encrypt certifications.
    "
}

function main(){
    [[ -z $1 ]] && { userguide; exit 1; }
    case $1 in
        'create')
            createCerts
            ;;
        'help')
            userguide
            exit 1
            ;;
        *)
            userguide
            exit 1
            ;;
    esac    
}

main $1
