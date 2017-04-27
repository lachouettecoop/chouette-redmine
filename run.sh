#!/bin/bash

set -e
cd `dirname $0`

function container_full_name() {
    # workaround for docker-compose ps: https://github.com/docker/compose/issues/1513
    echo `docker inspect -f '{{if .State.Running}}{{.Name}}{{end}}' \
            $(docker-compose ps -q) | cut -d/ -f2 | grep _${1}_`
}

function dc_dockerfiles_images() {
    DOCKERFILES=`grep -E '^\s*build:' docker-compose.yml|cut -d: -f2 |sed 's/\s*\([^ ]*\)\s*/\1\/Dockerfile/'`
    for dockerfile in $DOCKERFILES; do
        echo `grep "^FROM " $dockerfile |cut -d' ' -f2`
    done
}

function dc_exec_or_run() {
    CONTAINER_SHORT_NAME=$1
    CONTAINER_FULL_NAME=`container_full_name ${CONTAINER_SHORT_NAME}`
    shift
    if test -n "$CONTAINER_FULL_NAME" ; then
        # container already started
        docker exec -it $CONTAINER_FULL_NAME $*
    else
        # container not started
        docker-compose run --rm $CONTAINER_SHORT_NAME $*
    fi
}

case $1 in
    "")
        docker-compose up -d
        ;;
    init)
        test -e docker-compose.yml || cp docker-compose.yml.dist docker-compose.yml
        test -e data/redmine/configuration.yml \
            || cp data/redmine/configuration.yml.dist data/redmine/configuration.yml
        docker-compose run --rm mysql chown -R mysql:mysql /var/lib/mysql
        docker-compose run --rm redmine chown -R redmine:redmine log files public/system/rich
        ;;
    upgrade)
        read -rp "Êtes-vous sûr de vouloir effacer et mettre à jour les images et conteneurs Docker ? (o/n) "
        if [[ $REPLY =~ ^[oO]$ ]] ; then
            docker-compose pull
            for image in `dc_dockerfiles_images`; do
                docker pull $image
            done
            docker-compose build
            docker-compose stop
            docker-compose rm -f
            $0 update
        fi
        ;;
    update)
        $0 init
        $0
        echo "Attente de 5s..."
        sleep 5
        dc_exec_or_run redmine plugins/post-install.sh
        $0
        ;;
    prune)
        read -rp "Êtes-vous sûr de vouloir effacer les conteneurs et images Docker innutilisés ? (o/n)"
        if [[ $REPLY =~ ^[oO]$ ]] ; then
            # Note: la commande docker system prune n'est pas dispo sur les VPS OVH
            # http://stackoverflow.com/questions/32723111/how-to-remove-old-and-unused-docker-images/32723285
            exited_containers=$(docker ps -qa --no-trunc --filter "status=exited")
            test "$exited_containers" != ""  && docker rm $exited_containers
            dangling_images=$(docker images --filter "dangling=true" -q --no-trunc)
            test "$dangling_images" != "" && docker rmi $dangling_images
        fi
        ;;
    bash)
        dc_exec_or_run redmine $*
        ;;
    mysql|mysqldump|mysqlrestore)
        case $1 in
            mysql)        cmd=mysql;     option="-it";;
            mysqldump)    cmd=mysqldump; option=     ;;
            mysqlrestore) cmd=mysql;     option="-i" ;;
        esac
        MYSQL_CONTAINER=`container_full_name mysql`
        MYSQL_PASSWORD=`grep MYSQL_PASSWORD docker-compose.yml|cut -d= -f2`
        docker exec $option $MYSQL_CONTAINER $cmd --user=redmine --password=$MYSQL_PASSWORD redmine
        ;;
    build|config|create|down|events|exec|kill|logs|pause|port|ps|pull|restart|rm|run|start|stop|unpause|up)
        docker-compose $*
        ;;
    *)
        cat <<HELP
Utilisation : $0 [COMMANDE]
  init         : initialise les données
               : lance les conteneurs
  upgrade      : met à jour les images et les conteneurs Docker
  update       : a exécuter après une mise à jour
  prune        : efface les conteneurs et images Docker inutilisés
  bash         : lance bash sur le conteneur redmine
  mysql        : lance mysql sur le conteneur mysql, en mode interactif
  mysqldump    : lance mysqldump sur le conteneur mysql
  mysqlrestore : permet de rediriger un dump vers la commande mysql
  stop         : stoppe les conteneurs
  rm           : efface les conteneurs
  logs         : affiche les logs des conteneurs
HELP
        ;;
esac

