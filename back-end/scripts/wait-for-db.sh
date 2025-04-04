#!/bin/bash
# wait-for-it.sh

set -e

host="$1"
shift
cmd="$@"

until php -r "
try {
    \$dbh = new PDO(
        'mysql:host=$host;',
        getenv('DB_USERNAME'),
        getenv('DB_PASSWORD')
    );
    echo 'connected successfully\n';
    exit(0);
} catch (PDOException \$e) {
    echo \$e->getMessage() . PHP_EOL;
    exit(1);
}
"
do
  echo "MySQL is unavailable - sleeping"
  sleep 1
done

echo "MySQL is up - executing command"
exec $cmd
