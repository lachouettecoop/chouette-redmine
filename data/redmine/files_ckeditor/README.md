Répertoire de stockage des images du plugin CKEditor
====================================================

Ce repertoire est utilisé par le module Rich du plugin CKEditor pour stocker les
images qu'on envoie vers le serveur.

Il est à mapper dans le fichier `docker-compose.yml` vers le répertoire
```
/usr/src/redmine/public/system/rich
```

**ATTENTION**: ce répertoire est configuré pour être accessible en écriture à tous le monde (1777) pour que Redmine puisse y créer le répertoire rich_files dont il a besoins.
