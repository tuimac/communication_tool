#!/bin/bash

DOMAIN='comm.tuimac.com'

function createCerts(){
    
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
