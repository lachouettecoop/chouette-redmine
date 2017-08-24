FROM redmine:3.4.2-passenger

# Permettre au module Apache passenger de compiler sa lib native,
# dans le répertoire /home/redmine:
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libmysqlclient-dev  build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/redmine && chown redmine /home/redmine \
    && rm -rf /var/lib/apt/lists/*

# Installation de du plugin ldap_sync
# https://github.com/thorin/redmine_ldap_sync
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://github.com/thorin/redmine_ldap_sync/archive/2.0.7.tar.gz" | tar zx) \
    && mv redmine_ldap_sync-2.0.7 redmine_ldap_sync

# Installation du plugin base_deface
# https://github.com/jbbarth/redmine_base_deface
# Installation de version du 10 Mai 2017 (b9796f7d11fdd126623e8cabf7a3698b78daab51)
RUN cd /usr/src/redmine/plugins/ \
    && base_deface_version=b9796f7d11fdd126623e8cabf7a3698b78daab51 \
    && (wget -q -O - "https://github.com/jbbarth/redmine_base_deface/archive/${base_deface_version}.tar.gz" | tar xz) \
    && mv redmine_base_deface-${base_deface_version} redmine_base_deface \
    && cd redmine_base_deface \
    && (echo "source 'https://rubygems.org'" >> Gemfile)

# Installation du plugin redmine_multiprojects_issue
# https://github.com/nanego/redmine_multiprojects_issue
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://github.com/nanego/redmine_multiprojects_issue/archive/v3.3.0.tar.gz" | tar zx) \
    && mv redmine_multiprojects_issue-3.3.0 redmine_multiprojects_issue

# Installation du plugin scrum (backlog, sprint)
# http://www.redmine.org/plugins/scrum-plugin
# sed pour changer les couleurs en plus claire et rendre le texte plus lisible.
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://redmine.ociotec.com/attachments/download/470/scrum-v0.17.0.tar.gz" | tar zx) \
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
    && (wget -q -O - "https://github.com/a-ono/redmine_ckeditor/archive/1.1.5.tar.gz" | tar zx) \
    && mv redmine_ckeditor-1.1.5 redmine_ckeditor \
    && cd redmine_ckeditor \
    && sed -i "s/.*sprockets-rails.*/source 'https:\/\/rubygems.org'/" Gemfile \
    && apt-get update \
    && apt-get install -y --no-install-recommends pandoc \
    && rm -rf /var/lib/apt/lists/*
# Les images incluses dans les documents CKEditor grace à son extension  rcich
# seront stockées dans le répertore /usr/src/redmine/public/system/rich"]
VOLUME ["/usr/src/redmine/public/system/rich"]

# Installation du plugin issuecloser (redmine_issue_closer)
# Pour lequel on supprime la contrainte "is_closed=false" dans
# la sélection du status source.
RUN cd /usr/src/redmine/plugins/ \
    && issue_closer_version=c359c004f19e706a70fd694870354b7ba2827e17 \
    && (wget -q -O - "https://github.com/isheninp/redmine_issue_closer/archive/${issue_closer_version}.tar.gz" | tar zx) \
    && mv redmine_issue_closer-${issue_closer_version} issuecloser \
    && cd issuecloser \
    && sed -i "s/.where('is_closed=false')/.all/" app/views/settings/_issuecloser.html.erb \
    && echo "" >> Gemfile \
    && echo "source 'https://rubygems.org'" >> Gemfile

# Installation du plugin Redmine Lightbox 2
# This plugin lets you preview image, pdf and swf attachments in a lightbox.
RUN cd /usr/src/redmine/plugins/ \
    && lightbox_version=0.4.3 \
    && (wget -q -O - "https://github.com/paginagmbh/redmine_lightbox2/archive/v${lightbox_version}.tar.gz" | tar zx) \
    && mv redmine_lightbox2-${lightbox_version} redmine_lightbox2

# Installation du plugin Redmine Dashboard 2
RUN cd /usr/src/redmine/plugins/ \
    && dashboard_version=4c130e3883ca9bf909d519d5d29bd3a0a2a89201 \
    && (wget -q -O - "https://github.com/jgraichen/redmine_dashboard/archive/${dashboard_version}.tar.gz" | tar zx) \
    && mv redmine_dashboard-${dashboard_version} redmine_dashboard

## Installation du plugin redmine_pretend
#RUN cd /usr/src/redmine/plugins/ \
#    && redmine_pretend_version=6046e195bb58311ccf5725272162a3a5033afd5f \
#    && (wget -q -O - "https://github.com/batizhevsky/redmine_pretend/archive/${redmine_pretend_version}.tar.gz" | tar zx) \
#    && mv redmine_pretend-${redmine_pretend_version} redmine_pretend

# Installation des dépendances (bundle Gemfile)
# Supprimme le fichier Gemfile.lock et commence par
# installer en mode --no-deployment à cause d'un
# pb d'installation du bundle "rich" depuis git puis
# d'une erreur comme quoi il y aurait une différence
# entre Gemfile et Gemfile.lock
RUN set +x \
    && cd /usr/src/redmine/ \
    && rm -f Gemfile.lock Gemfile.lock.mysql2 \
    && bundle install --no-deployment \
    && bundle install \
    && cp Gemfile.lock Gemfile.lock.mysql2 \
    && chown redmine Gemfile*

# Apply patch so that:
# - default / page will list projects
# - listed project links will jump to their wiki page
# - svg mime type http://www.redmine.org/issues/11595
# - scrum plugin fix for Redmine 3.4 https://redmine.ociotec.com/issues/1381
COPY home-to-project-index.patch \
     project-hierarchy-jump-to-wiki.patch \
     svg-mime_type.patch \
     scrum_plugin-issue_1381.patch \
     /usr/src/redmine/
RUN cd /usr/src/redmine/ \
    && for p in *.patch ; do \
        echo "apply patch $p"; \
        patch -p1 -E < $p; \
    done

