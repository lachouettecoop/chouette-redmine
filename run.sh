#!/bin/bash

cd `dirname $0` || exit -1

case $1 in
    "")
        test -e docker-compose.yml || cp docker-compose.yml.dist docker-compose.yml
        test -e data/redmine/configuration.yml || cp data/redmine/configuration.yml.dist data/redmine/configuration.yml
        docker-compose up -d
        ;;
    bash)
        REDMINE_CONTAINER=`docker-compose ps |grep _redmine_ |cut -d" " -f1`
        docker exec -it $REDMINE_CONTAINER $*
        ;;
    mysql|mysqldump|mysqlrestore)
        case $1 in
            mysql)        cmd=mysql;     option="-it";;
            mysqldump)    cmd=mysqldump; option=     ;;
            mysqlrestore) cmd=mysql;     option="-i" ;;
        esac
        MYSQL_CONTAINER=`docker-compose ps |grep _mysql_ |cut -d" " -f1`
        MYSQL_PASSWORD=`grep MYSQL_PASSWORD docker-compose.yml|cut -d= -f2`
        docker exec $option $MYSQL_CONTAINER $cmd --user=redmine --password=$MYSQL_PASSWORD redmine
        ;;
    build|config|create|down|events|exec|kill|logs|pause|port|ps|pull|restart|rm|run|start|stop|unpause|up)
        docker-compose $*
        ;;
    *)
        cat <<HELP
Utilisation : $0 [COMMANDE]
               : lance les containers
  bash         : lance bash sur le container redmine
  mysql        : lance mysql sur le container mysql, en mode interactif
  mysqldump    : lance mysqldump sur le container mysql
  mysqlrestore : permet de rediriger un dump vers la commande mysql
  stop         : stop les containers
  rm           : efface les containers
  logs         : affiche les logs du container
HELP
        ;;
esac

