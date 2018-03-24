FROM ubuntu:xenial
MAINTAINER 9to6 <ktk0011+dev@gmail.com>

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade

# Mariadb Settings
RUN apt-get install -y software-properties-common

RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \
    add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.kaist.ac.kr/mariadb/repo/10.2/ubuntu xenial main' && \
	apt-get update && \
    apt-get install -y mariadb-server
RUN apt-get install -y mariadb-client
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# Basic Requirements
RUN apt-get install -y curl git unzip php php7.0-fpm php7.0-mysql php7.0-curl php7.0-gd php-apcu php7.0-zip vim wget pwgen

# Nginx Settings
RUN echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list
RUN echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list
RUN wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key && \
	apt-get update && apt-get install -y nginx

RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 500m/" /etc/nginx/nginx.conf
RUN sed -i -e"s/user\s*nginx;/user  www-data;/" /etc/nginx/nginx.conf

# nginx site conf
ADD ./nginx-site.conf /etc/nginx/conf.d/default.conf

# php-fpm Settings
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 500M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 500M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -i "s/pm = dynamic/pm = ondemand/" /etc/php/7.0/fpm/pool.d/www.conf
RUN find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;
RUN mkdir -p /run/php

## Supervisor Settings

RUN apt-get install -y python-setuptools
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# Install Wordpress
ADD https://wordpress.org/latest.tar.gz /usr/share/nginx/latest.tar.gz
RUN cd /usr/share/nginx/ && tar xvf latest.tar.gz && rm latest.tar.gz
RUN mkdir -p /usr/share/nginx/errors
ADD https://raw.githubusercontent.com/AndiDittrich/HttpErrorPages/master/dist/pages.tar /usr/share/nginx/errors/pages.tar
RUN cd /usr/share/nginx/errors/ && tar xvf pages.tar && rm pages.tar
#RUN find . -maxdepth 1 -name "HTTP*.html" | sed -e 'p' -e "s/HTTP//g" |xargs -n 2 mv
RUN mv /usr/share/nginx/wordpress /usr/share/nginx/www
RUN mv /usr/share/nginx/errors /usr/share/nginx/www/
# for plugins
RUN sed -i -e "s/define('DB_COLLATE', '');/define('DB_COLLATE', '');\r\ndefine('FS_METHOD', 'direct');/" /usr/share/nginx/www/wp-config-sample.php

RUN usermod -u 1000 www-data
RUN usermod -G staff www-data
RUN chown -R www-data:www-data /usr/share/nginx/www

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 3306
EXPOSE 9001
EXPOSE 80

# volume for mysql database and wordpress install
VOLUME ["/var/lib/mysql", "/usr/share/nginx/www"]

CMD ["/bin/bash", "/start.sh"]
