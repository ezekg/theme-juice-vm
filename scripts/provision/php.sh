#!/bin/bash

# Make sure these directories exist
mkdir -p "/etc/php5/apache2/custom-conf.d/"

# Copy php configuration from local
rsync -rvzh "/srv/config/php5-config/php-custom.ini" "/etc/php5/apache2/custom-conf.d/php-custom.ini"
rsync -rvzh "/srv/config/php5-config/opcache.ini" "/etc/php5/apache2/custom-conf.d/opcache.ini"
rsync -rvzh "/srv/config/php5-config/xdebug.ini" "/etc/php5/apache2/custom-conf.d/xdebug.ini"

# Find the path to Xdebug and prepend it to xdebug.ini
XDEBUG_PATH=$(find /usr -name 'xdebug.so' | head -1)
sed -i "1izend_extension=\"$XDEBUG_PATH\"" "/etc/php5/mods-available/xdebug.ini"

echo " * /srv/config/php5-config/php-custom.ini -> /etc/php5/apache2/custom-conf.d/php-custom.ini"
echo " * /srv/config/php5-config/opcache.ini -> /etc/php5/apache2/custom-conf.d/opcache.ini"
echo " * /srv/config/php5-config/xdebug.ini -> /etc/php5/apache2/custom-conf.d/xdebug.ini"

# Copy memcached configuration from local
rsync -rvzh "/srv/config/memcached-config/memcached.conf" "/etc/memcached.conf"
echo " * /srv/config/memcached-config/memcached.conf    -> /etc/memcached.conf"

# phpbrew
#
# Install or update phpbrew based on current state.
if [[ "$(phpbrew --version)" ]]; then
  # Update as root user
  echo "Updating phpbrew..."
  phpbrew self-update
else
  echo "Installing phpbrew..."
  curl -L -O "https://github.com/phpbrew/phpbrew/raw/master/phpbrew"
  chmod +x "phpbrew"
  mv "phpbrew" "/usr/local/bin/phpbrew"
  # Initialize as vagrant user
  echo "Initializing phpbrew..."
  sudo -i -u vagrant phpbrew init
fi

# php-switch
#
# Install php-switch helper.
if [[ ! -f "/usr/local/bin/php-switch" ]]; then
  echo "Installing php-switch..."
  cat > /usr/local/bin/php-switch <<'EOT'
#!/usr/bin/env bash
VERSION="$1"
SOFILE="/usr/lib/apache2/modules/libphp$VERSION.so"
CONFFILE="/etc/apache2/mods-available/php5.load"

if [[ -z "$VERSION" ]]; then
echo "No PHP version specified"
echo "Usage: php-switch <version> [-y]"
echo "   -y: answer yes to all prompts"
sudo -E -i -u vagrant phpbrew list
exit 1
fi

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
echo "Invalid PHP version: $VERSION (should be x.x.x)"
sudo -E -i -u vagrant phpbrew known
exit 1
fi

if [[ ! "$VERSION" =~ ^5 ]]; then
echo "Right now, only PHP version 5.x is supported."
echo "Do you know how to configure PHP 7.x (or older versions of PHP) using"
echo "PHPBrew? Help out by submitting a pull request at:"
echo "https://github.com/themejuice/graft"
exit 1
fi

if [[ ! -f "$SOFILE" ]]; then
echo "PHP version $VERSION is not installed"

if [[ "${@: -1}" =~ ^-y$ ]]; then
  REPLY=y
else
  read -p "Do you want to install it? (y/N) " -r
fi

if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  echo "Installing PHP version $VERSION..."
  sudo -E -i -u vagrant phpbrew install "php-$VERSION" +default +mysql +debug +iconv +apxs2=/usr/bin/apxs2 -- --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-config-file-scan-dir=/etc/php5/apache2/custom-conf.d/
else
  exit 0
fi
fi

sudo -E su vagrant <<END
source ~vagrant/.phpbrew/bashrc

echo "Switching PHP version to $VERSION..."
phpbrew switch "$VERSION"

echo "Installing PHP extensions for version $VERSION..."
phpbrew ext install openssl || echo "Failed to install openssl"
phpbrew ext install memcache || echo "Failed to install memcache"
phpbrew ext install imagick || echo "Failed to install imagick"
phpbrew ext install xdebug && phpbrew ext disable xdebug || echo "Failed to install xdebug"
END

if [[ -f "$SOFILE" ]]; then
echo "Updating contents of $CONFFILE to load PHP version $VERSION..."
echo "LoadModule php5_module $SOFILE" > "$CONFFILE"
else
echo "Could not locate $SOFILE"
echo "Failed to fully install PHP version $VERSION"
exit 1
fi

echo "Restarting Apache..."
sudo service apache2 restart
EOT
  chmod +x "/usr/local/bin/php-switch"
  echo -e "\n[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc" >> ~vagrant/.bash_profile
fi
