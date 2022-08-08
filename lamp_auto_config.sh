tar -zxvf mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz
tar -zxvf httpd-2.4.41.tar.gz
tar -zxvf apr-1.7.0.tar.gz
tar -zxvf apr-util-1.6.1.tar.gz
tar -zxvf php-7.2.26.tar.gz
mv mysql-5.7.28-linux-glibc2.12-x86_64 /usr/local/mysql
mv httpd-2.4.41 httpd
mv apr-1.7.0 httpd/srclib/apr
mv apr-util-1.6.1 httpd/srclib/apr-util
mv httpd /usr/local
mv php-7.2.26 /usr/local/php-tar

cd /usr/local
groupadd mysql
useradd mysql -g mysql
chown -R mysql:mysql mysql/
chgrp -R mysql mysql/
yum -y install libaio
cd mysql/bin
./mysqld --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --initialize
sed -i 's/datadir=\/var\/lib\/mysql/datadir=\/usr\/local\/mysql\/data/g' /etc/my.cnf
sed -i 's/socket=\/var\/lib\/mysql\/mysql.sock/socket=\/usr\/local\/mysql\/mysql.sock/g' /etc/my.cnf
sed -i 's/log-error=\/var\/log\/mariadb\/mariadb.log/log-error=\/usr\/local\/mysql\/data\/mysql.log/g' /etc/my.cnf
sed -i 's/pid-file=\/var\/run\/mariadb\/mariadb.pid/pid-file=\/usr\/local\/mysql\/data\/mysql.pid/g' /etc/my.cnf
sed -i '1i [client]' /etc/my.cnf
sed -i '2i socket=\/usr\/local\/mysql\/mysql.sock' /etc/my.cnf
../support-files/mysql.server start
ln -s /usr/local/mysql/support-files/mysql.server  /etc/rc.d/init.d/mysql
chkconfig --add mysql
chmod +x /etc/rc.d/init.d/mysql
service mysql restart
sed -i '/\[mysqld\]/a\skip-grant-tables' /etc/my.cnf
service mysql restart
./mysql -uroot << EOF
flush privileges;
alter user 'root'@'localhost' identified by '123456';
exit
EOF
sed -i 's/skip-grant-tables/#&/g' /etc/my.cnf
service mysql restart
./mysql -uroot -p123456 << EOF
update mysql.user set host='%' where user='root';
grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;
flush privileges;
exit
EOF

firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload

cd /usr/local/httpd
yum -y install gcc make prce-devel openssl-devel expat-devel
./configure \
--prefix=/usr/local/httpd \
--enable-so \
--enable-ssl \
--enable-cgi \
--enable-rewrite \
--with-zlib \
--with-pcre \
--with-included-apr \
--enable-modules=most \
--enable-mpms-shared=all \
--with-mpm=prefork 
make && make install
echo $?
cd bin/
./apachectl start
sed -i '1i servername localhost:80' ../conf/httpd.conf
./apachectl restart
ln -s /usr/local/httpd/bin/apachectl /etc/rc.d/init.d/httpd
sed -i '1a # chkconfig: 35 85 21' /etc/init.d/httpd 
sed -i '2a # description: apache 2.4.41' /etc/init.d/httpd
chkconfig --add httpd
chkconfig httpd on
systemctl restart httpd

cd /usr/local/php-tar
yum -y install gcc autoconf gcc-c++
yum -y install  libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel readline readline-devel libxslt libxslt-devel
yum install -y systemd-devel
yum install -y openjpeg-devel
sed -i 's/\/replace\/with\/path\/to\/perl\/interpreter/\/usr\/bin\/perl/g' /usr/local/httpd/bin/apxs


./configure \
--prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--with-apxs2=/usr/local/httpd/bin/apxs \
--with-pdo-mysql=/usr/local/mysql \
--with-zlib \
--with-freetype-dir \
--enable-mbstring \
--with-libxml-dir=/usr \
--enable-xmlreader \
--enable-xmlwriter \
--enable-soap \
--enable-calendar \
--with-curl \
--with-zlib \
--with-gd \
--with-pdo-sqlite \
--with-pdo-mysql \
--with-mysqli \
--with-mysql-sock \
--enable-mysqlnd \
--disable-rpath \
--enable-inline-optimization \
--with-bz2 \
--with-zlib \
--enable-sockets \
--enable-sysvsem \
--enable-sysvshm \
--enable-pcntl \
--enable-mbregex \
--enable-exif \
--enable-bcmath \
--with-mhash \
--enable-zip \
--with-pcre-regex \
--with-jpeg-dir=/usr \
--with-png-dir=/usr \
--with-openssl \
--enable-ftp \
--with-kerberos \
--with-gettext \
--with-xmlrpc \
--with-xsl \
--enable-fpm \
--with-fpm-user=php-fpm \
--with-fpm-group=php-fpm \
--with-fpm-systemd \
--disable-fileinfo
make && make install
cp php.ini-development ../php/etc/php.ini
echo 'PATH=$PATH:/usr/local/php/bin' >>/etc/profile
echo 'export PATH' >>/etc/profile
sed -i '/AddType application\/x-gzip .gz .tgz/a\AddType application\/x-httpd-php .php' /usr/local/httpd/conf/httpd.conf
sed -i '/AddType application\/x-httpd-php .php/a\AddType application\/x-httpd-source .phps' /usr/local/httpd/conf/httpd.conf
sed -i '/php7_module/a\PhpIniDir \/usr\/local\/php\/etc' /usr/local/httpd/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/& index.php/g' /usr/local/httpd/conf/httpd.conf
service httpd restart
cp /root/test_apache_success.php /usr/local/httpd/htdocs/
cp /root/test_mysql_con_success.php /usr/local/httpd/htdocs/
service mysql restart
service httpd restart
service mysql restart
curl 127.0.0.1/test_apache_success.php
curl 127.0.0.1/test_mysql_con_success.php 
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload


