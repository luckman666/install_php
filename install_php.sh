#!/bin/bash

version="7.2.29"
url="http://cn2.php.net/distributions/php-${version}.tar.bz2"

# download package
wget -c $url

# check package
SOURCE_PACKAGE="php-${version}.tar.bz2"
if [ ! -f "$SOURCE_PACKAGE" ]; then
    echo "package no found "
    exit 1
fi

tar -jxf $SOURCE_PACKAGE
if [ "$?" != "0" ]; then
    echo "extra package fail "
    exit 2
fi

# install deps
yum install libjpeg libjpeg-devel curl-devel gcc gcc-c++ libxml2-devel openssl openssl-devel libpng-devel freetype-devel libmcrypt libmcrypt-devel -y

if [ "$?" != "0" ]; then
    echo "install deps fail "
    exit 3
fi

cd php-$version
./configure --prefix=/opt/php7 --with-config-file-path=/opt/php7/etc --with-config-file-scan-dir=/opt/php7/etc/php.d --with-mcrypt=/usr/include --enable-mysqlnd --with-mysqli --with-pdo-mysql --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-gd --with-iconv --with-zlib --enable-xml --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-mbregex --enable-mbstring --enable-ftp --enable-gd-native-ttf --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-session --with-curl --with-jpeg-dir --with-freetype-dir --enable-opcache --with-mhash
if [ "$?" != "0" ]; then
    echo "config php fail "
    exit 4
fi
make && make install

if [ "$?" != "0" ]; then
    echo "install php fail "
    exit 5
fi
\cp ./sapi/fpm/php-fpm.service /usr/lib/systemd/system/
\cp ./php.ini-development /opt/php7/etc/php.ini
\cp /opt/php7/etc/php-fpm.conf.default /opt/php7/etc/php-fpm.conf
\cp /opt/php7/etc/php-fpm.d/www.conf.default /opt/php7/etc/php-fpm.d/www.conf
systemctl daemon-reload
systemctl enable php-fpm
systemctl start php-fpm
