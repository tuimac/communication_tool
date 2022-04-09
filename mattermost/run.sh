#!/bin/bash

function createContainers(){
    cp env .env
    mkdir -p ./postgresql/{data,logs,config,wal_archive}
    mkdir -p ./mattermost/{data,logs,config,plugins}
    mkdir -p ./nginx/{logs,config}
    sudo chown 999:999 -R postgresql/
    chown -R ${USER}:${USER} ./mattermost/
    sudo chown 101:101 -R nginx/
    docker-compose up -d
}

function deleteAll(){
    docker-compose down
    sudo rm -rf ./postgresql/data
    sudo rm -rf ./postgresql/wal_archive
    sudo rm -rf ./postgresql/logs
    sudo rm -rf ./mattermost
    sudo rm -rf ./nginx/logs
    sudo chown -R ec2-user:ec2-user .
    rm .env
}

function stopContaiers(){
    docker-compose down
}

function startContaiers(){
    docker-compose up -d
}

function restartContaiers(){
    docker-compose down
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
