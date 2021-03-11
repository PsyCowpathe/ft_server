FROM debian:buster

#Instalation de l'environement

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y \
&& apt-get upgrade -y \
&& apt-get install sudo -y \
&& apt-get install systemd -y \
&& apt-get install wget -y \
&& apt-get install curl -y

#Creation d'un utilisateur avec privileges sudo

RUN useradd -ms /bin/bash mysqluser \
&& adduser mysqluser sudo \
&& passwd -d mysqluser

#Instalation de Nginx

RUN sudo apt install nginx -y

#Instalation et initialisation de Mysql

COPY srcs/init.sql /etc/init.d/init.sql

RUN su - mysqluser \
&& sudo apt install mariadb-server -y \
&& sudo service mysql start \
&& mysql -u root < /etc/init.d/init.sql

#Instalation de PhpMyAdmin et creation de la db

COPY srcs/default /etc/nginx/sites-available/default

RUN su - mysqluser \
&& sudo apt-get install php-fpm --no-install-recommends -y \
&& sudo apt-get install php-mysqli php-xml -y \
&& cd /var/www/html/ \
&& mkdir phpmyadmin \
&& cd phpmyadmin \
&& wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-english.tar.gz \
&& tar xzf phpMyAdmin* --strip-components=1 \
&& mv config.sample.inc.php config.inc.php

COPY srcs/config.inc.php /var/www/html/phpmyadmin/config.inc.php

#Instalation de Wordpress

RUN cd /var/www/html/ \
&& sudo curl -O https://wordpress.org/latest.tar.gz \
&& sudo tar -xvf latest.tar.gz \
&& rm -rf latest.tar.gz

COPY srcs/wp-config.php /var/www/html/wordpress/wp-config.php

#Mise en place du protocol SSL

RUN cd && mkdir local_ssl \
&& cd local_ssl

COPY srcs/open_ssl.conf /root/local_ssl/open_ssl.conf

RUN cd /root/local_ssl \
&& openssl req -x509 -nodes -days 1024 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config open_ssl.conf -extensions 'v3_req' \
&& sudo cp localhost.crt /etc/ssl/certs/localhost.crt \
&& sudo cp localhost.key /etc/ssl/private/localhost.key

#Demarage du container

ENTRYPOINT cd /etc/init.d && service nginx start && service mysql start && service php7.3-fpm start && /bin/sh

EXPOSE 80 443
