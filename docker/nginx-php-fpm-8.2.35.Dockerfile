# Hosted nginx-php-fpm on PHP 8.2.35.
# Official Hub tag php:8.2.35-fpm-alpine3.23 is still unpublished (docker-library/official-images#22541).
# Build that base first, linux/amd64, from docker-library/php f6048b5 (8.2/alpine3.23/fpm), then:
#   docker build --platform linux/amd64 -f docker/nginx-php-fpm-8.2.35.Dockerfile -t ghcr.io/measuringu/nginx-php-fpm:8.2.35 .
FROM php:8.2.35-fpm-alpine3.23
COPY --from=richarvey/nginx-php-fpm:3.1.6 /start.sh /start.sh
COPY --from=richarvey/nginx-php-fpm:3.1.6 /etc/nginx /etc/nginx
COPY --from=richarvey/nginx-php-fpm:3.1.6 /etc/supervisord.conf /etc/supervisord.conf
COPY --from=richarvey/nginx-php-fpm:3.1.6 /usr/bin/composer /usr/bin/composer
COPY --from=richarvey/nginx-php-fpm:3.1.6 /usr/local/etc/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY --from=richarvey/nginx-php-fpm:3.1.6 /usr/local/etc/php-fpm.d /usr/local/etc/php-fpm.d
COPY --from=richarvey/nginx-php-fpm:3.1.6 /usr/local/etc/php/conf.d/docker-vars.ini /usr/local/etc/php/conf.d/docker-vars.ini
RUN apk add --no-cache nginx supervisor bash curl git icu-dev libzip-dev oniguruma-dev libxml2-dev freetype-dev libjpeg-turbo-dev libpng-dev linux-headers $PHPIZE_DEPS \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd pdo_mysql mysqli intl zip exif opcache \
  && pecl install redis-5.3.7 \
  && pecl install xdebug \
  && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
  && echo "zend_extension=xdebug" > /usr/local/etc/php/conf.d/xdebug.ini \
  && mkdir -p /var/lib/nginx/tmp \
  && chmod +x /start.sh
ENV FPM_CONF=/usr/local/etc/php-fpm.d/www.conf
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["/start.sh"]
