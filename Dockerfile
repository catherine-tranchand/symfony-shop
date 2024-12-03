# Use PHP 8.3 with Apache
FROM php:8.3-apache

# Allow Composer to be executed as a superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install necessary dependencies
RUN apt-get update \
    && apt-get install -yqq --no-install-recommends \
       git \
       curl \
       libpq-dev \
       libicu-dev \
       zip \
       unzip \
       postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure and install required PHP extensions
RUN docker-php-ext-configure intl && docker-php-ext-install pdo pdo_pgsql intl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set the working directory
WORKDIR /var/www/symfony-shop

# Copy project files (this includes bin/console if it's already part of the project)
COPY . /var/www/symfony-shop/

# Ensure permissions for the www-data user
RUN chown -R www-data:www-data /var/www/symfony-shop/

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install dependencies after copying the full project
RUN composer install --prefer-dist --no-progress --no-interaction --no-cache

# Set the correct user permissions
RUN usermod -u 1000 www-data

# Expose port 80 to access the application
EXPOSE 80

# Default command to start Apache in the foreground
CMD ["apache2-foreground"]
