#!/bin/bash

# Add the vagrant user to the www-data group so that it has better access
# to PHP and Apache related files
usermod -a -G www-data vagrant
chown -R vagrant:www-data /tmp
sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
chown -R vagrant:www-data /var/lock/apache2/
chown -R vagrant:www-data /var/lib/apache2/

# Make sure the services we expect to be running are running.
echo -e "\nRestart services..."
a2enmod headers && service apache2 restart
service memcached restart
service mailcatcher restart

# Disable PHP Xdebug module by default
php5dismod xdebug

# Enable PHP mcrypt module by default
php5enmod mcrypt

# Enable PHP mailcatcher sendmail settings by default
php5enmod mailcatcher
