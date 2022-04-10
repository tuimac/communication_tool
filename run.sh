#!/bin/bash

function _genPassword(){
    openssl rand -hex 16
}

function _jitsiGenPassword(){
    local COFO_AUTH_PASSWORD=$(_genPassword)
    local JVB_AUTH_PASSWORD=$(_genPassword)
    local JIGASI_XMPP_PASSWORD=$(_genPassword)
    local JIBRI_RECORDER_PASSWORD=$(_genPassword)
    local JIBRI_XMPP_PASSWORD=$(_genPassword)

    sed -i.bak \
        -e "s#JICOFO_AUTH_PASSWORD=.*#JICOFO_AUTH_PASSWORD=${JICOFO_AUTH_PASSWORD}#g" \
        -e "s#JVB_AUTH_PASSWORD=.*#JVB_AUTH_PASSWORD=${JVB_AUTH_PASSWORD}#g" \
        -e "s#JIGASI_XMPP_PASSWORD=.*#JIGASI_XMPP_PASSWORD=${JIGASI_XMPP_PASSWORD}#g" \
        -e "s#JIBRI_RECORDER_PASSWORD=.*#JIBRI_RECORDER_PASSWORD=${JIBRI_RECORDER_PASSWORD}#g" \
        -e "s#JIBRI_XMPP_PASSWORD=.*#JIBRI_XMPP_PASSWORD=${JIBRI_XMPP_PASSWORD}#g" \
        "$(dirname "$0")/.env"
}

function createContainers(){
    cp env .env
    mkdir -p postgresql/{data,logs,wal_archive}
    mkdir -p mattermost/{config,data,logs,plugins,client/plugins,bleve-indexes}
    mkdir -p jitsi/{web/crontabs,web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
    mkdir -p nginx/{logs}
    sudo chown -R 999:999 postgresql/
    sudo chown -R 2000:2000 mattermost/
    sudo chown -R 101:101 nginx/
    docker-compose up -d
}

function deleteAll(){
    docker-compose down
    sudo rm -rf postgresql/{data,logs,wal_archive}
    sudo rm -rf mattermost
    sudo rm -rf jitsi
    sudo rm -rf nginx/logs
    sudo chown -R ec2-user:ec2-user .
    rm .env
}

function stopContainers(){
    cp env .env
    docker-compose down
}

function startContainers(){
    docker-compose up -d
}

function restartContainers(){
    docker-compose down
    cp env .env
    docker-compose up -d
}

function userguide(){
    echo -e "usage: ./run.sh [help | create | delete]"
    echo -e "
optional arguments:
create              Create image and container after that run the container.
delete              Delete image and container.
    "
}

function main(){
    [[ -z $1 ]] && { userguide; exit 1; }
    case $1 in
        'create')
            createContainers
            ;;
        'delete')
            deleteAll
            ;;
        'stop')
            stopContainers
            ;;
        'start')
            startContainers
            ;;
        'restart')
            restartContainers
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
