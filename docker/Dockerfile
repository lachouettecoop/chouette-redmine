FROM redmine:3.3.4-passenger

# Permettre au module Apache passenger de compiler sa lib native,
# dans le répertoire /home/redmine:
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libmysqlclient-dev  build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/redmine && chown redmine /home/redmine

# Installation de la commande git utilisée plus loin dans ce fichier:
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Installation de du plugin ldap_sync
# https://github.com/thorin/redmine_ldap_sync
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://github.com/thorin/redmine_ldap_sync/archive/2.0.7.tar.gz" | tar zx) \
    && mv redmine_ldap_sync-2.0.7 redmine_ldap_sync

# Installation du plugin base_deface
# https://github.com/jbbarth/redmine_base_deface
# Installation de version du 19 Janvier 2017 (e31dd251f859081545c0e00c4af63de047fa99bc)
RUN cd /usr/src/redmine/plugins/ \
    && git clone https://github.com/jbbarth/redmine_base_deface.git \
    && cd redmine_base_deface \
    && git checkout e31dd251f859081545c0e00c4af63de047fa99bc \
    && (echo "source 'https://rubygems.org'" >> Gemfile) \
    && bundle install

# Installation du plugin redmine_multiprojects_issue
# https://github.com/nanego/redmine_multiprojects_issue
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://github.com/nanego/redmine_multiprojects_issue/archive/v3.3.0.tar.gz" | tar zx) \
    && mv redmine_multiprojects_issue-3.3.0 redmine_multiprojects_issue

# Installation du plugin scrum (backlog, sprint)
# http://www.redmine.org/plugins/scrum-plugin
# sed pour changer les couleurs en plus claire et rendre le texte plus lisible.
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://redmine.ociotec.com/attachments/download/440/scrum%20v0.16.2.tar.gz" | tar zx) \
    && sed -i -e "s/#F7D6FF/#FAEAFF/g" -e "s/#E9B1FF/#F0D1FF/g" -e "s/#C4FFCA/#E2FFE5/g" -e "s/#9CFFA4/#CEFFD2/g" -e "s/#C8E7FF/#E4F3FF/g" -e "s/#A3BFD7/#D1DFEB/g" -e "s/#FFCCF3/#FFE6F9/g" -e "s/#FFA4E5/#FFD2F2/g" scrum/assets/stylesheets/scrum.css

# Installation du plugin ckeditor pour avoir un éditeur WYSIWIG
# https://github.com/a-ono/redmine_ckeditor
# Supprime la dépendance Gemfile vers sprockets-rails à cause du conflit de version.
# Install le programme pandoc pour pouvoir migrer la base vers HTML
# Commande a exécuter pour la migration de la base vers le format HTML:
#     bundle exec rake redmine_ckeditor:migrate RAILS_ENV=production FROM=textile TO=html
# Configuration de Redmine
#     Administration/Configuration/Général/Formatage du texte = Ckeditor
# Configuration du plugin CKEditor:
#     Skin: moono-modifie
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://github.com/a-ono/redmine_ckeditor/archive/1.1.4.tar.gz" | tar zx) \
    && mv redmine_ckeditor-1.1.4 redmine_ckeditor \
    && cd redmine_ckeditor \
    && sed -i "s/.*sprockets-rails.*/source 'https:\/\/rubygems.org'/" Gemfile \
    && bundle install \
    && apt-get update \
    && apt-get install -y --no-install-recommends pandoc \
    && rm -rf /var/lib/apt/lists/*
# Les images incluses dans les documents CKEditor grace à son extension  rcich
# seront stockées dans le répertore /usr/src/redmine/public/system/rich"]
VOLUME ["/usr/src/redmine/public/system/rich"]

# Apply patch so that:
# - default / page will list projects
# - listed project links will jump to their wiki page
COPY home-to-project-index.patch project-hierarchy-jump-to-wiki.patch /usr/src/redmine/
RUN cd /usr/src/redmine/ \
    && patch -p1 -E < home-to-project-index.patch \
    && patch -p1 -E < project-hierarchy-jump-to-wiki.patch 

# Installation du plugin issuecloser (redmine_issue_closer)
# Pour lequel on supprime la contrainte "is_closed=false" dans
# la sélection du status source.
RUN cd /usr/src/redmine/plugins/ \
    && git clone "https://github.com/isheninp/redmine_issue_closer.git" issuecloser \
    && cd issuecloser \
    && git checkout c359c004f19e706a70fd694870354b7ba2827e17 \
    && sed -i "s/.where('is_closed=false')/.all/" app/views/settings/_issuecloser.html.erb \
    && echo "" >> Gemfile \
    && echo "source 'https://rubygems.org'" >> Gemfile \
    && (bundle check || bundle install)

