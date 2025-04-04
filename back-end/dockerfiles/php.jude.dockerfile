#### composer image to install composer dependencies
FROM composer:2.7.1 AS composer

##### node image to install node modules and build assets
FROM node:22-alpine AS node

RUN mkdir -p /var/www/html
WORKDIR /var/www/html

COPY . /var/www/html

RUN npm install && npm run build

### PHP image to run the application
FROM php:8.3-fpm-alpine

ARG UID=1000
ARG GID=1000 
ARG USER=laravelUser

ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}

WORKDIR /var/www/html

RUN delgroup dialout

RUN addgroup -g ${GID} --system ${USER}
RUN adduser -G ${USER} --system -D -s /bin/sh -u ${UID} ${USER}

RUN sed -i "s/user = www-data/user = ${USER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${USER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

### setting up for frontend api requests
RUN sed -i "s/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g" /usr/local/etc/php-fpm.d/www.conf.default
RUN echo "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 172.18.0.3/g" /usr/local/etc/php-fpm.d/www.conf


# Additional settings to prevent connection reset issues
# RUN echo "process_control_timeout = 0" >> /usr/local/etc/php-fpm.d/www.conf
RUN echo "request_terminate_timeout = 300s" >> /usr/local/etc/php-fpm.d/www.conf


##
RUN apk update && apk add --no-cache libpng libpng-dev jpeg-dev

RUN docker-php-ext-configure gd --enable-gd --with-jpeg
RUN docker-php-ext-install gd

RUN docker-php-ext-install exif

RUN apk add --no-cache zip libzip-dev
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip

RUN docker-php-ext-install pdo pdo_mysql

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

RUN apk add --no-cache --upgrade bash


COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=node /var/www/html .
RUN composer install --no-dev --no-interaction --optimize-autoloader

RUN chown -R ${USER}:${USER} /var/www/html/storage \
    && chown -R ${USER}:${USER} /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache


# COPY ./scripts/php-starter.sh php-starter.sh
RUN chmod +x ./scripts/php-starter.sh

# RUN chown -R www-data:www-data /var/www/html

# USER www-data

EXPOSE 9000

ENTRYPOINT ["./scripts/php-starter.sh"]


