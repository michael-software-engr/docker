FROM ruby:2.6.0
MAINTAINER Michael (michael@localhost)

ENV APP_HOME /production
ARG BUNDLE_SECRET

# Install repository for postgres 10
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get -y install lsb-core
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list'

RUN apt-get update && apt-get install -y build-essential libpq-dev curl

RUN apt-get -y install postgresql-10

# Install Nodejs
RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash -
RUN apt-get -y install nodejs

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock $APP_HOME/
RUN gem install bundler && bundle install
