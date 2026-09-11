#!/bin/sh
#########################################################################
# File Name: extension.sh
# Author: Skiychan
# Email:  dev@skiy.net
# Version:
# Created Time: 2016/08/03
#########################################################################

#Add extension xdebug
curl -Lk https://github.com/xdebug/xdebug/archive/refs/tags/3.5.3.tar.gz | gunzip | tar x -C /home/extension && \
cd /home/extension/xdebug-3.5.3 && \
/usr/local/php/bin/phpize && \
./configure --enable-xdebug --with-php-config=/usr/local/php/bin/php-config && \
make && make install

#Add extension mongodb
curl -Lk https://pecl.php.net/get/mongodb-2.5.2.tgz | gunzip | tar x -C /home/extension && \
cd /home/extension/mongodb-2.5.2 && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && make install
