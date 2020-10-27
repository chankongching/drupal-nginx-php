#
# Dockerfile for building Nginx images
# 
# https://github.com/addcn/docker-lnmp.git
#

FROM centos:centos7
MAINTAINER dodo <lhuibo@gmail.com>

ENV TZ "Asia/Shanghai"

#Yum
RUN yum -y update && \
    yum install -y gcc automake autoconf libtool make gcc-c++ vixie-cron  wget zlib  file openssl-devel sharutils zip  bash vim cyrus-sasl-devel libmemcached libmemcached-devel libyaml libyaml-devel unzip libvpx-devel openssl-devel ImageMagick-devel  autoconf  tar gcc libxml2-devel gd-devel libmcrypt-devel libmcrypt mcrypt mhash libmcrypt libmcrypt-devel libxml2 libxml2-devel bzip2 bzip2-devel curl curl-devel libjpeg libjpeg-devel libpng libpng-devel freetype-devel bison libtool-ltdl-devel net-tools && \
    yum clean all

#Nginx
RUN cd /tmp && \
  wget http://nginx.org/download/nginx-1.11.5.tar.gz && \
  tar xzf nginx-1.11.5.tar.gz && \
  cd /tmp/nginx-1.11.5 && \
  ./configure \
    --prefix=/usr/local/nginx \
    --with-http_ssl_module --with-http_sub_module --with-http_dav_module --with-http_flv_module \
    --with-http_gzip_static_module --with-http_stub_status_module --with-debug && \
    make && \
    make install
#Dir
RUN mkdir -p /usr/local/nginx/html

#Yum
RUN yum -y update && \
    yum install -y gcc automake autoconf libtool make gcc-c++ vixie-cron  wget zlib  file openssl-devel sharutils zip  bash vim cyrus-sasl-devel libmemcached libmemcached-devel libyaml libyaml-devel unzip libvpx-devel openssl-devel ImageMagick-devel  autoconf  tar gcc libxml2-devel gd-devel libmcrypt-devel libmcrypt mcrypt mhash libmcrypt libmcrypt-devel libxml2 libxml2-devel bzip2 bzip2-devel curl curl-devel libjpeg libjpeg-devel libpng libpng-devel freetype-devel bison libtool-ltdl-devel net-tools && \
    yum clean all

#Php
#fix error: mcrypt.h not found
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    yum install -y libmcrypt-devel 

RUN cd /tmp && \
  wget http://cn2.php.net/distributions/php-7.0.12.tar.gz && \
  tar xzf php-7.0.12.tar.gz && \
  cd /tmp/php-7.0.12 && \
  ./configure \
    --prefix=/usr/local/php \
    --with-mysqli --with-pdo-mysql --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-simplexml --enable-xml --disable-rpath --enable-bcmath --enable-soap --enable-zip --with-curl --enable-fpm --with-fpm-user=nobody --with-fpm-group=nobody --enable-mbstring --enable-sockets --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-opcache && \
    make && \
    make install

#复制文件
RUN cp /tmp/php-7.0.12/php.ini-production /usr/local/php/lib/php.ini && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
#配置nginx
ENV HTTP_PHP_CONFIG \\\n\\\t#php\\\n\\\tlocation ~ \\\\.php$ {\\\n\\\t\\\troot    html;\\\n\\\t\\\tfastcgi_pass   127.0.0.1:9000;\\\n\\\t\\\tfastcgi_index    index.php;\\\n\\\t\\\tfastcgi_param  SCRIPT_FILENAME    /usr/local/nginx/html\$fastcgi_script_name;\\\n\\\t\\\tinclude    fastcgi_params;\\\n\\\t}\\\n\\\n\\\t

RUN sed -i -e "s@# deny access to .htaccess files, if Apache@${HTTP_PHP_CONFIG}# deny access to .htaccess files, if Apache@" /usr/local/nginx/conf/nginx.conf
RUN sed -i -e 's/listen = 127.0.0.1:9000/listen = 9000/' /usr/local/php/etc/php-fpm.d/www.conf
#RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
#RUN yum -y install epel-release
#RUN yum -y install supervisor &&\
#    systemctl enable supervisord  &&\
#RUN set -x && \
#    easy_install supervisor && \
#    mkdir -p /var/{log/supervisor,run/{sshd,supervisord}}
RUN  yum -y install python3 &&\
     pip3 install supervisor 
RUN  echo "daemon off;" >> /usr/local/nginx/conf/nginx.conf
EXPOSE 80 443 9000
COPY supervisord.conf /etc/supervisord.conf
#
#ENTRYPOINT ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
CMD ["/usr/local/bin/supervisord"]
