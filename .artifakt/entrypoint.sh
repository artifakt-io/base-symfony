#!/bin/bash

set -e

echo ">>>>>>>>>>>>>> START CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "

mkdir -p /data/var/log /data/var/uploads /data/var/cache && \
  ln -s /data/var /var/www/html/var && \
  chown www-data:www-data /data/var/log /data/var/uploads /data/var/cache 

echo ">>>>>>>>>>>>>> END CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "
