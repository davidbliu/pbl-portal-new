# to use this script you need to have xcode installed
# run this script by placing it in some directory
# final directory structure will look like
# ./mac_installer.sh
# ./pbl-portal-new
# this script will:
# install ruby, rails, gems for the portal
# you will still need to: 
# create setenv.sh
# edit config/database.yml
# install postgres.app
# install elasticsearch

#!/bin/bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

curl -L get.rvm.io | bash
source ~/.rvm/scripts/rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

rvm get head
rvm requirements
rvm install 2.0.0
rvm use 2.0.0
rvm default 2.0.0

gem install rails

brew install mysql
brew install postgresql
gem install eventmachine -v '1.0.4'

brew install v8
gem install therubyracer
gem install libv8 -v '3.16.14.3' -- --with-system-v8 

brew update
brew install git

cd
git init
git clone https://github.com/davidbliu/pbl-portal-new.git
