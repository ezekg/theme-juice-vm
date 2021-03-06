#!/bin/bash

# Download phpMyAdmin
if [[ ! -d /srv/www/default/database-admin ]]; then
  echo "Downloading phpMyAdmin..."
  cd /srv/www/default
  wget -q -O phpmyadmin.tar.gz "https://files.phpmyadmin.net/phpMyAdmin/4.4.10/phpMyAdmin-4.4.10-all-languages.tar.gz"
  tar -xf phpmyadmin.tar.gz
  mv phpMyAdmin-4.4.10-all-languages database-admin
  rm phpmyadmin.tar.gz
else
  echo "PHPMyAdmin already installed."
fi
rsync -rvzh "/srv/config/phpmyadmin-config/config.inc.php" "/srv/www/default/database-admin/"
echo " * /srv/config/phpmyadmin-config/config.inc.php -> /srv/www/default/database-admin/"
