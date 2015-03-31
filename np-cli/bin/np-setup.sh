np_setup() {

	# ------------------------
	# INSTALL
	# ------------------------
	
	apk add --update \
	    mysql-client \
	    nginx \
	    openssl \
	    php-bz2 \
	    php-curl \
	    php-fpm \
	    php-ftp \
	    php-gd \
	    php-gettext \
	    php-mcrypt \
	    php-memcache \
	    php-mysql \
	    php-opcache \
	    php-openssl \
	    php-phar \
	    php-pear \
 	    php-pdo \
 	    php-pdo_pgsql \
 	    php-pdo_sqlite \
 	    php-pdo_mysql \
	    php-xml \
	    php-zlib \
	    php-zip \
	    nano curl wget
	                 
	rm -rf /var/cache/apk/*
                
	## WP-CLI
	wget -nv -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x /usr/local/bin/wp
	
	## JQ 
	wget -nv -O /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq
	chmod +x /usr/local/bin/jq
	
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
	cp $home/.profile /root/.profile
	
	cat $np/etc/html/index.html > $home/www/index.html
	cat $np/etc/html/info.php > $home/www/info.php	
	cat $np/etc/php/php-fpm.conf > /etc/php/php-fpm.conf
	
	for file in $(ls $np/etc/nginx); do cat $np/etc/nginx/$file > /etc/nginx/$file; done
	ln -s /etc/nginx/default.conf /app/app.conf
		
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

	chmod +x $np/np && ln -s $np/np /usr/bin/np
	chown $user:nginx -R $home && chmod 775 -R $home
}
