#! /bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt-get autoremove -y

sudo apt-get install -y git wget librsvg2-bin liblua5.3-0 libpcre3 libpcre3-dev spl imagemagick lsb-release apt-transport-https ca-certificates

export DEBIAN_FRONTEND=noninteractive

echo 'installing apache'
sudo apt install -y apache2 apache2-utils
sudo apt-get autoremove -y
a2enmod headers
sudo a2enmod rewrite

echo "what is full domain name?"
read domain
sudo nano /etc/apache2/sites-available/$domain.conf

echo "what is full subdomain name?"
read subdomain

sudo nano /etc/apache2/sites-available/$subdomain.conf

sudo a2dissite 000-default.conf
sudo a2ensite $domain.conf
sudo a2ensite $subdomain.conf
sudo systemctl restart apache2

echo 'installing lets encrypt'
sudo apt-get update -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe
sudo apt install -y certbot python3-certbot-apache

sudo certbot --apache
systemctl reload apache2
sudo systemctl restart apache2


echo "installing php"
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt install -y php7.4.3 php7.4.3-cli php7.4.3-common php-cli unzip
sudo apt-get install -y php-mysql php-apcu php-memcached php-curl php-xml php-mbstring php-intl p7zip-full p7zip-rar
sudo phpenmod mbstring
sudo phpenmod xml
sudo phpenmod intl
php -v

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo 'installing mariadb server'
sudo apt-get install -y software-properties-common dirmngr apt-transport-https
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el,s390x] https://mirror.its.dal.ca/mariadb/repo/10.6/ubuntu focal main'
sudo apt install -y mariadb-server-10.6 mariadb-client-10.6
mariadb -V
sudo systemctl status mariadb
sudo apt-get autoremove -y
sudo apt-get autoclean

sudo mysql_secure_installation

echo "What is database name?"
read database_name

mysql -u root -e "CREATE DATABASE $database_name;"

echo "password for MW_Admin"
read pass1

mysql -u root -e "CREATE USER 'MW_Admin'@'localhost' IDENTIFIED BY '$pass1';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'MW_Admin'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'MW_Admin'@'127.0.0.1' IDENTIFIED BY '$pass1';"

mysql -u root -e "FLUSH PRIVILEGES;"

echo 'setting up wiki files'
sudo chown -R www-data:www-data /var/www/html/*
sudo chmod 755 -R /var/www/html/*
echo 'mw 1.37.6'
wget -P /tmp/ https://releases.wikimedia.org/mediawiki/1.37/mediawiki-1.37.6.tar.gz
tar xvzf /tmp/mediawiki-1.37.6.tar.gz -C /var/www/html/
mv /var/www/html/mediawiki-1.37.6 /var/www/html/w/
sudo chown -R www-data:www-data /var/www/
sudo chown -R www-data:www-data /var/www/html
sudo chown -R www-data:www-data /var/www/html/*
sudo chmod 755 -R /var/www/html/w/*
sudo rm /tmp/mediawiki-1.37.6.tar.gz

cp /var/www/html/w/composer.json /root/composer.json
cd /root
php /usr/local/bin/composer update --no-dev
cp /root/composer.lock /var/www/html/w/composer.lock

echo "What is the language of the remote wiki?"
read lang

php /var/www/html/w/maintenance/install.php --dbname="$database_name" --dbserver="127.0.0.1" --installdbuser="MW_Admin" --installdbpass="$pass1" --dbuser="MW_Admin" --dbpass="$pass1" --server="$subdomain" --scriptpath=/wiki --lang="$lang" --pass="hf50lp2wM79E0fjois" "Temp Wiki" "Admin"


php /var/www/html/w/maintenance/update.php --quick --force

mysql -u root -e "USE $database_name; TRUNCATE TABLE page;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE revision;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE revision_actor_temp;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE revision_comment_temp;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE ip_changes;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE content;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE user;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE actor;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE logging;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE log_search;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE image;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE oldimage;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE filearchive;"
mysql -u root -e "USE $database_name; TRUNCATE TABLE imagelinks;"


echo 'setting up firewall'
sudo ufw allow 'Apache Full'
sudo ufw allow 'Apache Secure'
sudo ufw allow 'mysql'
sudo ufw allow 'ssh'

sudo systemctl enable apache2
sudo systemctl enable mariadb
sudo systemctl enable ufw
sudo ufw enable
sudo ufw reload
sudo systemctl restart apache2
systemctl daemon-reload
sudo systemctl reboot
