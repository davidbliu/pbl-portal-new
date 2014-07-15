FROM ubuntu:14.04
MAINTAINER David Liu <davidbliu@gmail.com>

RUN apt-get update
RUN apt-get install -y ruby ruby-dev libpq-dev build-essential
RUN gem install sinatra bundler --no-ri --no-rdoc
RUN apt-get -y install git

RUN apt-get -y install libmysqlclient-dev

ADD . /opt/dockernotes

WORKDIR /opt/dockernotes
RUN bundle install

EXPOSE 3000
CMD bundle exec rails s
