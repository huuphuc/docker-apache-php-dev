FROM ubuntu:20.04

MAINTAINER phucnh <phucbkit@gmail.com>

ARG PHP_VERSION=8.1
ENV DEBIAN_FRONTEND=noninteractive \
    WORKDIR=/var/www/dev

RUN apt update -y && apt -y upgrade \
    && apt install -y --no-install-recommends vim curl unzip git supervisor
RUN apt install -y gnupg software-properties-common \
    && add-apt-repository ppa:ondrej/php && apt update -y
RUN apt install -y --no-install-recommends \
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
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && mkdir -p ${WORKDIR} \
    && chown www-data:www-data ${WORKDIR} \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*


COPY ./configs/apache2.conf /etc/apache2/apache2.conf
COPY ./configs/app.conf /etc/apache2/sites-enabled/app.conf
COPY ./configs/php.ini /etc/php/${PHP_VERSION}/apache2/conf.d/custom.ini
COPY ./configs/supervisor.conf /etc/supervisor/conf.d/dev.conf

EXPOSE 80/tcp \
       443/tcp

CMD ["/usr/bin/supervisord"]
