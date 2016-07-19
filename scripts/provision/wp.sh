#!/bin/bash

# WP-CLI Install
if [[ ! -d "/srv/www/wp-cli" ]]; then
  echo -e "\nDownloading wp-cli, see http://wp-cli.org"
  git clone "https://github.com/wp-cli/wp-cli.git" "/srv/www/wp-cli"
  cd /srv/www/wp-cli
  composer install
else
  echo -e "\nUpdating wp-cli..."
  cd /srv/www/wp-cli
  git pull --rebase origin master
  composer update
fi

# Link `wp` to the `/usr/local/bin` directory
ln -sf "/srv/www/wp-cli/bin/wp" "/usr/local/bin/wp"
