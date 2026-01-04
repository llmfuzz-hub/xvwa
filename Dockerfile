FROM php:8-apache

LABEL org.opencontainers.image.source=https://github.com/s4n7h0/xvwa
LABEL org.opencontainers.image.description="XVWA pre-built image."

WORKDIR /var/www/html

RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping git libzip-dev unzip \
 && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && a2enmod rewrite \
 && docker-php-ext-install gd mysqli pdo pdo_mysql zip \
 && pecl install xdebug \
 && docker-php-ext-enable xdebug \
 && mkdir -p /tmp/xdebug \
 && chown www-data:www-data /tmp/xdebug \
 && printf '%s\n' \
        '; zend_extension=xdebug.so (already loaded by docker-php-ext-enable)' \
        'xdebug.mode=trace' \
        'xdebug.start_with_request=trigger' \
        'xdebug.trigger_value=1' \
        'xdebug.output_dir=/tmp/xdebug' \
        'xdebug.collect_return=1' \
        'xdebug.collect_params=4' \
        'xdebug.trace_format=0' \
        'xdebug.trace_options=0' \
        'xdebug.trace_output_name=trace.%t.%u' \
        'xdebug.log_level=0' \
        'xdebug.use_compression=false' \
    > /usr/local/etc/php/conf.d/99-xdebug.ini

COPY . .
RUN chown -R www-data:www-data /var/www/html \
 && ln -s . xvwa

# Configure database connection
RUN sed -i 's/localhost/db/g' config.php \
 && sed -i 's/"root"/"xvwa"/g' config.php \
 && sed -i 's/""/"pass"/g' config.php
