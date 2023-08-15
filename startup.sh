#!/bin/sh
Nginx_Install_Dir=/usr/local/nginx
DATA_DIR=/var/www/html

# Checking if newrelic variable is provided
if [ ! -z ${NEWRELICKEY+x} ];
then
  if [ ! -z ${NEWRELICAPPNAME+x} ];
  then
    export NR_INSTALL_SILENT=true
    /usr/bin/newrelic-install install
    sed -i "s/newrelic.appname = .*/newrelic.appname = \"$NEWRELICAPPNAME\"/" /etc/php.d/newrelic.ini
    sed -i "s/newrelic.license = .*/newrelic.license = \"$NEWRELICKEY\"/" /etc/php.d/newrelic.ini
  fi
fi

set -e
chown -R www.www $DATA_DIR
#/docker-entrypoint.sh

/usr/local/bin/supervisord -n -c /etc/supervisord.conf
