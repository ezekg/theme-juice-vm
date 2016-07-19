#!/bin/bash

if [[ ! -f "/usr/local/bin/xo" ]]; then
  echo "Installing xo (https://github.com/ezekg/xo)"
  curl -L -O https://github.com/ezekg/xo/releases/download/0.2.2/xo_0.2.2_linux_amd64.tar.gz
  tar -xvzf xo_0.2.2_linux_amd64.tar.gz
  rm xo_0.2.2_linux_amd64.tar.gz
  chmod +x xo_0.2.2_linux_amd64/xo
  mv xo_0.2.2_linux_amd64/xo /usr/local/bin/
  rm -rf xo_0.2.2_linux_amd64&
fi
