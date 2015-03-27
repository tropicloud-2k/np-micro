np_setup() {

	chmod +x /usr/local/np-cli/np && ln -s /usr/local/np-cli/np /usr/bin/np

	# ------------------------
	# INSTALL
	# ------------------------
	
	apk-install nginx \
	            openssl \
	            php-fpm \
	            php-opcache \
	            php-mcrypt \
	            php-curl \
	            php-zlib \
	            php-pdo \
	            php-gd \
	            php-gettext \
	            php-mysql \
	            php-xml \
	            php-zip
                
	# ------------------------
	# CHROOT USER
	# ------------------------
		
	adduser -G nginx -h $home -D $user
	echo "source /etc/environment" >> $home/.bashrc
	echo "$user    ALL=(ALL) ALL" >> /etc/sudoers
	chown root:root $home && chmod 755 $home

	mkdir -p $home/www
	mkdir -p $home/ssl
	mkdir -p $home/run
		
	# ------------------------
	# CONFIG
	# ------------------------

	cat $np/etc/nginx/default.conf > /etc/nginx/default.conf
	cat $np/etc/php/php-fpm.conf > /etc/php/php-fpm.conf
	cat $np/etc/nginx/nginx.conf > /etc/nginx/nginx.conf

	cat $np/etc/html/index.html > $home/www/index.html
	cat $np/etc/html/info.php > $home/www/info.php
	
	cp -R $np/etc/s6/* /app/run
	
	# ------------------------
	# SSL CERT.
	# ------------------------
	
	cd $home/ssl
	
	cat $np/etc/nginx/openssl.conf > openssl.conf
	openssl req -nodes -sha256 -newkey rsa:2048 -keyout app.key -out app.csr -config openssl.conf -batch
	openssl rsa -in app.key -out app.key
	openssl x509 -req -days 365 -sha256 -in app.csr -signkey app.key -out app.crt
	rm -f openssl.conf
	
	# ------------------------
	# FIX PERMISSIONS
	# ------------------------

	chown $user:nginx -R $home/* && chmod 755 -R $home/*
}
