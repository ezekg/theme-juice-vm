#!/bin/bash

rsync -rvzh /srv/config/init/graft-start.conf /etc/init/graft-start.conf

echo " * /srv/config/init/graft-start.conf -> /etc/init/graft-start.conf"

# If a custom httpd.conf file is not found, create an empty one
if [[ ! -f "/srv/config/apache-config/httpd.conf" ]]; then
  touch "/srv/config/apache-config/httpd.conf"
fi

# Copy Apache configuration from local
rsync -rvzh "/srv/config/apache-config/apache2.conf" "/etc/apache2/apache2.conf"
rsync -rvzh "/srv/config/apache-config/httpd.conf" "/etc/apache2/httpd.conf"
rsync -rvzh --delete "/srv/config/apache-config/sites/" "/etc/apache2/custom-sites/"

echo " * /srv/config/apache-config/apache2.conf -> /etc/apache2/apache2.conf"
echo " * /srv/config/apache-config/httpd.conf -> /etc/apache2/httpd.conf"
echo " * /srv/config/apache-config/sites/ -> /etc/apache2/custom-sites/"

# Configure Apache
a2enmod actions fastcgi alias

# Enable mod_rewrite
a2enmod rewrite

# Enable SSL
a2enmod ssl
a2ensite default-ssl.conf

# Allow phpbrew to access apache files
chmod -R oga+rw /usr/lib/apache2/modules
chmod -R oga+rw /etc/apache2
