#!/bin/bash

set -e

echo ">>>>>>>>>>>>>> START CUSTOM BUILD SCRIPT <<<<<<<<<<<<<<<<< "

echo "------------------------------------------------------------"
echo "The following build args are available:"
env
echo "------------------------------------------------------------"

export APP_ENV=prod
export APP_DEBUG=0

# NO SCRIPTS, it breaks the build
# see https://stackoverflow.com/a/61349991/1093649
#composer install --no-cache --optimize-autoloader --no-interaction --no-ansi --no-scripts

echo "export APP_ENV=$APP_ENV" >> /etc/apache2/envvars
echo "export APP_DEBUG=$APP_DEBUG" >> /etc/apache2/envvars



echo ">>>>>>>>>>>>>> END CUSTOM BUILD SCRIPT <<<<<<<<<<<<<<<<< "
