FROM ubuntu:18.04

MAINTAINER phucnh <phucbkit@gmail.com>

ENV PHP=7.3 \
    DEBIAN_FRONTEND=noninteractive \
    WORKDIR=/var/www/dev \
    PHP_PATH=/etc/php/7.3 \
    APACHE_PATH=/etc/apache2 \
    SUPEVISOR_CONF=/etc/supervisor/conf.d

RUN apt-get update -y && apt-get -y dist-upgrade \
    && apt-get install -y gnupg software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y --no-install-recommends vim curl unzip git supervisor \
    && apt-get install -y --no-install-recommends \
    apache2 \
    php${PHP} \
    php-pear \
    libapache2-mod-php${PHP} \
    php${PHP}-cli \
    php${PHP}-readline \
    php${PHP}-mbstring \
    php${PHP}-zip \
    php${PHP}-intl \
    php${PHP}-xml \
    php${PHP}-json \
    php${PHP}-curl \
    php${PHP}-gd \
    php${PHP}-mysql \
    php${PHP}-bcmath \
    php${PHP}-bz2 \
    php${PHP}-dev \
    && rm -rf ${APACHE_PATH}/sites-enabled/000-default.conf /var/www/html \
    && a2enmod rewrite \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && mkdir -p ${WORKDIR} \
    && chown www-data:www-data ${WORKDIR} \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*


COPY ./configs/apache2.conf ${APACHE_PATH}/apache2.conf
COPY ./configs/app.conf ${APACHE_PATH}/sites-enabled/app.conf
COPY ./configs/php.ini ${PHP_PATH}/apache2/conf.d/custom.ini
COPY ./configs/supervisor.conf ${SUPEVISOR_CONF}/dev.conf

EXPOSE 80/tcp \
       443/tcp

CMD ["/usr/bin/supervisord"]
