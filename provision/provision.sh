#!/bin/bash
#
# provision.sh
#
# This file is specified in Vagrantfile and is loaded by Vagrant as the primary
# provisioning script whenever the commands `vagrant up`, `vagrant provision`,
# or `vagrant reload` are used. It provides all of the default packages and
# configurations included with Varying Vagrant Vagrants.

# By storing the date now, we can calculate the duration of provisioning at the
# end of this script.
start_seconds="$(date +%s)"

# PACKAGE INSTALLATION
#
# Build a bash array to pass all of the packages we want to install to a single
# apt-get command. This avoids doing all the leg work each time a package is
# set to install. It also allows us to easily comment out or add single
# packages. We set the array as empty to begin with so that we can append
# individual packages to it as required.
apt_package_install_list=()

# Start with a bash array containing all packages we want to install in the
# virtual machine. We'll then loop through each of these and check individual
# status before adding them to the apt_package_install_list array.
apt_package_check_list=(

  # PHP5
  #
  # Our base packages for php5.
  php5

  # Common and dev packages for php
  php5-common
  php5-dev

  # Extra PHP modules that we find useful
  php5-memcache
  php5-imagick
  php5-mcrypt
  php5-mysql
  php5-imap
  php5-curl
  php-pear
  php5-gd

  # Apache is installed as the default web server
	apache2-mpm-worker
	libapache2-mod-fastcgi

  # Memcached is made available for object caching
  memcached

  # MySQL is the default database
  mysql-server

  # Other packages that come in handy
  imagemagick
  subversion
  git-core
  zip
  unzip
  ngrep
  curl
  make
  vim
  colordiff
  postfix

  # NTP service to keep clock current
  ntp

  # Req'd for i18n tools
  gettext

  # Req'd for Webgrind
  graphviz

  # Dos2unix
  # Allows conversion of DOS style line endings to something we'll have less
  # trouble with in Linux.
  dos2unix

  # Nodejs for use by grunt
  g++
  nodejs

  # Mailcatcher dependency
  libsqlite3-dev
)

### FUNCTIONS

network_detection() {
  # Network Detection
  #
  # Make an HTTP request to google.com to determine if outside access is available
  # to us. If 3 attempts with a timeout of 5 seconds are not successful, then we'll
  # skip a few things further in provisioning rather than create a bunch of errors.
  if [[ "$(wget --tries=3 --timeout=5 --spider http://google.com 2>&1 | grep 'connected')" ]]; then
    echo "Network connection detected..."
    ping_result="Connected"
  else
    echo "Network connection not detected. Unable to reach google.com..."
    ping_result="Not Connected"
  fi
}

network_check() {
  network_detection
  if [[ ! "$ping_result" == "Connected" ]]; then
    echo -e "\nNo network connection available, skipping package installation"
    exit 0
  fi
}

noroot() {
  sudo -EH -u "vagrant" "$@";
}

profile_setup() {
  # Copy custom dotfiles and bin file for the vagrant user from local
  sudo rsync -rvzh "/srv/config/bash_profile" "/home/vagrant/.bash_profile"
  sudo rsync -rvzh "/srv/config/bash_aliases" "/home/vagrant/.bash_aliases"
  sudo rsync -rvzh "/srv/config/vimrc" "/home/vagrant/.vimrc"

  if [[ ! -d "/home/vagrant/.subversion" ]]; then
    mkdir "/home/vagrant/.subversion"
  fi

  sudo rsync -rvzh "/srv/config/subversion-servers" "/home/vagrant/.subversion/servers"

  if [[ ! -d "/home/vagrant/bin" ]]; then
    mkdir "/home/vagrant/bin"
  fi

  sudo rsync -rvzh --delete "/srv/config/homebin/" "/home/vagrant/bin/"
  sudo chmod +x /home/vagrant/bin/*

  echo " * /srv/config/bash_profile                        -> /home/vagrant/.bash_profile"
  echo " * /srv/config/bash_aliases                        -> /home/vagrant/.bash_aliases"
  echo " * /srv/config/vimrc                               -> /home/vagrant/.vimrc"
  echo " * /srv/config/subversion-servers                  -> /home/vagrant/.subversion/servers"
  echo " * /srv/config/homebin                             -> /home/vagrant/bin"

  # If a bash_prompt file exists in the VVV config/ directory, copy to the VM.
  if [[ -f "/srv/config/bash_prompt" ]]; then
    sudo rsync -rvzh "/srv/config/bash_prompt" "/home/vagrant/.bash_prompt"
    echo " * /srv/config/bash_prompt                          -> /home/vagrant/.bash_prompt"
  fi
}

package_check() {
  # Loop through each of our packages that should be installed on the system. If
  # not yet installed, it should be added to the array of packages to install.
  local pkg
  local package_version

  for pkg in "${apt_package_check_list[@]}"; do
    package_version=$(dpkg -s "${pkg}" 2>&1 | grep 'Version:' | cut -d " " -f 2)
    if [[ -n "${package_version}" ]]; then
      space_count="$(expr 20 - "${#pkg}")" #11
      pack_space_count="$(expr 30 - "${#package_version}")"
      real_space="$(expr ${space_count} + ${pack_space_count} + ${#package_version})"
      printf " * $pkg %${real_space}.${#package_version}s ${package_version}\n"
    else
      echo " *" $pkg [not installed]
      apt_package_install_list+=($pkg)
    fi
  done
}

package_install() {
  package_check

  # MySQL
  #
  # Use debconf-set-selections to specify the default password for the root MySQL
  # account. This runs on every provision, even if MySQL has been installed. If
  # MySQL is already installed, it will not affect anything.
  echo mysql-server mysql-server/root_password password "root" | debconf-set-selections
  echo mysql-server mysql-server/root_password_again password "root" | debconf-set-selections

  # Postfix
  #
  # Use debconf-set-selections to specify the selections in the postfix setup. Set
  # up as an 'Internet Site' with the host name 'vvv'. Note that if your current
  # Internet connection does not allow communication over port 25, you will not be
  # able to send mail, even with postfix installed.
  echo postfix postfix/main_mailer_type select Internet Site | debconf-set-selections
  echo postfix postfix/mailname string vvv | debconf-set-selections

  # Disable ipv6 as some ISPs/mail servers have problems with it
  echo "inet_protocols = ipv4" >> "/etc/postfix/main.cf"

  if [[ ${#apt_package_install_list[@]} = 0 ]]; then
    echo -e "No apt packages to install.\n"
  else
    # Update all of the package references before installing anything
    echo "Running apt-get update..."
    apt-get update -y

    # Install required packages
    echo "Installing apt-get packages..."
    apt-get install -y ${apt_package_install_list[@]}

    # Clean up apt caches
    apt-get clean
  fi
}

tools_install() {
  # npm
  #
  # Make sure we have the latest npm version and the update checker module
  npm install -g npm
  npm install -g npm-check-updates

  # xdebug
  #
  # XDebug 2.2.3 is provided with the Ubuntu install by default. The PECL
  # installation allows us to use a later version. Not specifying a version
  # will load the latest stable.
  pecl install xdebug

  # ack-grep
  #
  # Install ack-rep directory from the version hosted at beyondgrep.com as the
  # PPAs for Ubuntu Precise are not available yet.
  if [[ -f /usr/bin/ack ]]; then
    echo "ack-grep already installed"
  else
    echo "Installing ack-grep as ack"
    curl -s http://beyondgrep.com/ack-2.14-single-file > "/usr/bin/ack" && chmod +x "/usr/bin/ack"
  fi

  # COMPOSER
  #
  # Install Composer if it is not yet available.
  if [[ ! -n "$(composer --version --no-ansi | grep 'Composer version')" ]]; then
    echo "Installing Composer..."
    curl -sS "https://getcomposer.org/installer" | php
    chmod +x "composer.phar"
    mv "composer.phar" "/usr/local/bin/composer"
  fi

  if [[ -f /vagrant/provision/github.token ]]; then
    ghtoken=`cat /vagrant/provision/github.token`
    composer config --global github-oauth.github.com $ghtoken
    echo "Your personal GitHub token is set for Composer."
  fi

  # Update both Composer and any global packages. Updates to Composer are direct from
  # the master branch on its GitHub repository.
  if [[ -n "$(composer --version --no-ansi | grep 'Composer version')" ]]; then
    echo "Updating Composer..."
    COMPOSER_HOME=/usr/local/src/composer composer self-update
    COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update phpunit/phpunit:4.8.*
    COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update phpunit/php-invoker:1.1.*
    COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update mockery/mockery:0.9.*
    COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update d11wtq/boris:v1.0.8
    COMPOSER_HOME=/usr/local/src/composer composer -q global config bin-dir /usr/local/bin
    COMPOSER_HOME=/usr/local/src/composer composer global update
  fi

  # Grunt
  #
  # Install or Update Grunt based on current state.  Updates are direct
  # from NPM
  if [[ "$(grunt --version)" ]]; then
    echo "Updating Grunt CLI"
    npm update -g grunt-cli &>/dev/null
    npm update -g grunt-sass &>/dev/null
    npm update -g grunt-cssjanus &>/dev/null
    npm update -g grunt-rtlcss &>/dev/null
  else
    echo "Installing Grunt CLI"
    npm install -g grunt-cli &>/dev/null
    npm install -g grunt-sass &>/dev/null
    npm install -g grunt-cssjanus &>/dev/null
    npm install -g grunt-rtlcss &>/dev/null
  fi

  # Graphviz
  #
  # Set up a symlink between the Graphviz path defined in the default Webgrind
  # config and actual path.
  echo "Adding graphviz symlink for Webgrind..."
  ln -sf "/usr/bin/dot" "/usr/local/bin/dot"
}

apache_setup() {
  # Used to to ensure proper services are started on `vagrant up`
  sudo rsync -rvzh /srv/config/init/vvv-start.conf /etc/init/vvv-start.conf

  echo " * /srv/config/init/vvv-start.conf                -> /etc/init/vvv-start.conf"

  # Copy Apache configuration from local
  sudo rsync -rvzh "/srv/config/apache-config/apache2.conf" "/etc/apache2/apache2.conf"
  sudo rsync -rvzh "/srv/config/apache-config/httpd.conf" "/etc/apache2/httpd.conf"
  sudo rsync -rvzh "/srv/config/apache-config/php5-fpm.conf" "/etc/apache2/conf.d/php5-fpm.conf"
  sudo rsync -rvzh --delete "/srv/config/apache-config/sites/" "/etc/apache2/custom-sites/"

  echo " * /srv/config/apache-config/apache2.conf         -> /etc/apache2/apache2.conf"
  echo " * /srv/config/apache-config/httpd.conf           -> /etc/apache2/httpd.conf"
  echo " * /srv/config/apache-config/php-fpm.conf         -> /etc/apache2/conf.d/php-fpm.conf"
  echo " * /srv/config/apache-config/sites/               -> /etc/apache2/custom-sites/"

  # Configure Apache for PHP-FPM
  a2enmod actions fastcgi alias

  # Enable mod_rewrite
  a2enmod rewrite
}

phpfpm_setup() {
  sudo mkdir -p "/etc/php5/fpm/pool.d" "/etc/php5/fpm/conf.d/"

  # Copy php-fpm configuration from local
  sudo rsync -rvzh "/srv/config/php5-fpm-config/php5-fpm.conf" "/etc/php5/fpm/php5-fpm.conf"
  sudo rsync -rvzh "/srv/config/php5-fpm-config/www.conf" "/etc/php5/fpm/pool.d/www.conf"
  sudo rsync -rvzh "/srv/config/php5-fpm-config/php-custom.ini" "/etc/php5/fpm/conf.d/php-custom.ini"
  sudo rsync -rvzh "/srv/config/php5-fpm-config/opcache.ini" "/etc/php5/fpm/conf.d/opcache.ini"
  sudo rsync -rvzh "/srv/config/php5-fpm-config/xdebug.ini" "/etc/php5/mods-available/xdebug.ini"

  # Find the path to Xdebug and prepend it to xdebug.ini
  XDEBUG_PATH=$( find /usr -name 'xdebug.so' | head -1 )
  sed -i "1izend_extension=\"$XDEBUG_PATH\"" "/etc/php5/mods-available/xdebug.ini"

  echo " * /srv/config/php5-fpm-config/php5-fpm.conf       -> /etc/php5/fpm/php5-fpm.conf"
  echo " * /srv/config/php5-fpm-config/www.conf            -> /etc/php5/fpm/pool.d/www.conf"
  echo " * /srv/config/php5-fpm-config/php-custom.ini      -> /etc/php5/fpm/conf.d/php-custom.ini"
  echo " * /srv/config/php5-fpm-config/opcache.ini         -> /etc/php5/fpm/conf.d/opcache.ini"
  echo " * /srv/config/php5-fpm-config/xdebug.ini          -> /etc/php5/mods-available/xdebug.ini"

  # Copy memcached configuration from local
  sudo rsync -rvzh "/srv/config/memcached-config/memcached.conf" "/etc/memcached.conf"

  echo " * /srv/config/memcached-config/memcached.conf     -> /etc/memcached.conf"
}

mysql_setup() {
  # If MySQL is installed, go through the various imports and service tasks.
  local exists_mysql

  exists_mysql="$(service mysql status)"
  if [[ "mysql: unrecognized service" != "${exists_mysql}" ]]; then
    echo -e "\nSetup MySQL configuration file links..."

    # Copy mysql configuration from local
    sudo rsync -rvzh "/srv/config/mysql-config/my.cnf" "/etc/mysql/my.cnf"
    sudo rsync -rvzh "/srv/config/mysql-config/root-my.cnf" "/home/vagrant/.my.cnf"

    echo " * /srv/config/mysql-config/my.cnf                 -> /etc/mysql/my.cnf"
    echo " * /srv/config/mysql-config/root-my.cnf            -> /home/vagrant/.my.cnf"

    # MySQL gives us an error if we restart a non running service, which
    # happens after a `vagrant halt`. Check to see if it's running before
    # deciding whether to start or restart.
    if [[ "mysql stop/waiting" == "${exists_mysql}" ]]; then
      echo "service mysql start"
      service mysql start
      else
      echo "service mysql restart"
      service mysql restart
    fi

    # IMPORT SQL
    #
    # Create the databases (unique to system) that will be imported with
    # the mysqldump files located in database/backups/
    if [[ -f "/srv/database/init-custom.sql" ]]; then
      mysql -u "root" -p"root" < "/srv/database/init-custom.sql"
      echo -e "\nInitial custom MySQL scripting..."
    else
      echo -e "\nNo custom MySQL scripting found in database/init-custom.sql, skipping..."
    fi

    # Setup MySQL by importing an init file that creates necessary
    # users and databases that our vagrant setup relies on.
    mysql -u "root" -p"root" < "/srv/database/init.sql"
    echo "Initial MySQL prep..."

    # Process each mysqldump SQL file in database/backups to import
    # an initial data set for MySQL.
    "/srv/database/import-sql.sh"
  else
    echo -e "\nMySQL is not installed. No databases imported."
  fi
}

mailcatcher_setup() {
  # Mailcatcher
  #
  # Installs mailcatcher using RVM. RVM allows us to install the
  # current version of ruby and all mailcatcher dependencies reliably.
  local pkg

  rvm_version="$(/usr/bin/env rvm --silent --version 2>&1 | grep 'rvm ' | cut -d " " -f 2)"
  if [[ -n "${rvm_version}" ]]; then
    pkg="RVM"
    space_count="$(( 20 - ${#pkg}))" #11
    pack_space_count="$(( 30 - ${#rvm_version}))"
    real_space="$(( ${space_count} + ${pack_space_count} + ${#rvm_version}))"
    printf " * $pkg %${real_space}.${#rvm_version}s ${rvm_version}\n"
  else
    # RVM key D39DC0E3
    # Signatures introduced in 1.26.0
    gpg -q --no-tty --batch --keyserver "hkp://keyserver.ubuntu.com:80" --recv-keys D39DC0E3
    gpg -q --no-tty --batch --keyserver "hkp://keyserver.ubuntu.com:80" --recv-keys BF04FF17

    printf " * RVM [not installed]\n Installing from source"
    curl --silent -L "https://get.rvm.io" | sudo bash -s stable --ruby
    source "/usr/local/rvm/scripts/rvm"
  fi

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
    sudo rsync -rvzh "/srv/config/init/mailcatcher.conf"  "/etc/init/mailcatcher.conf"
    echo " * /srv/config/init/mailcatcher.conf               -> /etc/init/mailcatcher.conf"
  fi

  if [[ -f "/etc/php5/mods-available/mailcatcher.ini" ]]; then
    echo " * Mailcatcher php5 fpm already configured."
  else
    sudo rsync -rvzh "/srv/config/php5-fpm-config/mailcatcher.ini" "/etc/php5/mods-available/mailcatcher.ini"
    echo " * /srv/config/php5-fpm-config/mailcatcher.ini     -> /etc/php5/mods-available/mailcatcher.ini"
  fi
}

services_restart() {
  # RESTART SERVICES
  #
  # Make sure the services we expect to be running are running.
  echo -e "\nRestart services..."
  sudo a2enmod headers && sudo service apache2 restart
  service memcached restart
  service mailcatcher restart

  # Disable PHP Xdebug module by default
  php5dismod xdebug

  # Enable PHP mcrypt module by default
  php5enmod mcrypt

  # Enable PHP mailcatcher sendmail settings by default
  php5enmod mailcatcher

  service php5-fpm restart

  # Add the vagrant user to the www-data group so that it has better access
  # to PHP and Apache related files
  sudo usermod -a -G www-data vagrant
}

wp_cli() {
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
}

memcached_admin() {
  # Download and extract phpMemcachedAdmin to provide a dashboard view and
  # admin interface to the goings on of memcached when running
  if [[ ! -d "/srv/www/default/memcached-admin" ]]; then
    echo -e "\nDownloading phpMemcachedAdmin, see https://github.com/wp-cloud/phpmemcacheadmin"
    cd /srv/www/default
    wget -q -O phpmemcachedadmin.tar.gz "https://github.com/wp-cloud/phpmemcacheadmin/archive/1.2.2.1.tar.gz"
    tar -xf phpmemcachedadmin.tar.gz
    mv phpmemcacheadmin* memcached-admin
    rm phpmemcachedadmin.tar.gz
  else
    echo "phpMemcachedAdmin already installed."
  fi
}

opcached_status(){
  # Checkout Opcache Status to provide a dashboard for viewing statistics
  # about PHP's built in opcache.
  if [[ ! -d "/srv/www/default/opcache-status" ]]; then
    echo -e "\nDownloading Opcache Status, see https://github.com/rlerdorf/opcache-status/"
    cd /srv/www/default
    git clone "https://github.com/rlerdorf/opcache-status.git" opcache-status
  else
    echo -e "\nUpdating Opcache Status"
    cd /srv/www/default/opcache-status
    git pull --rebase origin master
  fi
}

webgrind_install() {
  # Webgrind install (for viewing callgrind/cachegrind files produced by
  # xdebug profiler)
  if [[ ! -d "/srv/www/default/webgrind" ]]; then
    echo -e "\nDownloading webgrind, see https://github.com/michaelschiller/webgrind.git"
    git clone "https://github.com/michaelschiller/webgrind.git" "/srv/www/default/webgrind"
  else
    echo -e "\nUpdating webgrind..."
    cd /srv/www/default/webgrind
    git pull --rebase origin master
  fi
}

phpmyadmin_setup() {
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
  sudo rsync -rvzh "/srv/config/phpmyadmin-config/config.inc.php" "/srv/www/default/database-admin/"
  echo " * /srv/config/phpmyadmin-config/config.inc.php    -> /srv/www/default/database-admin/"
}

custom_vvv(){
  # Find new sites to setup.
  # Kill previously symlinked Apache configs
  # We can't know what sites have been removed, so we have to remove all
  # the configs and add them back in again.
  find /etc/apache2/custom-sites -name 'vvv-auto-*.conf' -exec rm {} \;

  # Look for site setup scripts
  for SITE_CONFIG_FILE in $(find /srv/www -maxdepth 5 -name 'vvv-init.sh'); do
    DIR="$(dirname "$SITE_CONFIG_FILE")"
    (
    cd "$DIR"
    source vvv-init.sh
    )
  done

  # Look for Apache vhost files, symlink them into the custom sites dir
  for SITE_CONFIG_FILE in $(find /srv/www -maxdepth 5 -name 'vvv-apache.conf'); do
    DEST_CONFIG_FILE=${SITE_CONFIG_FILE//\/srv\/www\//}
    DEST_CONFIG_FILE=${DEST_CONFIG_FILE//\//\-}
    DEST_CONFIG_FILE=${DEST_CONFIG_FILE/%-vvv-apache.conf/}
    DEST_CONFIG_FILE="vvv-auto-$DEST_CONFIG_FILE-$(md5sum <<< "$SITE_CONFIG_FILE" | cut -c1-32).conf"
    # We allow the replacement of the {vvv_path_to_folder} token with
    # whatever you want, allowing flexible placement of the site folder
    # while still having an Apache config which works.
    DIR="$(dirname "$SITE_CONFIG_FILE")"
    sed "s#{vvv_path_to_folder}#$DIR#" "$SITE_CONFIG_FILE" > "/etc/apache2/custom-sites/""$DEST_CONFIG_FILE"
  done

  # Parse any vvv-hosts file located in www/ or subdirectories of www/
  # for domains to be added to the virtual machine's host file so that it is
  # self aware.
  #
  # Domains should be entered on new lines.
  echo "Cleaning the virtual machine's /etc/hosts file..."
  sed -n '/# vvv-auto$/!p' /etc/hosts > /tmp/hosts
  mv /tmp/hosts /etc/hosts
  echo "Adding domains to the virtual machine's /etc/hosts file..."
  find /srv/www/ -maxdepth 5 -name 'vvv-hosts' | \
  while read hostfile; do
    while IFS='' read -r line || [ -n "$line" ]; do
      if [[ "#" != ${line:0:1} ]]; then
        if [[ -z "$(grep -q "^127.0.0.1 $line$" /etc/hosts)" ]]; then
          echo "127.0.0.1 $line # vvv-auto" >> "/etc/hosts"
          echo " * Added $line from $hostfile"
        fi
      fi
    done < "$hostfile"
  done
}

### SCRIPT
#set -xv

network_check

# Profile_setup
echo "Bash profile setup and directories."
profile_setup

network_check

# Package and Tools Install
echo " "
echo "Main packages check and install."
package_install
tools_install
apache_setup
mailcatcher_setup
phpfpm_setup
services_restart
mysql_setup

network_check

# WP-CLI and debugging tools
echo " "
echo "Installing/updating wp-cli and debugging tools"

wp_cli
memcached_admin
opcached_status
webgrind_install
phpmyadmin_setup

network_check

# VVV custom site import
echo " "
echo "VVV custom site import"
custom_vvv

#set +xv
# And it's done
end_seconds="$(date +%s)"
echo "-----------------------------"
echo "Provisioning complete in "$((${end_seconds} - ${start_seconds}))" seconds"
echo "For further setup instructions, visit http://vvv.dev"
