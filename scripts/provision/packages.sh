#!/bin/bash

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

  # Our base packages for php5
  php5
  php5-cli

  # Common and dev packages for php
  php5-common
  php5-dev

  # Extra PHP modules that we find useful
  php5-memcache
  php5-imagick
  php5-xdebug
  php5-mcrypt
  php5-mysql
  php5-imap
  php5-curl
  php-pear
  php5-gd
  php-apc
  php5-cgi

  # Dependencies for building PHP versions with phpbrew
  autoconf
  automake
  libcurl3-openssl-dev
  build-essential
  libxslt1-dev
  re2c
  libxml2
  libxml2-dev
  bison
  libbz2-dev
  libreadline-dev
  libfreetype6
  libfreetype6-dev
  libpng12-0
  libpng12-dev
  libjpeg-dev
  libjpeg8-dev
  libjpeg8
  libgd-dev
  libgd3
  libxpm4
  libltdl7
  libltdl-dev
  libssl-dev
  openssl
  libgettextpo-dev
  libgettextpo0
  libicu-dev
  libmhash-dev
  libmhash2
  libmcrypt-dev
  libmcrypt4
  libmagickwand-dev
  libmagickcore-dev

  # Apache is installed as the default web server
	apache2-mpm-prefork
  apache2-dev
	libapache2-mod-fastcgi
  libapache2-mod-php5

  # Memcached is made available for object caching
  memcached

  # MySQL is the default database
  mysql-server
  mysql-client
  libmysqlclient-dev
  libmysqld-dev

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

  # Mailcatcher dependency
  libsqlite3-dev
)

# Loop through each of our packages that should be installed on the system. If
# not yet installed, it should be added to the array of packages to install.
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
# up as an 'Internet Site' with the host name 'graft'. Note that if your current
# Internet connection does not allow communication over port 25, you will not be
# able to send mail, even with postfix installed.
echo postfix postfix/main_mailer_type select Internet Site | debconf-set-selections
echo postfix postfix/mailname string graft | debconf-set-selections

# Disable ipv6 as some ISPs/mail servers have problems with it
echo "inet_protocols = ipv4" >> "/etc/postfix/main.cf"

# Provide our custom apt sources before running `apt-get update`
ln -sf /srv/config/apt-sources.list /etc/apt/sources.list.d/graft-sources.list
echo "Linked custom apt sources"

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
