FROM php:8.3-apache

# Installer les dépendances système et les extensions PHP
RUN apt-get update && apt-get install -y \
    libicu-dev libzip-dev unzip git \
    && docker-php-ext-install pdo pdo_mysql intl zip \
    && rm -rf /var/lib/apt/lists/*

# Activer mod_rewrite pour Symfony
RUN a2enmod rewrite

# Copier la configuration Apache personnalisée
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers Composer et installer les dépendances pour tirer parti du cache de calques
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Copier le reste des fichiers de l'application
COPY . .

# Exécuter les scripts Composer maintenant que tous les fichiers sont présents
RUN composer run-script post-install-cmd

# Donner les droits d'accès à l'utilisateur Apache
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
