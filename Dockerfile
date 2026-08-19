FROM composer:2.10 AS composer

FROM php:8.5-fpm-trixie

LABEL org.opencontainers.image.title="Drupal PHP Nginx" \
      org.opencontainers.image.description="Production-oriented PHP-FPM, Nginx, Composer, and Drush image for Drupal." \
      org.opencontainers.image.source="https://github.com/chankongching/drupal-nginx-php"

ARG NGINX_VERSION=1.30.4-1~trixie
ARG REDIS_VERSION=6.3.0
ARG MEMCACHED_VERSION=3.4.0
ARG DRUSH_VERSION=13.7.6
ARG XDEBUG_VERSION=3.5.3
ARG INSTALL_XDEBUG=false

ENV APP_USER=www \
    APP_GROUP=www \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/opt/composer \
    PATH="/opt/composer/vendor/bin:${PATH}"

SHELL ["/bin/sh", "-euxc"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg2 supervisor \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/debian/ trixie nginx" > /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends "nginx=${NGINX_VERSION}" \
    && apt-mark manual nginx supervisor curl ca-certificates \
    && savedAptMark="$(apt-mark showmanual)" \
    && apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS \
        libavif-dev \
        libfreetype-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmemcached-dev \
        libpng-dev \
        libwebp-dev \
        libxml2-dev \
        libxslt1-dev \
        libzip-dev \
        pkg-config \
        zlib1g-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-avif \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        exif \
        gd \
        intl \
        mysqli \
        pcntl \
        pdo_mysql \
        soap \
        sockets \
        xsl \
        zip \
    && pecl install "redis-${REDIS_VERSION}" \
    && pecl install "memcached-${MEMCACHED_VERSION}" \
    && docker-php-ext-enable redis memcached \
    && if [ "${INSTALL_XDEBUG}" = "true" ]; then \
        pecl install "xdebug-${XDEBUG_VERSION}"; \
        docker-php-ext-enable xdebug; \
    fi \
    && apt-mark auto '.*' > /dev/null \
    && apt-mark manual ${savedAptMark} \
    && apt-mark manual \
        libavif16 \
        libfreetype6 \
        libicu76 \
        libjpeg62-turbo \
        libmemcached11t64 \
        libpng16-16t64 \
        libwebp7 \
        libxml2 \
        libxslt1.1 \
        libzip5 \
        zlib1g \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* /tmp/pear

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN composer global require --no-interaction --no-plugins --prefer-dist --optimize-autoloader "drush/drush:${DRUSH_VERSION}" \
    && ln -sf /opt/composer/vendor/bin/drush /usr/local/bin/drush \
    && groupadd --system "${APP_GROUP}" \
    && useradd --system --gid "${APP_GROUP}" --home-dir /var/www --shell /usr/sbin/nologin "${APP_USER}" \
    && mkdir -p /var/www/html /var/www/phpext /var/run/php /etc/nginx/certs /etc/nginx/conf.d/vhost \
    && chown -R "${APP_USER}:${APP_GROUP}" /var/www /var/run/php \
    && ln -s /etc/nginx /usr/local/nginx \
    && mkdir -p /usr/local/php/etc \
    && ln -s "${PHP_INI_DIR}/conf.d" /usr/local/php/etc/php.d \
    && rm -f /etc/nginx/conf.d/default.conf

COPY php/conf.d/99-drupal.ini ${PHP_INI_DIR}/conf.d/99-drupal.ini
COPY php-fpm.d/zz-drupal.conf /usr/local/etc/php-fpm.d/zz-drupal.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY startup.sh /usr/local/bin/container-start
COPY index.php /var/www/html/index.php
COPY extfile/ /var/www/phpext/

RUN chmod +x /usr/local/bin/container-start \
    && chown -R "${APP_USER}:${APP_GROUP}" /var/www/html /var/www/phpext

VOLUME ["/var/www/html", "/etc/nginx/certs", "/etc/nginx/conf.d/vhost", "/usr/local/etc/php/conf.d", "/var/www/phpext"]

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl --fail --silent --show-error http://127.0.0.1/healthz || exit 1

ENTRYPOINT ["/usr/local/bin/container-start"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

WORKDIR /var/www/html
