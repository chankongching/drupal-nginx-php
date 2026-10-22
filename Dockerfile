FROM rockylinux/rockylinux:10.2.20260525.0
# Pull all the latest security updates
RUN dnf update -y && dnf clean all
LABEL maintainer="chankongching <chankongching@gmail.com>"

ENV NGINX_VERSION 1.30.6
ENV PHP_VERSION 8.4.27
ENV REDIS_VERSION 6.3.0
ENV MEMCACHED_VERSION 3.4.0
# 3.2.16 is the latest stable igbinary release with PHP 8.4 support
ENV IGBINARY_VERSION 3.2.16
# oniguruma is required by PHP mbstring (mbregex) but is not packaged in EPEL 10
ENV ONIGURUMA_VERSION 6.9.10
# libzip-devel is not packaged in EL 10, so libzip is built from source for ext-zip
ENV LIBZIP_VERSION 1.11.4

# Enable EPEL (libmemcached-awesome, libavif, supervisor, re2c) and CRB
RUN set -x && \
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm && \
    dnf install -y dnf-plugins-core && \
    crb enable

RUN set -x && \
    dnf install -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake \
    pkgconf-pkg-config \
    file \
    diffutils \
    findutils \
    patch \
    procps-ng

#Install PHP library
RUN set -x && \
    dnf install -y zlib-ng-compat \
    zlib-ng-compat-devel \
    re2c \
    openssl \
    openssl-devel \
    pcre2-devel \
    libxml2 \
    libxml2-devel \
    libcurl --allowerasing \
    libcurl-devel \
    libpng-devel \
    libjpeg-turbo-devel \
    libwebp-devel \
    freetype-devel \
    libavif-devel \
    libXpm-devel \
    openssh-server \
    libxslt-devel \
    sqlite-devel \
    mariadb \
    libmemcached-awesome \
    libmemcached-awesome-devel \
    cyrus-sasl-devel \
    unzip \
    wget \
    which \
    telnet \
    supervisor

# Build oniguruma (mbstring mbregex) and libzip (ext-zip) from source
RUN set -x && \
    mkdir -p /home/nginx-php && cd /home/nginx-php && \
    curl -Lk https://github.com/kkos/oniguruma/releases/download/v$ONIGURUMA_VERSION/onig-$ONIGURUMA_VERSION.tar.gz | gunzip | tar x && \
    cd onig-$ONIGURUMA_VERSION && \
    ./configure --prefix=/usr && \
    make && make install && \
    cd /home/nginx-php && \
    curl -Lk https://github.com/nih-at/libzip/releases/download/v$LIBZIP_VERSION/libzip-$LIBZIP_VERSION.tar.gz | gunzip | tar x && \
    cd libzip-$LIBZIP_VERSION && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. && \
    make && make install

#Add user, then download nginx & php
RUN set -x && \
    mkdir -p /var/www/{html,phpext} && \
    useradd -r -s /sbin/nologin -d /var/www/html -m -k no www && \
    mkdir -p /home/nginx-php && cd /home/nginx-php && \
    curl -Lk https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
    curl -Lk https://www.php.net/distributions/php-$PHP_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php

#Make install nginx
RUN set -x && \
    cd /home/nginx-php/nginx-$NGINX_VERSION && \
    ./configure --prefix=/usr/local/nginx \
    --user=www --group=www \
    --error-log-path=/var/log/nginx_error.log \
    --http-log-path=/var/log/nginx_access.log \
    --pid-path=/var/run/nginx.pid \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --with-http_gzip_static_module && \
    make && make install

#Make install php
# NOTE: GD is built from the libgd bundled with PHP (no --with-external-gd), so
# --with-avif/--with-webp/--with-jpeg/--with-xpm/--with-freetype all take effect.
# NOTE: --with-mhash is omitted because it has been deprecated since PHP 8.1.
# NOTE: on PHP 8.4 opcache is not built in, --enable-opcache builds it as a shared
# extension (opcache.so) that is loaded via zend_extension below.
RUN set -x && \
    cd /home/nginx-php/php-$PHP_VERSION && \
    ./configure --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-config-file-scan-dir=/usr/local/php/etc/php.d \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mysqli \
    --with-pdo-mysql \
    --with-openssl \
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-xsl \
    --without-pear \
    --enable-bcmath \
    --enable-fpm \
    --enable-xml \
    --enable-shmop \
    --enable-sysvsem \
    --enable-sysvmsg \
    --enable-sysvshm \
    --enable-mbregex \
    --enable-mbstring \
    --enable-opcache \
    --enable-ftp \
    --enable-mysqlnd \
    --enable-pcntl \
    --enable-sockets \
    --with-zip \
    --enable-soap \
    --enable-session \
    --enable-exif \
    --enable-fileinfo \
    --disable-rpath \
    --enable-ipv6 \
    --enable-gd \
    --with-avif \
    --with-webp \
    --with-jpeg \
    --with-xpm \
    --with-freetype && \
    make && make install

#Install php-fpm
RUN set -x && \
    cd /home/nginx-php/php-$PHP_VERSION && \
    cp php.ini-production /usr/local/php/etc/php.ini && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

# Enable igbinary
RUN set -x && \
    mkdir -p /usr/local/src/php-igbinary && \
    cd /usr/local/src/php-igbinary && \
    curl -Lk https://github.com/igbinary/igbinary/archive/refs/tags/$IGBINARY_VERSION.tar.gz | gunzip | tar x && \
    cd igbinary-$IGBINARY_VERSION && \
    /usr/local/php/bin/phpize && \
    ./configure --with-php-config=/usr/local/php/bin/php-config && \
    make && \
    make install && \
    echo "extension=igbinary.so" >> /usr/local/php/etc/php.ini

# Enable memcache
RUN set -x && \
    mkdir -p /usr/local/src/php-memcache && \
    cd /usr/local/src/php-memcache && \
    wget https://github.com/php-memcached-dev/php-memcached/archive/refs/tags/v$MEMCACHED_VERSION.zip && \
    unzip v$MEMCACHED_VERSION.zip && \
    cd php-memcached-$MEMCACHED_VERSION && \
    /usr/local/php/bin/phpize && \
    ./configure --with-php-config=/usr/local/php/bin/php-config && \
    make && \
    make install && \
    echo "extension=memcached.so" >> /usr/local/php/etc/php.ini

# Enable redis
RUN set -x && \
    cd /root && \
    wget https://github.com/phpredis/phpredis/archive/$REDIS_VERSION.zip -O phpredis.zip && \
    unzip -o /root/phpredis.zip && \
    mv /root/phpredis-* /root/phpredis && \
    cd /root/phpredis && \
    /usr/local/php/bin/phpize && \
    ./configure --with-php-config=/usr/local/php/bin/php-config && \
    make && \
    make install && \
    echo extension=redis.so >> /usr/local/php/etc/php.ini

# Changing php.ini
# NOTE: opcache is a shared extension on PHP 8.4, so it is loaded with
# zend_extension=opcache.so in the opcache step below.
RUN set -x && \
    sed -i 's/memory_limit = .*/memory_limit = -1/' /usr/local/php/etc/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 512M/' /usr/local/php/etc/php.ini && \
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 512M/' /usr/local/php/etc/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 512M/' /usr/local/php/etc/php.ini && \
    sed -i 's/^; max_input_vars =.*/max_input_vars =10000/' /usr/local/php/etc/php.ini && \
    sed -i 's/^;cgi.fix_pathinfo =.*/cgi.fix_pathinfo = 0;/' /usr/local/php/etc/php.ini

# Enable opcache php.ini (opcache is built as a shared extension on PHP 8.4)
RUN set -x && \
    echo "zend_extension=opcache.so" >> /usr/local/php/etc/php.ini && \
    sed -i 's/^;opcache.enable=.*/opcache.enable=1/' /usr/local/php/etc/php.ini && \
    sed -i 's/^;opcache.memory_consumption=.*/opcache.memory_consumption=256/' /usr/local/php/etc/php.ini && \
    sed -i 's/^;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/' /usr/local/php/etc/php.ini && \
    sed -i 's/^;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=4000/' /usr/local/php/etc/php.ini && \
    sed -i 's/^;opcache.revalidate_freq=.*/opcache.revalidate_freq=60/' /usr/local/php/etc/php.ini && \
    sed -i 's/^;opcache.fast_shutdown=.*/opcache.fast_shutdown=1/' /usr/local/php/etc/php.ini && \
    sed -i 's/^;opcache.enable_cli=.*/opcache.enable_cli=1/' /usr/local/php/etc/php.ini

# Changing php-fpm configureations
RUN set -x && \
    sed -i 's/listen = .*/listen = \/var\/run\/php-fpm-www.sock/' /usr/local/php/etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.owner = www/listen.owner = www/' /usr/local/php/etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.group = www/listen.group = www/' /usr/local/php/etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.mode = 0660/listen.mode = 0660/' /usr/local/php/etc/php-fpm.d/www.conf

# Install supervisor (from EPEL)
RUN set -x && \
    mkdir -p /var/{log/supervisor,run/{sshd,supervisord}}

ENV PATH /usr/local/php/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.config/composer/vendor/bin

# Chaning timezone
RUN set -x && \
    unlink /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#Change Mod from webdir
RUN set -x && \
    chown -R www:www /var/www/html

# Insert supervisord conf file
ADD supervisord.conf /etc/

#Create web folder,mysql folder
VOLUME ["/var/www/html", "/usr/local/nginx/conf/ssl", "/usr/local/nginx/conf/vhost", "/usr/local/php/etc/php.d", "/var/www/phpext"]

ADD index.php /var/www/html

ADD extfile/ /var/www/phpext/

#Update nginx config
ADD nginx.conf /usr/local/nginx/conf/

#Start
ADD startup.sh /var/www/startup.sh
RUN chmod +x /var/www/startup.sh

ENV COMPOSER_ALLOW_SUPERUSER 1
RUN set -x && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require drush/drush:^13 && \
    echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> $HOME/.bashrc

# Update Composer
RUN /usr/local/bin/composer self-update --2

RUN rpm -Uvh https://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm
# New Relic rotated their RPM signing key in March 2026; the new key must be imported
RUN rpm --import https://download.newrelic.com/php_agent/NEWRELIC_RPM_BD2E199C.public
RUN dnf install -y newrelic-php5


#Clean OS
RUN set -x && \
    dnf remove -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \
    dnf clean all && \
    rm -rf /tmp/* /var/cache/{dnf,yum,ldconfig} /etc/my.cnf{,.d} && \
    mkdir -p --mode=0755 /var/cache/{dnf,yum,ldconfig} && \
    find /var/log -type f -delete && \
    rm -rf /home/nginx-php /usr/local/src/php-igbinary /usr/local/src/php-memcache /root/phpredis /root/phpredis.zip

#Set port
EXPOSE 80 443

#Start it
ENTRYPOINT ["/var/www/startup.sh"]

# Setting working directory
WORKDIR /var/www/html
