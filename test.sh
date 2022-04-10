#!/bin/bash

DOMAIN='comm.tuimac.com'

function delete(){
    docker stop test
    docker rm test
    docker rmi nginx:latest
}

function healthcheck(){
    docker run -itd --name test -p 80:80 nginx:latest
    sleep 2
    for i in {0..10}; do
        STATUS_CODE=$(curl -LI http://${DOMAIN} -m 5 -o /dev/null -w '%{http_code}\n' -s)
        [[ $STATUS_CODE == '200' ]] && { echo 'Success!!'; delete; return 0; }
        sleep 1
    done
    echo 'Health Check has been failed!'
    return 1
}


healthcheck
echo $?
