FROM registry.artifakt.io/symfony:4.4-apache

COPY --chown=www-data:www-data . /var/www/html/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# copy the artifakt folder on root
RUN  if [ -d .artifakt ]; then cp -rp /var/www/html/.artifakt /.artifakt/; fi

ENV APP_DEBUG=0
ENV APP_ENV=prod

RUN [ -f composer.lock ] && composer install --no-cache --optimize-autoloader --no-interaction --no-ansi --no-dev || true

# FAILSAFE LOG FOLDER
RUN mkdir -p /var/log/artifakt && chown www-data:www-data /var/log/artifakt

# PERSISTENT DATA FOLDERS
RUN rm -rf /var/www/html/var/uploads && \
    mkdir -p /data/uploads && \
    ln -s /data/uploads /var/www/html/var/uploads && \
    chown -R www-data:www-data /data/uploads

# run custom scripts build.sh
# hadolint ignore=SC1091
#RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
RUN    if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
    if [ -f /.artifakt/build.sh ]; then /.artifakt/build.sh; fi

USER www-data
RUN php bin/console cache:clear --no-warmup
RUN php bin/console --verbose cache:warmup
USER root