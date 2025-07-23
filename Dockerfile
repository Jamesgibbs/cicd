# Stage “assets” compiles your front-end
FROM node:18 AS assets

WORKDIR /app

# Install only npm deps for caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy source and build assets
COPY . .
RUN npm run build

# Stage 1: Build
FROM composer:2 AS build

WORKDIR /app

# PHP deps caching trick
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copy app code
COPY . .

# Pull in compiled assets
COPY --from=assets /app/public /app/public

# Cache Laravel bootstraps
RUN php artisan config:cache \
 && php artisan route:cache \
 && php artisan view:cache

# Stage 2: Runtime
FROM php:8.3-fpm-alpine

WORKDIR /var/www

# Copy built app (including assets)
COPY --from=build /app /var/www

# Production PHP extensions
RUN apk add --no-cache \
      oniguruma-dev \
      libzip-dev \
      zlib-dev \
      autoconf \
      g++ \
      make \
    && docker-php-ext-install pdo_mysql zip

# Permissions
RUN chown -R www-data:www-data /var/www

EXPOSE 9000
CMD ["php-fpm"]

