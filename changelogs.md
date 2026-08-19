# Changelog

## 2026-08-19 — Modern runtime migration

- Replaced the unsupported CentOS 7 source-build image with `php:8.5-fpm-trixie`.
- Upgraded Nginx to the official stable `1.30.4-1~trixie` package.
- Upgraded Composer to 2.10 and Drush to 13.7.6.
- Replaced legacy Redis, Memcached, and Xdebug installation flows with pinned PECL releases: Redis 6.3.0, Memcached 3.4.0, and optional Xdebug 3.5.3.
- Removed deprecated PHP 7 extensions and options, including `mcrypt`, `xmlrpc`, `wddx`, and the old `mysql` extension.
- Added current PHP 8.5 extensions for Drupal workloads: `intl`, `gd` with modern image formats, PDO MySQL, OPcache, SOAP, XSL, ZIP, Redis, and Memcached.
- Reworked PHP-FPM, Nginx, and Supervisor configuration for container-native foreground processes, structured standard-output logging, a `/healthz` endpoint, and safer defaults.
- Removed the public `phpinfo()` page and unsafe TLS-disabling download commands.
- Added current usage, migration, custom-extension, and validation documentation.

> This is a major compatibility change from PHP 7.2 to PHP 8.5. Existing Drupal applications must be upgraded and tested before deployment.

## Historical releases

### 2016-12-04

- Updated PHP to 7.1.0.
- Updated Nginx to 1.11.6.

### 2016-10-14 through 2016-01-25

- Incrementally updated PHP 7.0 and Nginx 1.9/1.11 releases.
- Added early custom-extension, MongoDB, fileinfo, IPv6, and Xdebug support.
