# Mod from abiosoft
#
# Builder 
# Copy from Abiosoft/caddy-docker
#
FROM benzbrake/caddy:builder as builder

ARG version="1.0.4"
ARG caddy_plugins="git,cors,realip,filter,expires,cache,cloudflare"
ARG enable_telemetry="false"

RUN env

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${caddy_plugins} ENABLE_TELEMETRY=${enable_telemetry} /bin/sh /usr/bin/builder.sh

#
# Final stage
#
FROM benzbrake/alpine
LABEL maintainer "Ryan Lieu <github-benzBrake@woai.ru>"

# PHP PLUGINS
ARG php_plugins="php7-mysqli,php7-pdo_mysql,php7-mbstring,php7-json,php7-zlib,php7-gd,php7-intl,php7-session,php7-memcached,php7-ctype"

# PHP user www's GID and UID
ARG PUID=1000
ARG PGID=1000

# Let's Encrypt Agreement
ENV ACME_AGREE="true"

# Telemetry Stats
ENV ENABLE_TELEMETRY="$enable_telemetry"

RUN mkdir -pv /www/wwwroot/default
COPY html/index.html /www/wwwroot/default/
COPY html/404.html /www/wwwroot/default/
COPY html/phpinfo.php /www/wwwroot/default/
COPY Caddyfile /etc/
COPY entrypoint.sh /bin/

# Install Caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# Install process wrapper
COPY --from=builder /go/bin/parent /bin/parent

# Install PHP
RUN set -x && env && \
    apk add --update --no-cache openssl curl git&& \
    apk add --update --no-cache php7-cli && \
    apk add --update --no-cache php7-fpm && \
    for name in $(echo ${php_plugins} | sed "s#,#\n#g"); do apk add --update --no-cache ${name} ; done && \
    chmod +x /bin/entrypoint.sh && \
    rm -rf /var/cache/apk/* /tmp/*

# Symlink php7 to php
RUN ln -sf /usr/bin/php7 /usr/bin/php

# Symlink php-fpm7 to php-fpm
RUN ln -sf /usr/bin/php-fpm7 /usr/bin/php-fpm

# Add a PHP www-user instead of nobody
RUN addgroup -g ${PGID} www-user && \
  adduser -D -H -u ${PUID} -G www-user www-user && \
  sed -i "s|^user = .*|user = www-user|g" /etc/php7/php-fpm.d/www.conf && \
sed -i "s|^group = .*|group = www-user|g" /etc/php7/php-fpm.d/www.conf


# Allow environment variable access
RUN echo "clear_env = no" >> /etc/php7/php-fpm.conf

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins
RUN /usr/bin/php -v

EXPOSE 80 443
VOLUME /root/.caddy /www
WORKDIR /www

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]