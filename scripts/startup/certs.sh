#!/bin/bash

echo "Adding self-signed SSL certs"
sites=$(cat /etc/apache2/custom-sites/*.conf | xo '/\*:443.*?ServerName\s(www)?\.?([-.0-9A-Za-z]+)/$1?:www.$2/mis')

# Install a cert for each domain
for site in $sites; do
  if [[ $site =~ "localhost" ]] || [[ ! $site =~ ".dev" ]]; then
    continue
  fi

  domain=$(echo "$site" | sed "s/^www.//")

  if [[ -f "/etc/ssl/certs/$domain.pem" ]]; then
    echo " * Cert for $domain already exists"
    continue
  fi

  openssl genrsa -des3 -passout pass:x -out "$domain.pass.key" 2048 &>/dev/null
  openssl rsa -passin pass:x -in "$domain.pass.key" -out "$domain.key" &>/dev/null
  rm "$domain.pass.key"
  openssl req -new -key "$domain.key" -out "$domain.csr" -subj "/C=US/ST=New York/L=New York City/O=Evil Corp/OU=IT Department/CN=$domain" &>/dev/null
  openssl x509 -req -days 365 -in "$domain.csr" -signkey "$domain.key" -out "$domain.pem" &>/dev/null

  mv "$domain.key" /etc/ssl/private/
  mv "$domain.pem" /etc/ssl/certs/
  rm "$domain.csr"

  echo " * Created cert for $domain"
done
