#!/bin/bash

function runContainer(){
    mkdir -p ./volumes/app/mattermost/{data,logs,config,plugins}
    chown -R ${USER}:${USER} ./volumes/app/mattermost/
    docker-compose up -d
}

function cleanup(){
    docker image prune -f
    docker container prune -f
}

function createContainer(){
    runContainer
    cleanup
}

function deleteAll(){
    docker-compose down
    docker rmi mattermost_web
    docker rmi mattermost_app
    docker rmi mattermost_db
    cleanup
    sudo rm -rf volumes/
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
            createContainer
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
