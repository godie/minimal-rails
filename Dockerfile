ARG RUBY_VERSION=3.2.1-alpine
FROM ruby:$RUBY_VERSION AS builder

ARG BUNDLER_VERSION
ARG RAILS_ENV=production

ENV RAILS_ENV=$RAILS_ENV
# RAILS_LOG_TO_STDOUT=true \
# RAILS_SERVE_STATIC_FILES=true

RUN apk -U upgrade && apk add --no-cache \
      build-base tzdata libc6-compat

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

ENV LANG=C.UTF-8 \
   BUNDLE_JOBS=4 \
   BUNDLE_RETRY=3 \
   BUNDLE_PATH='vendor/bundle'

RUN gem install bundler:${BUNDLER_VERSION} --no-document \
   && bundle config set --without 'development test' 
RUN bundle install --quiet --without development test 

COPY . .

RUN rm -rf tmp/cache tmp/miniprofiler tmp/sockets


###########################################################################
ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}

ENV RAILS_ENV=$RAILS_ENV

RUN apk -U upgrade && apk add --no-cache libpq tzdata netcat-openbsd libc6-compat \
   && rm -rf /var/cache/apk/*

# -disabled-password doesn't assign a password, so cannot login
RUN adduser --disabled-password app-user
USER app-user

COPY --from=builder --chown=app-user /app /app

ENV RAILS_ENV=${RAILS_ENV:-production} \
   RAILS_LOG_TO_STDOUT=true \
   RAILS_SERVE_STATIC_FILES=true  \
   BUNDLE_PATH='vendor/bundle' 

ENV SECRET_KEY_BASE=getfromthesecretmanagerinthefuture

WORKDIR /app

RUN bundle install --without development test --quiet
RUN rm -rf tmp/cache tmp/miniprofiler tmp/sockets

COPY . .

# Add a script to be executed every time the container starts.
USER root
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["bundle","exec","rails","s", "-p","3000","-b","0.0.0.0"]
