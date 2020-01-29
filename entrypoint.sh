#!/bin/sh
# Run php
/usr/sbin/php-fpm7
# Run caddy
/bin/parent caddy $@