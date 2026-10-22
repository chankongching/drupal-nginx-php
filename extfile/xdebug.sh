#!/bin/sh

# install xdebug from source (pecl/PEAR was removed from the image), do not use it in product environment, add it at 2025-09-04
ENV XDEBUG_VERSION 3.5.3
RUN set -x
dnf install -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake

mkdir -p /home/extension && \
curl -Lk https://github.com/xdebug/xdebug/archive/refs/tags/$XDEBUG_VERSION.tar.gz | gunzip | tar x -C /home/extension && \
cd /home/extension/xdebug-$XDEBUG_VERSION && \
/usr/local/php/bin/phpize && \
./configure --enable-xdebug --with-php-config=/usr/local/php/bin/php-config && \
make && make install && \
echo zend_extension=xdebug.so >> /usr/local/php/etc/php.ini
# echo zend_extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20170718/xdebug.so >> /usr/local/php/etc/php.ini

#Clean OS
dnf remove -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \
    dnf clean all && \
    rm -rf /tmp/* /var/cache/{dnf,yum,ldconfig} /etc/my.cnf{,.d} && \
    mkdir -p --mode=0755 /var/cache/{dnf,yum,ldconfig}
