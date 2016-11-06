#!/bin/bash

# include parent entrypoint script
source /tomcat.sh

# set environment variables
if [ -z $PASSPHRASE ]
then 
	PASSPHRASE='w3bp@$$w0rd$@f3k3y'
fi

if [ -z $DB_TYPE ]
then
	DB_TYPE="hsqldb"
fi

if [ -z $DB_HOST ]
then
	if [ -n "$MYSQL_PORT_3306_TCP_ADDR" ]
	then
		DB_HOST="$MYSQL_PORT_3306_TCP_ADDR"
	else 
		DB_HOST="pwsafe-mysql"
	fi
fi

if [ -z $DB_PORT ]
then
	if [ -n "$MYSQL_PORT_3306_TCP_PORT" ]
	then 
		DB_PORT="$MYSQL_PORT_3306_TCP_PORT"
	else
		DB_PORT="3306"
	fi 
fi

if [ -z $DB_NAME ]
then 
	if [ -n "$MYSQL_ENV_MYSQL_DATABASE" ]
	then
		DB_NAME="$MYSQL_ENV_MYSQL_DATABASE"
	else
		DB_NAME="pwsafe"
	fi
fi

if [ -z $DB_USER ]
then 
	if [ -n "$MYSQL_ENV_MYSQL_USER" ]
	then
		DB_USER="$MYSQL_ENV_MYSQL_USER"
	else
		DB_USER="pwsafe"
	fi
fi

if [ -z $DB_PASS ]
then 
	if [ -n "$MYSQL_ENV_MYSQL_PASSWORD" ]
	then
		DB_PASS="$MYSQL_ENV_MYSQL_PASSWORD"
	else
		DB_PASS="my-password"
	fi
fi

# set db dialect and db driver class name by db type
case "$DB_TYPE" in
	hsqldb)
		DB_URL="jdbc:hsqldb:file:/data/webpasswordsafedb"
		DB_DIALECT="org.hibernate.dialect.HSQLDialect"
		DB_DRIVER="org.hsqldb.jdbcDriver"
		DB_VALIDATION_QUERY="select 1 from INFORMATION_SCHEMA.SYSTEM_USERS"
	;;
	mssql)
		DB_URL="jdbc:jtds:sqlserver//$DB_HOST:$DB_PORT/$DB_NAME"
		DB_DIALECT="org.hibernate.dialect.SQLServerDialect"
		DB_DRIVER="net.sourceforge.jtds.jdbc.Driver"
		DB_VALIDATION_QUERY="select 1"
	;;
	mysql)
		DB_URL="jdbc:mysql://$DB_HOST:$DB_PORT/$DB_NAME"
		DB_DIALECT="org.hibernate.dialect.MySQL5InnoDBDialect"
		DB_DRIVER="com.mysql.jdbc.Driver"
		DB_VALIDATION_QUERY="select 1"
	;;
	postgresql)
		DB_URL="jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME"
		DB_DIALECT="org.hibernate.dialect.PostgreSQLDialect"
		DB_DRIVER="org.postgresql.Driver"
		DB_VALIDATION_QUERY="select 1"
	;;
	*)
		echo "ERROR: The db type '$DB_TYPE' is not supported"
		exit 1
	;;
esac

# wait for database port to be opened
if [ "$DB_TYPE" != "hsqldb" ]
then
	while ! nc -z $DB_HOST $DB_PORT; do sleep 1; done
fi

# set config file variables
CONFIG_FOLDER="$TOMCAT_WEBAPPS_FOLDER/webpasswordsafe/WEB-INF"
ENCRYPTION_CONFIG_FILE="$CONFIG_FOLDER/encryption.properties"
JDBC_CONFIG_FILE="$CONFIG_FOLDER/jdbc.properties"

# change jasypt encryptor password in config file
sed -i 's|'encryptor.jasypt.password=.*'|'encryptor.jasypt.password=$PASSPHRASE'|' $ENCRYPTION_CONFIG_FILE

# change jdbc settings in config file
sed -i 's|'jdbc.username=.*'|'jdbc.username=$DB_USER'|' $JDBC_CONFIG_FILE
sed -i 's|'jdbc.password=.*'|'jdbc.password=$DB_PASS'|' $JDBC_CONFIG_FILE
sed -i 's|'jdbc.driverClassName=.*'|'jdbc.driverClassName=$DB_DRIVER'|' $JDBC_CONFIG_FILE
sed -i 's|'jdbc.url=.*'|'jdbc.url=$DB_URL'|' $JDBC_CONFIG_FILE
sed -i 's|'jdbc.validationQuery=.*'|'jdbc.validationQuery="$DB_VALIDATION_QUERY"'|' $JDBC_CONFIG_FILE
sed -i 's|'hibernate.dialect=.*'|'hibernate.dialect=$DB_DIALECT'|' $JDBC_CONFIG_FILE

# execute command
exec "$@"
