FROM ubuntu:22.04

LABEL org.opencontainers.image.authors="huuphuc <phucbkit@gmail.com>" \
      org.opencontainers.image.description="Apache + PHP (mod_php) image for local development" \
      org.opencontainers.image.source="https://github.com/huuphuc/docker-apache-php-dev"

ENV DEBIAN_FRONTEND=noninteractive \
    WORKDIR=/var/www/dev

# Base tools + ondrej/php PPA. Kept independent of PHP_VERSION so this layer
# is shared between builds of different PHP versions.
RUN apt-get update -y && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
       ca-certificates vim curl unzip git make supervisor \
       gnupg2 software-properties-common \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get purge -y --auto-remove software-properties-common gnupg2 \
    && rm -rf /var/lib/apt/lists/*

ARG PHP_VERSION=8.5

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    apache2 \
    php${PHP_VERSION} \
    php-pear \
    libapache2-mod-php${PHP_VERSION} \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-bz2 \
    php${PHP_VERSION}-dev \
    && rm -rf /etc/apache2/sites-enabled/000-default.conf /var/www/html \
    && a2enmod rewrite \
    && ln -sfT /dev/stderr /var/log/apache2/error.log \
    && ln -sfT /dev/stdout /var/log/apache2/access.log \
    && a2disconf other-vhosts-access-log \
    && mkdir -p ${WORKDIR}/public \
    && chown -R www-data:www-data ${WORKDIR} \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY ./configs/apache2.conf /etc/apache2/apache2.conf
COPY ./configs/app.conf /etc/apache2/sites-enabled/app.conf
COPY ./configs/php.ini /etc/php/${PHP_VERSION}/apache2/conf.d/custom.ini
COPY ./configs/php.ini /etc/php/${PHP_VERSION}/cli/conf.d/custom.ini
COPY ./configs/supervisor.conf /etc/supervisor/conf.d/dev.conf
COPY --chown=www-data:www-data ./public/ ${WORKDIR}/public/

WORKDIR ${WORKDIR}

EXPOSE 80/tcp

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
