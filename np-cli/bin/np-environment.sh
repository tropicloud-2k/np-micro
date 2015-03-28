np_environment() {
	
	# ------------------------
	# DATABASE URL
	# ------------------------
	
	if [[  -z $DATABASE_URL  ]]; then
	
		DB_HOST=$(env | grep '_PORT_3306_TCP_ADDR' | cut -d= -f2)
		DB_PORT=$(env | grep '_PORT_3306_TCP_PORT' | cut -d= -f2)
		DB_PRTO=$(env | grep '_PORT_3306_TCP_PROTO' | cut -d= -f2)
		DB_NAME=$(env | grep '_ENV_MYSQL_DATABASE' | cut -d= -f2)
		DB_USER=$(env | grep '_ENV_MYSQL_USER' | cut -d= -f2)
		DB_PASS=$(env | grep '_ENV_MYSQL_PASSWORD' | cut -d= -f2)
		
		if [[  ! -z $DB_HOST  ]]; then export DB_HOST=$DB_HOST; fi
		if [[  ! -z $DB_PORT  ]]; then export DB_PORT=$DB_PORT; fi
		if [[  ! -z $DB_PRTO  ]]; then export DB_PRTO=$DB_PRTO; fi
		if [[  ! -z $DB_NAME  ]]; then export DB_NAME=$DB_NAME; fi
		if [[  ! -z $DB_USER  ]]; then export DB_USER=$DB_USER; fi
		if [[  ! -z $DB_PASS  ]]; then export DB_PASS=$DB_PASS; fi
		
		export DATABASE_URL=${DB_PRTO}://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}
		
	else
	
		DB_HOST=$(env | grep 'DATABASE_URL' | cut -d@ -f2 | cut -d: -f1)
		DB_PORT=$(env | grep 'DATABASE_URL' | cut -d@ -f2 | cut -d: -f2 | cut -d/ -f1)
		DB_PRTO=$(env | grep 'DATABASE_URL' | cut -d= -f2 | cut -d: -f1)
		DB_NAME=$(env | grep 'DATABASE_URL' | cut -d@ -f2 | cut -d\/ -f2)
		DB_USER=$(env | grep 'DATABASE_URL' | cut -d: -f2 | sed 's|//||g')
		DB_PASS=$(env | grep 'DATABASE_URL' | cut -d: -f3 | cut -d@ -f1)
		
		if [[  ! -z $DB_HOST  ]]; then export DB_HOST=$DB_HOST; fi
		if [[  ! -z $DB_PORT  ]]; then export DB_PORT=$DB_PORT; fi
		if [[  ! -z $DB_PRTO  ]]; then export DB_PRTO=$DB_PRTO; fi
		if [[  ! -z $DB_NAME  ]]; then export DB_NAME=$DB_NAME; fi
		if [[  ! -z $DB_USER  ]]; then export DB_USER=$DB_USER; fi
		if [[  ! -z $DB_PASS  ]]; then export DB_PASS=$DB_PASS; fi
			
	fi
	
	export HOME=/app
	export TERM=xterm

	# ------------------------
	# ENV SETUP
	# ------------------------

	echo "" > /etc/environment
	env | grep = >> /etc/environment

	if [[  -d '/etc/env'  ]];
	then rm -f /etc/env/*
	else mkdir -p /etc/env
	fi

	cat $np/etc/php/php-fpm.conf > /etc/php/php-fpm.conf

	for var in $(cat /etc/environment); do 
		key=$(echo $var | cut -d= -f1)
		val=$(echo $var | cut -d= -f2)
		echo -ne $val > /etc/env/${key}
		echo -e "env[$key] = '$val'" >> /etc/php/php-fpm.conf
	done
	
	chown root:nginx /etc/environment && chmod 750 /etc/environment
	chown root:nginx -R /etc/env && chmod 750 -R /etc/env

}
