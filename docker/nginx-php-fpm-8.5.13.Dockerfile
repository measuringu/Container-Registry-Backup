# Hosted nginx-php-fpm on PHP 8.5.13.
# Tagged as ghcr.io/measuringu/nginx-php-fpm:8.5.13 and :latest.
# :8.2.35 and :8.5.12 remain pinned to their own PHP versions.
#   docker buildx build --platform linux/amd64,linux/arm64 -f docker/nginx-php-fpm-8.5.13.Dockerfile -t ghcr.io/measuringu/nginx-php-fpm:8.5.13 -t ghcr.io/measuringu/nginx-php-fpm:latest --push .
FROM php:8.5.13-fpm-alpine3.23
COPY --from=richarvey/nginx-php-fpm:3.1.6 /start.sh /start.sh
COPY --from=richarvey/nginx-php-fpm:3.1.6 /etc/nginx /etc/nginx
COPY --from=richarvey/nginx-php-fpm:3.1.6 /etc/supervisord.conf /etc/supervisord.conf
COPY --from=richarvey/nginx-php-fpm:3.1.6 /usr/bin/composer /usr/bin/composer
COPY --from=richarvey/nginx-php-fpm:3.1.6 /usr/local/etc/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY --from=richarvey/nginx-php-fpm:3.1.6 /usr/local/etc/php-fpm.d /usr/local/etc/php-fpm.d
COPY --from=richarvey/nginx-php-fpm:3.1.6 /usr/local/etc/php/conf.d/docker-vars.ini /usr/local/etc/php/conf.d/docker-vars.ini
# PHP 8.5 links Zend OPcache into the binary. Installing it as a shared module
# fails with "cp: can't stat 'modules/*'". opcache.enable is already On.
RUN apk add --no-cache nginx supervisor bash curl git icu-dev libzip-dev oniguruma-dev libxml2-dev freetype-dev libjpeg-turbo-dev libpng-dev linux-headers $PHPIZE_DEPS \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd pdo_mysql mysqli intl zip exif \
  && MAKEFLAGS="-j1" pecl install redis-6.3.0 \
  && MAKEFLAGS="-j1" pecl install xdebug-3.5.3 \
  && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
  && echo "zend_extension=xdebug" > /usr/local/etc/php/conf.d/xdebug.ini \
  && mkdir -p /var/lib/nginx/tmp \
  && chmod +x /start.sh
ENV FPM_CONF=/usr/local/etc/php-fpm.d/www.conf
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["/start.sh"]
