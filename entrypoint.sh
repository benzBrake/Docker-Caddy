#!/bin/sh
# Set default value of variable CADDYPATH
[[ -z ${CADDYPATH} ]] && export CADDYPATH=/data/caddy
[[ -z ${TZ} ]] && export TZ=Asia/Shanghai
# Set timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
# Create necessary directories
mkdir -pv ${CADDYPATH}/logs ${CADDYPATH}/vhosts
# Create default Caddyfile
if [[ ! -f /etc/Caddyfile ]]; then
    cat > /etc/Caddyfile <<EOF
:80 {
    gzip
    timeouts 0
    root /html
    index index.html index.htm default.html default.htm index.php
    fastcgi / 127.0.0.1:9000 php
    log ${CADDYPATH}/logs/default.log
}
import vhosts/*.conf
EOF
fi
# Run php
/usr/sbin/php-fpm7
# Run caddy
/bin/caddy $@