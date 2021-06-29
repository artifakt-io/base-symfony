#!/bin/bash

set -e

echo ">>>>>>>>>>>>>> START CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "

# Generate file holding custom keys 
if [[ ! -f /data/secret-key ]]; then
  key=$(openssl rand -base64 24)
  echo export WORDPRESS_SECRET=$key >> /data/secret-key
fi

source /data/secret-key

echo "------------------------------------------------------------"
echo "The following build args are available:"
env
echo "------------------------------------------------------------"

mkdir -p /data/var/log /data/var/uploads /data/var/cache && \
  ln -sfn /data/var /var/www/html/var  && \
  chown www-data:www-data /data/var/log /data/var/uploads /data/var/cache

# Generate file holding custom keys 
if [[ ! -f /data/secret-key.php ]]; then
  key=$(openssl rand -base64 24)
  echo WORDPRESS_SECRET=$key >> /data/secret-key
fi


echo ">>>>>>>>>>>>>> END CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "
