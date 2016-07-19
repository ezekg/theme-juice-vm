#!/bin/bash

# Kill previously symlinked Apache configs
# We can't know what sites have been removed, so we have to remove all
# the configs and add them back in again.
find /etc/apache2/custom-sites -name 'graft-auto-*.conf' -exec rm {} \;

# Look for site setup scripts
for SITE_CONFIG_FILE in $(find /srv/www -maxdepth 5 -name 'graft-init.sh'); do
  DIR="$(dirname "$SITE_CONFIG_FILE")"
  (
  cd "$DIR"
  source graft-init.sh
  )
done

# Look for Apache vhost files, symlink them into the custom sites dir
for SITE_CONFIG_FILE in $(find /srv/www -maxdepth 5 -name 'graft-apache.conf'); do
  DEST_CONFIG_FILE=${SITE_CONFIG_FILE//\/srv\/www\//}
  DEST_CONFIG_FILE=${DEST_CONFIG_FILE//\//\-}
  DEST_CONFIG_FILE=${DEST_CONFIG_FILE/%-graft-apache.conf/}
  DEST_CONFIG_FILE="graft-auto-$DEST_CONFIG_FILE-$(md5sum <<< "$SITE_CONFIG_FILE" | cut -c1-32).conf"
  # We allow the replacement of the {graft_path_to_folder} token with
  # whatever you want, allowing flexible placement of the site folder
  # while still having an Apache config which works.
  DIR="$(dirname "$SITE_CONFIG_FILE")"
  sed "s#{graft_path_to_folder}#$DIR#" "$SITE_CONFIG_FILE" > "/etc/apache2/custom-sites/""$DEST_CONFIG_FILE"
done

# Parse any graft-hosts file located in www/ or subdirectories of www/
# for domains to be added to the virtual machine's host file so that it is
# self aware.
#
# Domains should be entered on new lines.
echo "Cleaning the virtual machine's /etc/hosts file..."
sed -n '/# graft-auto$/!p' /etc/hosts > /tmp/hosts
mv /tmp/hosts /etc/hosts
echo "Adding domains to the virtual machine's /etc/hosts file..."
find /srv/www/ -maxdepth 5 -name 'graft-hosts' | \
while read hostfile; do
  while IFS='' read -r line || [ -n "$line" ]; do
    if [[ "#" != ${line:0:1} ]]; then
      if [[ -z "$(grep -q "^127.0.0.1 $line$" /etc/hosts)" ]]; then
        echo "127.0.0.1 $line # graft-auto" >> "/etc/hosts"
        echo " * Added $line from $hostfile"
      fi
    fi
  done < "$hostfile"
done
