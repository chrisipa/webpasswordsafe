Manual Installation
===================

Prerequisites
-------------
* [Java 6](http://www.oracle.com/technetwork/java/javase/downloads/index.html) must be installed
* [JCE](http://www.oracle.com/technetwork/java/javase/downloads/jce-6-download-429243.html) must be installed
* Web application server (e.g. tomcat) must be installed

Installation
-------------
* Download and extract the war file to webapps folder:
```
cd /opt/tomcat/webapps
wget https://papke.it/jenkins/job/webpasswordsafe/lastStableBuild/net.webpasswordsafe%24webpasswordsafe/artifact/net.webpasswordsafe/webpasswordsafe/1.4.1/webpasswordsafe-1.4.1.war -O webpasswordsafe.war
mkdir webpasswordsafe
unzip webpasswordsafe.war -d webpasswordsafe
rm webpasswordsafe.war
```
* Change master password:
```
nano /opt/tomcat/webapps/webpasswordsafe/WEB-INF/encryption.properties

encryptor.jasypt.password=xxxxxxxxxxxxxxxxxxxx
```
* By default the applicaton is using a HSQL database

Installation (MySQL)
-------------
* Install required os packages:
```
sudo apt-get install mysql-server
```
* Create mysql database and system user:
```
CREATE DATABASE webpasswordsafe CHARACTER SET utf8;
CREATE USER 'wps'@'localhost' IDENTIFIED BY 'xxxxxxxxxxx';
GRANT ALL PRIVILEGES ON webpasswordsafe.* TO 'wps'@'localhost';
```
* Download mysql JDBC connector to lib folder:
```
cd /opt/tomcat/webapps/webpasswordsafe/WEB-INF/lib
wget http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.28/mysql-connector-java-5.1.28.jar
```
* Configure mysql in hibernate settings:
```
nano /opt/tomcat/webapps/webpasswordsafe/WEB-INF/jdbc.properties

# Common settings
jdbc.username=wps
jdbc.password=xxxxxxxxxxx

# HSQL settings
#hibernate.dialect=org.hibernate.dialect.HSQLDialect
#jdbc.driverClassName=org.hsqldb.jdbcDriver
#jdbc.url=jdbc:hsqldb:file:/tmp/webpasswordsafedb
#jdbc.url=jdbc:hsqldb:hsql://localhost/
#jdbc.validationQuery=select 1 from INFORMATION_SCHEMA.SYSTEM_USERS

# MySQL/MariaDB settings
hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/webpasswordsafe
jdbc.validationQuery=select 1
```

Installation (Mobile-Fronted)
-------------
* This web application is not optimized for mobile devices
* There is an alternative web frontend called [pwsafe-mobile](https://github.com/chrisipa/pwsafe-mobile) which is using the RESTful web service interface for some basic functionalities