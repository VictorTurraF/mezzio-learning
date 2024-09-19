# Use the official PHP 8.1 CLI image
FROM php:8.1-cli

ARG USER_ID
ARG USER_NAME

# Set the working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $USER_ID -d /home/$USER_NAME $USER_NAME
RUN mkdir -p /home/$USER_NAME/.composer && \
    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME

# Copy composer files and install dependencies
COPY composer.json composer.lock ./
COPY bin /var/www/html/bin

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --verbose

# COPY . .

RUN chown -R www-data:www-data /var/www/html

USER $USER_NAME

# Expose port 8080
EXPOSE 8080

# Set the command to run your application
CMD ["composer", "run", "--timeout=0", "serve"]
