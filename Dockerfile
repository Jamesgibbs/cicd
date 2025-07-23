# Stage 1: Build
FROM composer:2 AS build

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

COPY . .
RUN php artisan config:cache \
 && php artisan route:cache \
 && php artisan view:cache

# Stage 2: Runtime
FROM php:8.3-fpm-alpine

WORKDIR /var/www
COPY --from=build /app /var/www

# Install only production PHP extensions
RUN apk add --no-cache oniguruma libzip \
 && docker-php-ext-install pdo_mysql zip

# Permissions
RUN chown -R www-data:www-data /var/www

EXPOSE 9000
CMD ["php-fpm"]

