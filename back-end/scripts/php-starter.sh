#!/bin/bash

echo "Waiting for MySQL to be ready..."
while ! nc -z mysql 3306; do
    sleep 1
    echo "MySQL is not ready..."
done
echo "MySQL is ready!"


# Wait for MySQL to be ready
# ./scripts/wait-for-db.sh mysql:3306 -t 60

# Install dependencies
# composer install --no-interaction --no-plugins --no-scripts

# Generate app key if not set
php artisan key:generate --no-interaction --force



php artisan optimize
php artisan config:clear
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Run migrations
php artisan migrate:refresh --force

php artisan db:seed --force

exec php-fpm -y /usr/local/etc/php-fpm.conf -R --nodaemonize