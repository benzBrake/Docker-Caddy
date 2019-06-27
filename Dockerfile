FROM benzbrake/alpine:3.9
MAINTAINER Ryan Lieu <github-benzBrake@woai.ru>

# Cadddy Build ARGS
ARG CADDY_ARCH="amd64"
ARG CADDY_PLUGIN="http.cache,http.filter,http.nobots,http.ratelimit,http.realip,tls.dns.cloudflare"
ARG CADDY_LICENSE="personal"
ARG CADDY_ACCOUNT_ID
ARG CADDY_API_KEY

# PHP Build ARGS
ARG PHP_PACKAGES="php7-mysqli,php7-pdo_mysql,php7-mbstring,php7-json,php7-zlib,php7-gd,php7-intl,php7-session,php7-memcached"
# Runtime ENV
ENV CADDYPATH=/data/caddy TZ=Asia/Shanghai

ADD html /html
ADD entrypoint.sh /bin
# trust this project public key to trust the packages.
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# Install Caddy
RUN apk add --update --no-cache openssl curl && \
    curl -L "https://caddyserver.com/download/linux/${CADDY_ARCH}?plugins=${CADDY_PLUGIN}&license=${CADDY_LICENSE}&telemetry=off" -u "${CADDY_ACCOUNT_ID}:${CADDY_API_KEY}" -o "/tmp/caddy.tgz" && \
    cd /tmp && \
    tar xvf caddy.tgz && \
    mv caddy /bin/caddy && \
    chmod +x /bin/caddy && \
    chmod +x /bin/entrypoint.sh && \
    echo "@php https://dl.bintray.com/php-alpine/v3.9/php-7.3" >> /etc/apk/repositories && \
    apk add --update --no-cache php7-cli@php && \
    apk add --update --no-cache php7-fpm@php && \
    for name in $(echo ${PHP_PACKAGES} | sed "s#,#\n#g"); do apk add --update --no-cache ${name}@php ; done && \
    rm -rf /var/cache/apk/* /tmp/*

CMD ["-conf=/etc/Caddyfile", "--log=stdout", "--agree=true"]
ENTRYPOINT ["/bin/entrypoint.sh"]
