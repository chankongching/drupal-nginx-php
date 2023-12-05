#!/bin/sh
Nginx_Install_Dir=/usr/local/nginx
DATA_DIR=/var/www/html

# Checking if newrelic variable is provided
if [ ! -z ${NEWRELICKEY+x} ];
then
  if [ ! -z ${NEWRELICAPPNAME+x} ];
  then
    NR_INSTALL_KEY=$NEWRELICKEY NR_INSTALL_SILENT=1 newrelic-install install
    find /etc /opt/etc /usr/local/etc -type f -name newrelic.ini -exec sed -i -e "s/REPLACE_WITH_REAL_KEY/$NEWRELICKEY/" -e "s/newrelic.appname[[:space:]]=[[:space:]].*/newrelic.appname = \"$NEWRELICAPPNAME\"/" {} \; 2>/dev/null
  fi
fi

set -e
chown -R www.www $DATA_DIR
#/docker-entrypoint.sh

/usr/local/bin/supervisord -n -c /etc/supervisord.conf
