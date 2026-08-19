# Drupal PHP Nginx

A production-oriented Docker image that runs **Nginx 1.30.4** and **PHP 8.5 FPM** for Drupal applications. The image replaces the legacy CentOS 7 source-build stack with maintained Debian-based official images and packages.

| Component | Current image configuration | Notes |
| --- | --- | --- |
| PHP | `php:8.5-fpm-trixie` | Official PHP FPM image; the 8.5 tag receives current patch updates. |
| Nginx | `1.30.4-1~trixie` | Current Nginx stable package from the official Nginx repository. |
| Composer | `2.10` | Copied from the official Composer image. |
| Drush | `13.7.6` | Installed globally for compatible Drupal projects. |
| Redis extension | `6.3.0` | Installed via PECL. |
| Memcached extension | `3.4.0` | Installed via PECL; includes PHP 8.5 support. |
| Xdebug | `3.5.3` | Excluded by default; opt in for development builds only. |

## What changed

The old image compiled Nginx and PHP 7.2 from source on CentOS 7, which is end-of-life. It also installed unpinned dependencies through discontinued endpoints, exposed `phpinfo()` in the default page, and relied on deprecated extensions such as `mcrypt`, `xmlrpc`, `wddx`, and the old `mysql` API. The image now uses maintained packages, reproducibly pins third-party PHP extensions, removes deprecated functionality, sends logs to standard output/error, exposes a health endpoint, and keeps PHP-FPM and Nginx in the foreground under Supervisor.

> **Major-version migration:** This is an intentional upgrade from PHP 7.2 to PHP 8.5. Before deploying an existing Drupal application, update Drupal core, contributed modules, themes, and Composer dependencies to versions that support PHP 8.5. Drupal 7 applications in particular need a separately validated compatibility plan.

## Build

Build the standard production image:

```sh
docker build -t drupal-nginx-php:latest .
```

Create a development image with Xdebug enabled:

```sh
docker build \
  --build-arg INSTALL_XDEBUG=true \
  -t drupal-nginx-php:dev .
```

The build uses versioned Nginx, PECL extension, and Drush dependencies. To deliberately update a pinned package, modify the corresponding `ARG` in the `Dockerfile`, rebuild, and run the validation commands below.

## Run

Mount a Drupal document root at `/var/www/html`:

```sh
docker run --rm --name drupal-web \
  -p 8080:80 \
  -v "$PWD/web:/var/www/html" \
  drupal-nginx-php:latest
```

Open `http://localhost:8080` to access the application. Container readiness can be checked without loading Drupal:

```sh
curl -i http://localhost:8080/healthz
```

The expected response is **HTTP 204**.

| Mount path | Purpose |
| --- | --- |
| `/var/www/html` | Drupal document root. |
| `/etc/nginx/certs` | TLS certificates and keys for custom virtual hosts. |
| `/etc/nginx/conf.d/vhost` | Additional Nginx virtual-host configuration. |
| `/usr/local/etc/php/conf.d` | Additional PHP INI files. The legacy alias `/usr/local/php/etc/php.d` resolves here. |
| `/var/www/phpext` | Reference location for custom extension artifacts. Build extensions into a derived image rather than compiling them at runtime. |

## Included PHP extensions

The image installs `bcmath`, `exif`, `gd` (with AVIF, FreeType, JPEG, and WebP), `intl`, `mysqli`, `opcache`, `pcntl`, `pdo_mysql`, `redis`, `memcached`, `soap`, `sockets`, `xsl`, and `zip`. The standard PHP extensions already bundled in the official base image remain available.

Run the following command to view the actual module list in the built image:

```sh
docker run --rm --entrypoint php drupal-nginx-php:latest -m
```

## Drupal and Nginx behavior

Nginx routes requests through `index.php` only when no matching static file or directory exists. Direct PHP execution is limited to real files, private Drupal files are denied, sensitive repository and Composer metadata files are blocked, and static assets receive cache headers. The `/healthz` endpoint is intentionally handled by Nginx and does not invoke PHP.

The default PHP configuration is located at `php/conf.d/99-drupal.ini`; it enables OPcache and sets conservative production defaults. FPM settings are in `php-fpm.d/zz-drupal.conf`. Override only the settings required by the deployed application through a dedicated file mounted into `/usr/local/etc/php/conf.d`.

## Drush

Drush is available on the image `PATH`:

```sh
docker run --rm \
  -v "$PWD/web:/var/www/html" \
  --entrypoint drush \
  drupal-nginx-php:latest status
```

Drush compatibility depends on the mounted Drupal application's core version and Composer dependency constraints. The globally installed Drush is therefore a convenience tool; project-local Drush installed through the application's `composer.json` should take precedence in CI and production automation.

## Custom extensions

Use a derived Docker image for custom extensions. The current MongoDB recipe is documented in [`extfile/extension.sh`](extfile/extension.sh). Do not install compilers or run PECL in a running production container.

## Validation

After a build, verify the image configuration and runtime behavior:

```sh
docker run --rm --entrypoint nginx drupal-nginx-php:latest -t
docker run --rm --entrypoint php drupal-nginx-php:latest -v
docker run --rm --entrypoint php drupal-nginx-php:latest -m
docker run --rm -d --name drupal-web-test -p 8080:80 drupal-nginx-php:latest
curl -fsSI http://localhost:8080/healthz
docker rm -f drupal-web-test
```

## References

The image follows the installation and configuration guidance of the [official PHP Docker image](https://hub.docker.com/_/php), [official Nginx Docker image](https://hub.docker.com/_/nginx), [Nginx documentation](https://nginx.org/en/docs/), [Composer](https://getcomposer.org/), and [Drush](https://www.drush.org/).
