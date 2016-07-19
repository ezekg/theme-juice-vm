#!/bin/bash

if [[ "$(nvm --version)" ]]; then
  echo "Updating NVM"
else
  echo "Installing NVM from source"
  echo -e "\n[[ -e ~/.nvm/nvm.sh ]] && source ~/.nvm/nvm.sh" >> ~vagrant/.bash_profile
fi

# Installing and updating are handled within the install script
curl -L -O https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh
sudo -i -u vagrant bash install.sh
rm install.sh

source "~vagrant/.nvm/nvm.sh"

# Install Node stable
echo "Installing Node stable"
sudo -i -u vagrant nvm install node
sudo -i -u vagrant nvm alias default node
