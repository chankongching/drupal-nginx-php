FROM centos:7
MAINTAINER Skiychan <dev@skiy.net>

ENV NGINX_VERSION 1.11.6
ENV PHP_VERSION 7.1.0

RUN set -x && \
    yum install -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \

#Install PHP library
## libmcrypt-devel DIY
    rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && \
    yum install -y zlib \
    zlib-devel \
    re2c \
    openssl \
    openssl-devel \
    pcre-devel \
    libxml2 \
    libxml2-devel \
    libcurl \
    libcurl-devel \
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libmcrypt-devel \
    openssh-server \
    python-setuptools \
    mysql && \

#Add user
    mkdir -p /var/www/{html,phpext} && \
    useradd -r -s /sbin/nologin -d /var/www/html -m -k no www && \

#Download nginx & php
    mkdir -p /home/nginx-php && cd $_ && \
    curl -Lk http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
    curl -Lk http://php.net/distributions/php-$PHP_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \

#Make install nginx
    cd /home/nginx-php/nginx-$NGINX_VERSION && \
    ./configure --prefix=/usr/local/nginx \
    --user=www --group=www \
    --error-log-path=/var/log/nginx_error.log \
    --http-log-path=/var/log/nginx_access.log \
    --pid-path=/var/run/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --with-http_gzip_static_module && \
    make && make install && \

#Make install php
    cd /home/nginx-php/php-$PHP_VERSION && \
    ./configure --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-config-file-scan-dir=/usr/local/php/etc/php.d \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mcrypt=/usr/include \
    --with-mysqli \
    --with-pdo-mysql \
    --with-openssl \
    --with-gd \
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-png-dir \
    --with-jpeg-dir \
    --with-freetype-dir \
    --with-xmlrpc \
    --with-mhash \
    --enable-fpm \
    --enable-xml \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-mbstring \
    --enable-ftp \
    --enable-gd-native-ttf \
    --enable-mysqlnd \
    --enable-pcntl \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-session \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --enable-fileinfo \
    --disable-rpath \
    --enable-ipv6 \
    --disable-debug \
    --without-pear && \
    make && make install && \


#Install php-fpm
    cd /home/nginx-php/php-$PHP_VERSION && \
    cp php.ini-production /usr/local/php/etc/php.ini && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf && \

# Changing php.ini
   sed -i 's/memory_limit = .*/memory_limit = 512M/' /usr/local/php/etc/php.ini && \
   sed -i 's/upload_max_filesize = .*/upload_max_filesize = 20M/' /usr/local/php/etc/php.ini && \
   sed -i 's/post_max_size = .*/post_max_size = 80M/' /usr/local/php/etc/php.ini && \

# Changing php-fpm configureations
   sed -i 's/listen = .*/listen = \/var\/run\/php-fpm-www.sock/' /usr/local/php/etc/php-fpm.d/www.conf && \
   sed -i 's/;listen.owner = www/listen.owner = www/' /usr/local/php/etc/php-fpm.d/www.conf && \
   sed -i 's/;listen.group = www/listen.group = www/' /usr/local/php/etc/php-fpm.d/www.conf && \
   sed -i 's/;listen.mode = 0660/listen.mode = 0660/' /usr/local/php/etc/php-fpm.d/www.conf && \

#Install supervisor
    easy_install supervisor && \
    mkdir -p /var/{log/supervisor,run/{sshd,supervisord}} && \

#Clean OS
    yum remove -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \
    yum clean all && \
    rm -rf /tmp/* /var/cache/{yum,ldconfig} /etc/my.cnf{,.d} && \
    mkdir -p --mode=0755 /var/cache/{yum,ldconfig} && \
    find /var/log -type f -delete && \
    rm -rf /home/nginx-php && \

# Chaning timezone
    unlink /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \

#Change Mod from webdir
    chown -R www:www /var/www/html

#Add supervisord conf
ADD supervisord.conf /etc/

#Create web folder,mysql folder
VOLUME ["/var/www/html", "/usr/local/nginx/conf/ssl", "/usr/local/nginx/conf/vhost", "/usr/local/php/etc/php.d", "/var/www/phpext"]

ADD index.php /var/www/html

ADD extfile/ /var/www/phpext/

#Update nginx config
ADD nginx.conf /usr/local/nginx/conf/

ADD ./scripts/docker-entrypoint.sh /docker-entrypoint.sh
ADD ./scripts/docker-install.sh /docker-install.sh

#Start
ADD startup.sh /var/www/startup.sh
RUN chmod +x /var/www/startup.sh

ENV PATH /usr/local/php/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN set -x && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require drush/drush:~8 && \
    sed -i '1i export PATH="$HOME/.composer/vendor/drush/drush:$PATH"' $HOME/.bashrc && \
    source $HOME/.bashrc 

#RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /docker-install.sh
#Set port
EXPOSE 80 443

#Start it
ENTRYPOINT ["/var/www/startup.sh"]

#Start web server
#CMD ["/bin/bash", "/startup.sh"]

# Setting working directory
WORKDIR /var/www/html
