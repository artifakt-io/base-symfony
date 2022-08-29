FROM php:8.1-apache

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  libzip-dev \
  wget \
  zip \
  zlib1g-dev

RUN docker-php-ext-configure zip && docker-php-ext-install zip

ENV APP_DEBUG=0
ENV APP_ENV=prod

ARG ARTIFAKT_COMPOSER_VERSION=2.3.7
ARG CODE_ROOT=.

RUN curl -sS https://getcomposer.org/installer | \
    php -- --version=${ARTIFAKT_COMPOSER_VERSION} --install-dir=/usr/local/bin --filename=composer


COPY --chown=www-data:www-data $CODE_ROOT /var/www/html/

WORKDIR /var/www/html/

USER www-data
RUN [ -f composer.lock ] && composer install --no-cache --optimize-autoloader --no-interaction --no-ansi --no-dev || true
USER root

# copy the artifakt folder on root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN  if [ -d .artifakt ]; then cp -rp /var/www/html/.artifakt /.artifakt/; fi

# run custom scripts build.sh
# hadolint ignore=SC1091
RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
    if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
    if [ -f /.artifakt/build.sh ]; then /.artifakt/build.sh; fi

USER www-data
RUN php bin/console cache:clear --no-warmup
RUN php bin/console cache:warmup
USER root

