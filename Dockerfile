FROM benzbrake/alpine:3.9
MAINTAINER Ryan Lieu <github-benzBrake@woai.ru>
ARG CADDY_ARCH="amd64"
ARG CADDY_PLUGIN="http.cache,http.filter,http.nobots,http.ratelimit,http.realip,tls.dns.cloudflare"
ARG CADDY_LICENSE="personal"
ARG CADDY_ACCOUNT_ID
ARG CADDY_API_KEY
ENV CADDYPATH=/data/caddy TZ=Asia/Shanghai

ADD html /html
ADD entrypoint.sh /bin/
RUN apk add --update --no-cache openssl curl && \
    curl -L "https://caddyserver.com/download/linux/${CADDY_ARCH}?plugins=${CADDY_PLUGIN}&license=${CADDY_LICENSE}&telemetry=off" -u "${CADDY_ACCOUNT_ID}:${CADDY_API_KEY}" -o "/tmp/caddy.tgz" && \
    cd /tmp && \
    tar xvf caddy.tgz && \
    mv caddy /bin/caddy && \
    chmod +x /bin/caddy && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    chmod +x /bin/entrypoint.sh
CMD ["-conf=/etc/Caddyfile", "--log=stdout", "--agree=true"]
ENTRYPOINT ["entrypoint.sh"]
