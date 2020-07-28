FROM golang:1.14-alpine as builder

ARG VERSION=2.1.0
ARG CADDY_PLUGINS=""

ADD builder.sh /
RUN chmod +x /builder.sh && /builder.sh

FROM benzbrake/alpine
LABEL maintainer "Ryan Lieu <github-benzBrake@woai.ru>"

# Install Caddy
COPY --from=builder /caddy /usr/bin/caddy

# Configure 
RUN mkdir -pv /www/wwwroot/default /www/wwwlogs/
COPY html/index.html /www/wwwroot/default/
COPY html/404.html /www/wwwroot/default/
COPY Caddyfile /etc/

# validate install
RUN /usr/bin/caddy version

# Ports, volumes, workdir
EXPOSE 80 443 2015
VOLUME /root/.caddy /www
WORKDIR /www

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=true"]