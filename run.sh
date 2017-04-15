#!/bin/bash

set -e
cd `dirname $0`

function container_full_name() {
    # workaround for docker-compose ps: https://github.com/docker/compose/issues/1513
    echo `docker inspect -f '{{if .State.Running}}{{.Name}}{{end}}' \
            $(docker-compose ps -q) | cut -d/ -f2 | grep $1`
}

case $1 in
    "")
        docker-compose up -d
        ;;
    init)
        test -e docker-compose.yml || cp docker-compose.yml.dist docker-compose.yml
        test -e data/redmine/configuration.yml || cp data/redmine/configuration.yml.dist data/redmine/configuration.yml
        docker-compose run --rm mysql chown -R mysql:mysql /var/lib/mysql
        docker-compose run --rm redmine chown -R redmine:redmine log files public/system/rich
        ;;
    upgrade)
        read -rp "Êtes-vous sûr de vouloir mettre à jour les images et conteneurs Docker ? (o/n)"
        if [[ $REPLY =~ ^[oO]$ ]] ; then
            docker-compose pull
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
        REDMINE_CONTAINER=`container_full_name _redmine_`
        docker exec -it $REDMINE_CONTAINER plugins/post-install.sh
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
        REDMINE_CONTAINER=`container_full_name _redmine_`
        docker exec -it $REDMINE_CONTAINER $*
        ;;
    mysql|mysqldump|mysqlrestore)
        case $1 in
            mysql)        cmd=mysql;     option="-it";;
            mysqldump)    cmd=mysqldump; option=     ;;
            mysqlrestore) cmd=mysql;     option="-i" ;;
        esac
        MYSQL_CONTAINER=`container_full_name _mysql_`
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
  update       : a exécuter après une mise à jour
  upgrade      : met à jour les images et les conteneurs Docker
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

