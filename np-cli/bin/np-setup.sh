np_setup() {

	# ------------------------
	# INSTALL
	# ------------------------
	
	apk add --update \
	    nginx \
	    openssl \
	    php-curl \
	    php-fpm \
	    php-ftp \
	    php-gd \
	    php-gettext \
	    php-mcrypt \
	    php-mysql \
	    php-opcache \
 	    php-pdo \
# 	    php-pdo_pgsql \
# 	    php-pdo_sqlite \
# 	    php-pdo_mysql \
	    php-xml \
	    php-zlib \
	    php-zip
	                 
	rm -rf /var/cache/apk/*
                
	# ------------------------
	# CONFIG
	# ------------------------
	
	adduser -D -G nginx -h $home -s /bin/sh $user
	
	cat >> $home/.profile <<"EOF"
for var in $(cat /etc/environment); do 
	key=$(echo $var | cut -d= -f1)
	val=$(echo $var | cut -d= -f2)
	export ${key}=${val}
done
EOF

	mkdir -p $home/log
	mkdir -p $home/run
	mkdir -p $home/ssl
	mkdir -p $home/www
		
	cp -R $np/etc/s6/* /app/run

	cat $np/etc/html/index.html > $home/www/index.html
	cat $np/etc/html/info.php > $home/www/info.php
	cat $np/etc/nginx/nginx.conf > /etc/nginx/nginx.conf
	cat $np/etc/nginx/default.conf > /etc/nginx/default.conf
	cat $np/etc/php/php-fpm.conf > /etc/php/php-fpm.conf
	
	# ------------------------
	# SSL
	# ------------------------
	
	cd $home/ssl
	
	cat $np/etc/nginx/openssl.conf > openssl.conf
	
	openssl req -nodes -sha256 -newkey rsa:2048 -keyout app.key -out app.csr -config openssl.conf -batch
	openssl rsa -in app.key -out app.key
	openssl x509 -req -days 365 -sha256 -in app.csr -signkey app.key -out app.crt
	
	rm -f openssl.conf
	
	# ------------------------
	# CHMOD
	# ------------------------

	chmod +x /usr/local/np-cli/np
	ln -s /usr/local/np-cli/np /usr/bin/np

	chown $user:nginx -R $home
	chmod 770 -R $home
}
