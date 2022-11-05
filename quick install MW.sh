#! /bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt-get autoremove -y

sudo apt-get install -y git wget composer librsvg2-bin liblua5.3-0 libpcre3 libpcre3-dev spl imagemagick lsb-release apt-transport-https ca-certificates

export DEBIAN_FRONTEND=noninteractive

echo 'installing apache'
sudo apt install -y apache2 apache2-utils
sudo apt-get autoremove -y
a2enmod headers
sudo a2enmod rewrite
sudo systemctl restart apache2


echo "installing php"
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt install -y php7.4.3 php7.4.3-cli php7.4.3-common
sudo apt-get install -y php-mysql php-apcu php-memcached php-curl php-xml php-mbstring php-intl p7zip-full p7zip-rar
sudo phpenmod mbstring
sudo phpenmod xml
sudo phpenmod intl
php -v


echo 'installing mariadb server'
sudo apt-get install -y software-properties-common dirmngr apt-transport-https
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el,s390x] https://mirror.its.dal.ca/mariadb/repo/10.6/ubuntu focal main'
sudo apt install -y mariadb-server-10.6 mariadb-client-10.6
mariadb -V
sudo systemctl enable mariadb
sudo systemctl status mariadb
sudo apt-get autoremove -y
sudo apt-get autoclean

sudo mysql_secure_installation

echo "What is database name?"
read database_name

mysql -u root -e "CREATE DATABASE $database_name;"

echo "What is server IP?"
read IP

echo "password for MW_Admin"
read pass1

mysql -u root -e "CREATE USER 'MW_Admin'@'localhost' IDENTIFIED BY '$pass1';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'MW_Admin'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'MW_Admin'@'$IP' IDENTIFIED BY '$pass1';"

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


echo "What is the language of the remote wiki?"
read lang

php /var/www/html/w/maintenance/install.php --dbname="$database_name" --dbserver="localhost" --installdbuser="MW_Admin" --installdbpass="$pass1" --dbuser="MW_Admin" --dbpass="$pass1" --server="$IP" --scriptpath=/wiki --lang="$lang" --pass="hf50lp2wM79E0fjois" "Temp Wiki" "Admin"


php /var/www/html/wiki/maintenance/update.php --quick --force

echo 'setting up firewall'
sudo ufw allow 'Apache Full'
sudo ufw allow 'Apache Secure'
sudo ufw allow https
sudo ufw allow any port 3306
sudo ufw allow any port mysql

sudo systemctl enable apache2
sudo systemctl enable mariadb
sudo systemctl enable ufw
sudo ufw enable
sudo ufw reload
sudo systemctl restart apache2
systemctl daemon-reload
sudo systemctl reboot
