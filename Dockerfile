#
# Builder 
# Copy from Abiosoft/caddy-docker
#
FROM benzbrake/caddy:builder as builder

ARG version="1.0.3"
ARG caddy_plugins="git,cors,realip,filter,expires,cache,cloudflare"
ARG enable_telemetry="false"

# PHP Build ARGS
ARG php_plugins="php7-mysqli,php7-pdo_mysql,php7-mbstring,php7-json,php7-zlib,php7-gd,php7-intl,php7-session,php7-memcached,php7-ctype"

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${caddy_plugins} ENABLE_TELEMETRY=${enable_telemetry} /bin/sh /usr/bin/builder.sh

#
# Final stage
#
FROM benzbrake/alpine
LABEL maintainer "Ryan Lieu <github-benzBrake@woai.ru>"

ARG version="1.0.3"
LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

# Telemetry Stats
ENV ENABLE_TELEMETRY="$enable_telemetry"

# PHP PLUGINS
ENV PHP_PLUGINS="$php_plugins"

RUN mkdir -pv /www/wwwroot/default
COPY html/index.html /www/wwwroot/default/
COPY html/404.html /www/wwwroot/default/
COPY html/phpinfo.php /www/wwwroot/default/
COPY Caddyfile /etc/

# trust this project public key to trust the packages.
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# Install Caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# Install process wrapper
COPY --from=builder /go/bin/parent /bin/parent

# Install PHP
RUN apk add --update --no-cache openssl curl git&& \
    echo "@php https://dl.bintray.com/php-alpine/v3.9/php-7.3" >> /etc/apk/repositories && \
    apk add --update --no-cache php7-cli@php && \
    apk add --update --no-cache php7-fpm@php && \
    for name in $(echo ${PHP_PACKAGES} | sed "s#,#\n#g"); do apk add --update --no-cache ${name}@php ; done && \
    rm -rf /var/cache/apk/* /tmp/*

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins
RUN /usr/bin/php -v

EXPOSE 80 443
VOLUME /root/.caddy /www
WORKDIR /www

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]