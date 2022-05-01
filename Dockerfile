# Dockerfile

FROM ruby:2.7.4

# install dependencies
WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

# copy source
COPY . /app

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]