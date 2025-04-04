##### node image to install node modules and build assets
FROM node:22-alpine AS node

RUN mkdir -p /var/www/html
WORKDIR /var/www/html

COPY . /var/www/html

RUN npm install && npm run build




# Start from a PHP image with Apache
FROM php-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite


# RUN apt install -y gnupg && \
#     apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138 112695A0E562B32A && \
#     apt-get update

# Install PHP extensions
RUN apt update && apt install -y libpng-dev libjpeg-dev libfreetype6-dev zip unzip && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && docker-php-ext-install gd pdo pdo_mysql


WORKDIR /var/www/html

# Copy your applications code to the image
COPY --from=node /var/www/html .

# Copy over and run the composer install command
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev

# Adjust the permissions
RUN chown -R www-data:www-data /var/www