#!/bin/bash

set -e # Any commands which fail will cause the shell script to exit immediately
set -x # show command being executed

# We mainly follow instructions from https://gorails.com/deploy/ubuntu/20.04 but use `ubuntu` user (instead of `deploy` user)
# Install node, yarn, git, redis
# Adding Node.js repository
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
# Adding Yarn repository
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo add-apt-repository -y ppa:chris-lea/redis-server
# Refresh our packages list with the new repositories
sudo apt update
# Install our dependencies for compiiling Ruby along with Node.js and Yarn
sudo apt -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev dirmngr gnupg apt-transport-https ca-certificates redis-server redis-tools nodejs yarn vim monit binutils

# Install rbenv Install rbenv and plugins https://github.com/rbenv/rbenv
# https://github.com/rbenv/ruby-build https://github.com/rbenv/rbenv-installer
git clone https://github.com/rbenv/rbenv.git ~/.rbenv || true
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build || true
git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars || true

if [[ $(grep -L rbenv ~/.bashrc) ]]; then
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
eval "$(rbenv init -)"
yes N | rbenv install 2.6.3 || true
rbenv global 2.6.3
ruby -v
gem install bundler
bundle -v

# Database
# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-neo4j-on-ubuntu-20-04
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://debian.neo4j.com stable 4.1"
sudo apt install -y neo4j
sudo systemctl enable neo4j.service
sudo systemctl status neo4j.service
