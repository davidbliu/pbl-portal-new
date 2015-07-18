export DEBIAN_FRONTEND=noninteractive

sudo apt-get -y update
#RUN apt-get -y upgrade


sudo apt-get install -y ruby ruby-dev libpq-dev build-essential
sudo gem install sinatra bundler --no-ri --no-rdoc
sudo apt-get -y install git

sudo apt-get -y install libmysqlclient-dev


sudo apt-get -y install libxslt-dev libxml2-dev

git clone https://github.com/davidbliu/pbl-portal-new.git

cd pbl-portal-new

bundle install

# clone dumps
git clone https://github.com/davidbliu/dumps

sudo apt-get install postgresql postgresql-contrib
# see pbl.link/postgres-setup for further user postgres-setup. you will need to setup a postgres user with a password and change config/database.yml file for the portal to reflect that

# install elasticsearch pbl.link/elasticsearch-install
# sudo add-apt-repository ppa:webupd8team/java
# sudo apt-get update
# sudo apt-get install oracle-java7-installer

wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.7.tar.gz
tar -xf elasticsearch-0.90.7.tar.gz