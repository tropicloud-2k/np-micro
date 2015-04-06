get_wp_domain() {
	echo -ne "\033[0;34m  Domain Name: \n\n"
	echo -ne "\033[1;37m  http://"
	read WP_DOMAIN & echo ""
}

get_wp_mail() {
	echo -ne "\033[0;34m  WP Email: \033[1;37m"
	read WP_MAIL && echo ""
}

get_wp_user() {
	echo -ne "\033[0;34m  WP User: \033[1;37m"
	read WP_USER && echo ""
}

get_wp_pass() {
	echo -ne "\033[0;34m  WP Pass: \033[1;37m"
	read WP_PASS && echo ""
}

get_wp_ssl() {
	echo -ne "\033[0;34m  Enable SSL? [y/n]: \033[1;37m";
	read SSL
}

wp_install() {

	if [[  $@ == *' -d'*  ]];
	then WP_DOMAIN=$( echo $@ | grep -o '\-d.*' | awk '{print $2}' );
	else get_wp_domain;
	fi
	
	if [[  $@ == *' -u'*  ]];
	then WP_USER=$( echo $@ | grep -o '\-u.*' | awk '{print $2}' );
	else get_wp_user;
	fi
	
	if [[  $@ == *' -p'*  ]];
	then WP_PASS=$( echo $@ | grep -o '\-u.*' | awk '{print $2}' );
	else get_wp_pass;
	fi
	
	if [[  $@ == *' -m'*  ]];
	then WP_MAIL=$( echo $@ | grep -o '\-m.*' | awk '{print $2}' );
	else get_wp_mail;
	fi
	
	if [[  $@ == *'--ssl'*  ]];
	then SSL='true';
	else get_wp_ssl;
	fi
	
	# ------------------------
	# WP-CLI
	# ------------------------
	
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /usr/local/bin/wp
	chmod +x /usr/local/bin/wp
	
	# ------------------------
	# SSL CERT.
	# ------------------------

	cd $home/ssl
	
	cat $np/etc/nginx/openssl.conf | sed "s/localhost/$WP_DOMAIN/g" > openssl.conf

	openssl req -nodes -sha256 -newkey rsa:2048 -keyout app.key -out app.csr -config openssl.conf -batch
	openssl rsa -in app.key -out app.key
	openssl x509 -req -days 365 -sha256 -in app.csr -signkey app.key -out app.crt	

	rm -f openssl.conf
	
	# ------------------------
	# WP INSTALL
	# ------------------------

	cd $home/www && rm -rf $(ls)
	
	wp core download
	wp core config \
	   --dbname=${DB_NAME} \
	   --dbuser=${DB_USER} \
	   --dbpass=${DB_PASS} \
	   --dbhost=${DB_HOST}:${DB_PORT} \
	   --extra-php <<PHP
define('WPCACHEHOME', 'WPHOME/wp-content/plugins/wp-super-cache/');
define('DISALLOW_FILE_EDIT', true);
define('WP_CACHE', true);
PHP

	if [[  -z $WP_TITLE  ]];
	then WP_TITLE="NP-MICRO";
	fi

	if [[  $WP_SSL == "true"  ]];
	then WP_URL="https://${WP_DOMAIN}";
	else WP_URL="http://${WP_DOMAIN}";
	fi

   	wp core install \
 	   --url=$WP_URL \
 	   --title=$WP_TITLE \
 	   --admin_name=$WP_USER \
 	   --admin_email=$WP_MAIL \
 	   --admin_password=$WP_PASS
 	   
   	sed -i "s|WPHOME|$home/www|g" wp-config.php && mv wp-config.php ../
 	   
	# ------------------------
	# PERMISSIONS
	# ------------------------

	chown $user:nginx -R $home && chmod 775 -R $home
}
