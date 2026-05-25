FROM php:8.2-fpm-bookworm
WORKDIR /var/www/html
RUN apt-get update && apt-get install -y libicu-dev libzip-dev libxml2-dev libpng-dev libsodium-dev  
RUN docker-php-ext-install intl pdo_mysql zip bcmath soap gd sodium opcache
