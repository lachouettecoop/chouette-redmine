#!/bin/bash

cd `dirname $0` || exit -1

case $1 in
    "")
        docker-compose up -d
        ;;
    init)
        test -e docker-compose.yml || cp docker-compose.yml.dist docker-compose.yml
        test -e data/redmine/configuration.yml || cp data/redmine/configuration.yml.dist data/redmine/configuration.yml
        docker-compose run mysql  chown -R mysql:mysql /var/lib/mysql
        docker-compose run redmine chown -R redmine:redmine log files public/system/rich
        ;;
    post-install)
        REDMINE_CONTAINER=`docker-compose ps |grep _redmine_ |cut -d" " -f1`
        docker exec -it $REDMINE_CONTAINER plugins/post-install.sh
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
  init         : initialise
               : lance les conteneurs
  post-install : a exécuter après une mise à jour
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

