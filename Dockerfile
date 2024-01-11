FROM ruby:3.0.0

RUN apt-get update -qq && apt-get install -y postgresql-client
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs git vim
WORKDIR /web
COPY Gemfile* /web/
RUN bundle install
