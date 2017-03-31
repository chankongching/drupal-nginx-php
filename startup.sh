#!/bin/sh
Nginx_Install_Dir=/usr/local/nginx
DATA_DIR=/var/www/html

set -e
chown -R www.www $DATA_DIR
#/docker-entrypoint.sh

/usr/bin/supervisord -n -c /etc/supervisord.conf
