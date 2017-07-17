############################################################
# Dockerfile to build CentOS,Nginx installed  Container
# Based on CentOS
############################################################

# Set the base image to Ubuntu
FROM centos:7

# File Author / Maintainer
MAINTAINER Maju Ansari <majua@mindfiresolutions.com>

# Add the ngix and PHP dependent repository
ADD nginx.repo /etc/yum.repos.d/nginx.repo

# Installing nginx
RUN yum -y install nginx

# Installing PHP
RUN \
	yum -y install epel-release && \
	rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
	yum-config-manager --enable remi && \
	yum-config-manager --disable remi-php55 && \
	yum-config-manager --disable remi-php56 && \
	yum-config-manager --disable remi-php70 && \
	yum-config-manager --enable remi-php71 && \
	yum clean all

RUN yum -y install php-cli php-dev php-pgsql \
    php-sqlite3 php-gd php-apcu php-curl php-mcrypt php-imap \
    php-mysql php-memcached php-readline php-xdebug php-mbstring \
    php-xml php-zip php-intl php-bcmath php-soap php-fpm git

# Installing supervisor

RUN yum install -y python-setuptools
RUN easy_install pip
RUN pip install supervisor

# install nodejs
RUN yum install -y nodejs
RUN /usr/bin/npm install -g yarn
RUN /usr/bin/npm install -g gulp
RUN /usr/bin/npm install -g webpack

RUN \
	curl -sS https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer

# Adding the configuration file of the nginx
ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf
ADD app.conf /etc/nginx/conf.d/app.conf
ADD internal.conf /etc/nginx/conf.d/inernal.conf

# Adding the configuration file of the Supervisor
ADD supervisord.conf /etc/

# Adding the default file
ADD index.php /var/www/index.php

RUN yum -y autoremove && \
	yum clean metadata && \
	yum clean all

# Set the port to 80
EXPOSE 80 22 443 3306 6379

# Executing supervisord
CMD ["supervisord", "-n"]