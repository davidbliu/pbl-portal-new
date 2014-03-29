FROM ubuntu:13.04
MAINTAINER Docker Education Team <education@docker.com>

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ruby rubygems ruby-dev libpq-dev
RUN gem install sinatra bundler --no-ri --no-rdoc

ADD . /opt/dockernotes

WORKDIR /opt/dockernotes
RUN bundle install

EXPOSE 3000
CMD bundle exec rails s
