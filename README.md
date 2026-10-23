# apache-php-dev

Apache 2.4 + PHP (mod_php) on Ubuntu 22.04, for **local development**.
Docker Hub: [`huuphuc/apache-php-dev`](https://hub.docker.com/r/huuphuc/apache-php-dev)

> **Development only.** Errors are displayed in the browser (`display_errors = On`,
> `error_reporting = E_ALL`) and the image ships build tools (`php-dev`, `git`, `vim`).
> Do not use it for staging or production.

## Tags

| Tag                          | Meaning                                                        |
| ---------------------------- | -------------------------------------------------------------- |
| `<php>` e.g. `8.2`           | Latest build of that PHP version. Moves on every rebuild.      |
| `<php>-<YYYYMMDD>` e.g. `8.2-20261023` | The build from that day. Pin this for reproducibility (only a rebuild on the same day replaces it). |
| `latest`                     | The default PHP version (currently `8.2`).                     |

Older `<php>-v1.0` tags (e.g. `8.2-v1.0`) are no longer updated.

## Quick start

Mount your project at `/var/www/dev`. Apache serves **`/var/www/dev/public`**, so your
project needs a `public/` directory (Laravel, Symfony and most frameworks already have one).

```bash
docker run --rm -p 8080:80 -v "$PWD:/var/www/dev" huuphuc/apache-php-dev:8.2
```

Open http://localhost:8080. Without a mount you get a placeholder page showing the PHP version.

With Docker Compose:

```yaml
services:
  php:
    image: huuphuc/apache-php-dev:8.2
    volumes:
      - .:/var/www/dev
    ports:
      - "127.0.0.1:8080:80"
```

Run commands inside the container (the working directory is `/var/www/dev`):

```bash
docker compose exec php composer install
docker compose exec php php -v
```

## What's included

- Apache 2.4 with `mod_rewrite`. `AllowOverride All` is set, so `.htaccess` files work.
- PHP extensions: `mbstring`, `zip`, `intl`, `xml`, `curl`, `gd`, `mysql` (mysqli/PDO), `bcmath`, `bz2`, `readline`, `opcache`.
- PECL tooling: `php-pear` and `php<version>-dev`, so `pecl install <ext>` works.
- Composer 2, git, curl, unzip, vim.

## Configuration

**PHP settings.** The image's overrides live in `/etc/php/<version>/{apache2,cli}/conf.d/custom.ini`
(see [`configs/php.ini`](configs/php.ini)): short open tags on, errors displayed, 64M upload/post limit.
To change them, mount your own ini file into both directories, for example
`-v ./my.ini:/etc/php/8.2/apache2/conf.d/zz-my.ini`. Restart the container after changing it.

**Logs.** Apache access and error logs, including PHP errors, are written to the container output.
View them with `docker logs <container>` or `docker compose logs php`.

**Processes.** Apache runs under supervisord and is restarted automatically if it crashes. To run
extra processes, such as a queue worker, add a program file to `/etc/supervisor/conf.d/`.

**File ownership.** Apache runs as `www-data` (uid 33). `docker exec` runs as `root`, so files it
creates in a bind mount (for example `vendor/` after `composer install`) are owned by root on Linux
hosts. Use `docker compose exec -u www-data php ...`, or fix ownership afterwards, if that matters to you.

**HTTPS** is not configured. Only port 80 is served.

## Building

```bash
./build.sh            # build the default version (ARG PHP_VERSION in the Dockerfile), test it, push it
./build.sh 8.3        # build, test and push PHP 8.3
NO_PUSH=1 ./build.sh 8.3   # build and test only; nothing is pushed
./test.sh 8.3         # smoke-test the locally built "apache-php-dev" image
```

`build.sh` pushes to Docker Hub only after `test.sh` passes. It pushes `<php>` and `<php>-<YYYYMMDD>`,
and `latest` only when building the default version. You need to be logged in (`docker login`)
to push.
