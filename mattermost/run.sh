#!/bin/bash

function createContainers(){
    mkdir -p ./mattermost/{data,logs,config,plugins}
    chown -R ${USER}:${USER} ./mattermost/
    docker-compose up -d
}

function deleteAll(){
    docker-compose down
    docker rmi postgresql
    docker rmi mattermost
    docker rmi nginx
    cleanup
    sudo rm -rf ./postgresql/data
    sudo rm -rf ./postgresql/wal_archive
    sudo rm -rf ./postgresql/logs
    sudo rm -rf ./nginx/logs
    sudo rm -rf ./mattermost
}

function stopContaiers(){
    docker-compose stop
}

function startContaiers(){
    docker-compose start
}

function restartContaiers(){
    docker-compose restart
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
