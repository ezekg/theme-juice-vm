#!/bin/bash

# npm
#
# Make sure we have the latest npm version and the update checker module
sudo -i -u vagrant npm install -g npm
sudo -i -u vagrant npm install -g npm-check-updates

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

# Composer
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
# Install or update Grunt based on current state.
if [[ "$(grunt --version)" ]]; then
  echo "Updating Grunt CLI..."
  sudo -i -u vagrant npm update -g grunt-cli &>/dev/null
else
  echo "Installing Grunt CLI..."
  sudo -i -u vagrant npm install -g grunt-cli &>/dev/null
fi

# Bower
#
# Install or update Bower based on current state.
if [[ "$(bower --version)" ]]; then
  echo "Updating Bower..."
  sudo -i -u vagrant npm update -g bower &>/dev/null
else
  echo "Installing Bower..."
  sudo -i -u vagrant npm install -g bower &>/dev/null
fi

# Sympm
#
# Install or update Sympm based on current state.
if [[ "$(sympm --version)" ]]; then
  echo "Updating Sympm..."
  sudo -i -u vagrant npm update -g sympm &>/dev/null
else
  echo "Installing Sympm..."
  sudo -i -u vagrant npm install -g sympm &>/dev/null
fi

# Graphviz
#
# Set up a symlink between the Graphviz path defined in the default Webgrind
# config and actual path.
echo "Adding graphviz symlink for Webgrind..."
ln -sf "/usr/bin/dot" "/usr/local/bin/dot"
