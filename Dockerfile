# Dockerfile

FROM ruby:2.7.4

# install dependencies
WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

# copy source
COPY . /app

ENV PORT 4567

EXPOSE $PORT

CMD exec rackup --host 0.0.0.0 -p $PORT