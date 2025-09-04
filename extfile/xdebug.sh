#!/bin/sh

# install xdebug with pecl, do not use it in product environment, add it at 2025-09-04
RUN set -x
dnf install -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake

/usr/bin/pecl install xdebug &&\
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
