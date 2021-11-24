FROM ruby:3.0-buster

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle check || bundle install

COPY . .
