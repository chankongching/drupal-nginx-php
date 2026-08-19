#!/bin/sh
set -eu

# A bind-mounted application directory is normally owned by the host user.
# Keep the runtime writable by the PHP-FPM pool without modifying its contents.
if [ "$(id -u)" -eq 0 ]; then
    chown "${APP_USER:-www}:${APP_GROUP:-www}" /var/www/html /var/www/phpext
fi

exec "$@"
