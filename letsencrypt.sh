#!/bin/bash

DOMAIN='comm.tuimac.com'
BASEDIR='/etc/letsencrypt/archive/'${DOMAIN}


function createCerts(){
    [[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }
    wget -r --no-parent -A 'epel-release-*.rpm' https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/
    rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-*.rpm
    yum-config-manager --enable epel*
    amazon-linux-extras install epel -y
    yum install -y certbot python2-certbot-nginx expect
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

main
