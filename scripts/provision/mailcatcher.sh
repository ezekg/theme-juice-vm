#!/bin/bash

# Installs mailcatcher using RVM. RVM allows us to install all mailcatcher
# dependencies reliably.
mailcatcher_version="$(/usr/bin/env mailcatcher --version 2>&1 | grep 'mailcatcher ' | cut -d " " -f 2)"
if [[ -n "${mailcatcher_version}" ]]; then
  pkg="Mailcatcher"
  space_count="$(( 20 - ${#pkg}))" #11
  pack_space_count="$(( 30 - ${#mailcatcher_version}))"
  real_space="$(( ${space_count} + ${pack_space_count} + ${#mailcatcher_version}))"
  printf " * $pkg %${real_space}.${#mailcatcher_version}s ${mailcatcher_version}\n"
else
  echo " * Mailcatcher [not installed]"
  /usr/bin/env rvm default@mailcatcher --create do gem install mailcatcher --no-rdoc --no-ri
  /usr/bin/env rvm wrapper default@mailcatcher --no-prefix mailcatcher catchmail
fi

if [[ -f "/etc/init/mailcatcher.conf" ]]; then
  echo " *" Mailcatcher upstart already configured.
else
  rsync -rvzh "/srv/config/init/mailcatcher.conf"  "/etc/init/mailcatcher.conf"
  echo " * /srv/config/init/mailcatcher.conf -> /etc/init/mailcatcher.conf"
fi

if [[ -f "/etc/php5/mods-available/mailcatcher.ini" ]]; then
  echo " * Mailcatcher php already configured."
else
  rsync -rvzh "/srv/config/php5-config/mailcatcher.ini" "/etc/php5/mods-available/mailcatcher.ini"
  echo " * /srv/config/php5-config/mailcatcher.ini -> /etc/php5/mods-available/mailcatcher.ini"
fi
