#!/bin/sh
# Install External PHP Extensions
if [ -d /www/php-extensions ]; then
	cd /www/php-extensions
       	exts=`ls -al | grep -v ^d | awk '{print $9}'`
	echo -e "\n" >> /etc/php7/php.ini
	for e in $exts; do
		grep "/www/php-extensions/${e}" /etc/php7/php.ini &> /dev/null
		if [ $? -ne 0 ]; then
			echo 'extension=/www/php-extensions/'${e} >> /etc/php7/php.ini
		fi
	done
	cd -
fi
# Run php
/usr/sbin/php-fpm7
# Run caddy
/usr/bin/caddy $@