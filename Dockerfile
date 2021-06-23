FROM registry.artifakt.io/symfony:4.4-apache

ENV APP_DEBUG=0
ENV APP_ENV=prod

# Copy sources
COPY --chown=www-data:www-data . /var/www/html/

# Copy the artifakt folder on root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN  if [ -d .artifakt ]; then cp -rp .artifakt /.artifakt/; fi

# Copy the default vhost configuration for apache
COPY .artifakt/000-default.conf /etc/apache2/sites-enabled/000-default.conf 

# Create the parameter.yml file if it doesn't exist
RUN if [[ ! -f "config/parameters.yml" ]]; then cp .artifakt/parameters.yml config/; fi

# Get the last version of composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

# Rm folders
RUN rm -rf var/uploads

# MKDIR COMMANDS: FAILSAFE LOG FOLDER, UPLOADS, CACHE, SYMFONY VAR LOG
RUN mkdir -p /var/log/artifakt /data/uploads var/cache var/log /var/www/.composer

# CHOWN COMMANDS
RUN chown -R www-data:www-data /var/log/artifakt /var/www/html /var/www/.composer /data/uploads

# run custom scripts build.sh
# hadolint ignore=SC1091
#RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
#    if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
#    if [ -f /.artifakt/build.sh ]; then /.artifakt/build.sh; fi

USER www-data
RUN [ -f composer.lock ] && composer install --no-ansi || true
RUN php bin/console cache:clear --no-warmup
RUN php bin/console cache:warmup
USER root