FROM registry.artifakt.io/symfony:4.4-apache

COPY --chown=www-data:www-data . /var/www/html/

COPY /.artifakt/000-default.conf /etc/apache2/sites-enabled/000-default.conf 

# copy the artifakt folder on root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN  if [ -d .artifakt ]; then cp -rp /var/www/html/.artifakt /.artifakt/; fi

ENV APP_DEBUG=0
ENV APP_ENV=prod

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

# FAILSAFE LOG FOLDER
RUN mkdir -p /var/log/artifakt && chown www-data:www-data /var/log/artifakt

RUN chown -R www-data:www-data /var/www/html

# PERSISTENT DATA FOLDERS
RUN rm -rf /var/www/html/var/uploads && \
    mkdir -p /data/uploads && \
    ln -s /data/uploads /var/www/html/var/uploads && \
    chown -R www-data:www-data /data/uploads

RUN rm -rf /var/www/html/var/cache && \
    mkdir -p /data/cache && \
    ln -s /data/cache /var/www/html/var/cache && \
    chown -R www-data:www-data /data/cache

RUN mkdir -p /var/www/html/var/log && chown -R www-data:www-data /var/www/html/var/log

# run custom scripts build.sh
# hadolint ignore=SC1091
#RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
#    if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
#    if [ -f /.artifakt/build.sh ]; then /.artifakt/build.sh; fi

COPY /.artifakt/parameters.yml config/
USER www-data
RUN [ -f composer.lock ] && composer install --no-ansi || true
RUN php bin/console cache:clear --no-warmup
RUN php bin/console cache:warmup
USER root