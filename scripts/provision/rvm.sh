#!/bin/bash

# Installs RVM. RVM allows us to install the current version of Ruby.
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
  curl --silent -L "https://get.rvm.io" | bash -s stable --ruby
  source "/usr/local/rvm/scripts/rvm"
fi

# Install bundler gem
gem install bundler
