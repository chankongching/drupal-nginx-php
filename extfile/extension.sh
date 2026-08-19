#!/bin/sh
#
# Optional extension recipe for the PHP 8.5 image.
#
# This file is documentation and is not executed at container startup. Add the
# required commands to the Dockerfile during image build, rather than compiling
# extensions inside a running production container.
#
# Example: install the current MongoDB extension.
# RUN set -eux; \
#     apt-get update; \
#     apt-get install -y --no-install-recommends $PHPIZE_DEPS libssl-dev; \
#     pecl install mongodb-2.4.0; \
#     docker-php-ext-enable mongodb; \
#     apt-get purge -y --auto-remove $PHPIZE_DEPS libssl-dev; \
#     rm -rf /var/lib/apt/lists/* /tmp/pear
#
# Xdebug 3.5.3 is deliberately optional. Enable it only in a development image:
# docker build --build-arg INSTALL_XDEBUG=true -t drupal-nginx-php:dev .
