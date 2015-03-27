nps_setup() {

	chmod +x /usr/local/nps/nps && ln -s /usr/local/nps/nps /usr/bin/nps

	# ------------------------
	# INSTALL
	# ------------------------
	
	## Dependecies
	apk-install curl openssl apk-cron

	## NGINX
	apk-install nginx
	               
	## PHP
	apk-install php-fpm \
                php-opcache \
                php-mysql \
                php-pgsql \
                php-gd \
                php-mcrypt
	               
	## WP-CLI
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /usr/local/bin/wp
	chmod +x /usr/local/bin/wp
	
	## JQ 
	curl -O http://stedolan.github.io/jq/download/linux64/jq > /usr/local/bin/jq
	chmod +x /usr/local/bin/jq
	
	# ------------------------
	# CHROOT USER
	# ------------------------
		
# 	useradd -g nginx -d $home -s /bin/false npstack
# 	echo "source /etc/environment" >> $home/.bashrc
# 	chown root:root $home && chmod 755 $home

	mkdir -p $home/www
	mkdir -p $home/ssl
		
	# ------------------------
	# CONFIG
	# ------------------------

	cat $nps/etc/nginx/default.conf > /etc/nginx/default.conf
	cat $nps/etc/php/php-fpm.conf > /etc/php/php-fpm.conf
	cat $nps/etc/nginx/nginx.conf > /etc/nginx/nginx.conf
	cat $nps/etc/html/index.html > $home/www/index.html
	cat $nps/etc/html/info.php > $home/www/info.php

	# ------------------------
	# SSL CERT.
	# ------------------------
	
	cd $home/ssl
	
	cat $nps/etc/nginx/openssl.conf > openssl.conf
	openssl req -nodes -sha256 -newkey rsa:2048 -keyout app.key -out app.csr -config openssl.conf -batch
	openssl rsa -in app.key -out app.key
	openssl x509 -req -days 365 -sha256 -in app.csr -signkey app.key -out app.crt
	rm -f openssl.conf
	
	# ------------------------
	# FIX PERMISSIONS
	# ------------------------

	chown nginx:nginx -R $home/* && chmod 755 -R $home/*
}
