#!/usr/bin/env sh
set -e

# clear any old cached config just in case
set -e
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
exec "$@"
