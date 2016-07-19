#!/bin/bash

# Copy custom dotfiles and bin file for the vagrant user from local
rsync -rvzh "/srv/config/bash_profile" "/home/vagrant/.bash_profile"
rsync -rvzh "/srv/config/bash_aliases" "/home/vagrant/.bash_aliases"
rsync -rvzh "/srv/config/vimrc" "/home/vagrant/.vimrc"

if [[ ! -d "/home/vagrant/.subversion" ]]; then
  mkdir "/home/vagrant/.subversion"
fi

rsync -rvzh "/srv/config/subversion-servers" "/home/vagrant/.subversion/servers"

if [[ ! -d "/home/vagrant/bin" ]]; then
  mkdir "/home/vagrant/bin"
fi

rsync -rvzh --delete "/srv/config/homebin/" "/home/vagrant/bin/"
chmod +x /home/vagrant/bin/*

echo " * /srv/config/bash_profile -> /home/vagrant/.bash_profile"
echo " * /srv/config/bash_aliases -> /home/vagrant/.bash_aliases"
echo " * /srv/config/vimrc -> /home/vagrant/.vimrc"
echo " * /srv/config/subversion-servers -> /home/vagrant/.subversion/servers"
echo " * /srv/config/homebin -> /home/vagrant/bin"

# If a bash_prompt file exists in the graft config/ directory, copy to the VM.
if [[ -f "/srv/config/bash_prompt" ]]; then
  rsync -rvzh "/srv/config/bash_prompt" "/home/vagrant/.bash_prompt"
  echo " * /srv/config/bash_prompt -> /home/vagrant/.bash_prompt"
fi
