# La Chouette Coop - Redmine

Ce projet contient l'outil de gestion de projet de "[La chouette coop](http://lachouettecoop.fr/)".

*Pour rejoindre l'aventure au sein du groupe informatique contactez moi ou
utilisez le site !*

## Pré-requis

* récupérer le projet (`git clone`)
* avoir [Docker](http://docs.docker.com/) et [Docker Compose](http://docs.docker.com/compose/install/) installé

## Configuration

* Créer un fichier `docker-compose.yml` à partir de la version `.dist`.
  Y modifier les sections `environment:`.
* Idem pour le fichier `data/redmine/configuration.yml` pour parametrer l'envoie d'emails.


## Utilisation

Pour lancer l'application exécutez simplement la commande :

```
docker-compose up -d
```

### Bonus

Si vous avez [nginx-proxy](https://github.com/jwilder/nginx-proxy) en place (suivre procédure de lancement très simple sur la doc) le site sera accessible à l'url : http://gestion.lachouettecoop.test/

## Licence

[GPL v2.0](LICENSE)
