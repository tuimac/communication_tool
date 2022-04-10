#!/bin/bash

# You need to change here.
DOMAIN='comm.tuimac.com'
MAIL='tuimac.devadm01@gmail.com'

# Just Let's encrypt directory
BASEDIR='/etc/letsencrypt/archive/'${DOMAIN}

function _envDelete(){
    docker stop test
    docker rm test
    docker rmi nginx:latest
}

function _healthcheck(){
	docker run -itd --name test -p 80:80 nginx:latest
	sleep 2
	for i in {0..10}; do
		STATUS_CODE=$(curl -LI http://${DOMAIN} -o /dev/null -w '%{http_code}\n' -s)
		[[ $STATUS_CODE == '200' ]] && { _envDelete; return 0; }
		sleep 3
	done
    _envDelete
	return 1
}


function createCerts(){
    # Check authorization
    [[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }

    # Install fedora repository to install certbot
    wget -r --no-parent -A 'epel-release-*.rpm' https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/
    rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-*.rpm
    yum-config-manager --enable epel*
    amazon-linux-extras install epel -y

    # Install software
    yum install -y certbot python2-certbot-nginx expect

    # Health Check if the DOMAIN url is valid or not
    _healthcheck
    [[ $? -ne 0 ]] && { echo 'Health Check has been failed!'; exit 1; }

    # Create the certifications of Let's encrypt by expect
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

    # Create the directory to deploy the SSL certs for nginx container
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
