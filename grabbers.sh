#! /bin/bash

exec 1>>/var/log/grabber.log 2>&1

cd /var/www/html/w/
git clone https://gerrit.wikimedia.org/r/mediawiki/tools/grabbers.git 


# build url
echo "What is the subdomain?"
read subdomain

echo "What is the base domain?"
read domain

URL = ""

if ["${domain}" === "fandom"] {
	URL = "https://$subdomain.$domain.com/api.php"
}

if ["${domain}" === "miraheze"] {
	URL = "https://$subdomain.$domain.org/w/api.php"
}

if ["${domain}" === "shoutwiki"] {
	URL = "http://www.$subdomain.$domain.com/w/api.php"
}

echo "What is database user?"
read dbUser

echo "What is database user password?"
read dbPass

echo "What is database name?"
read dbName

php /var/www/html/w/grabbers/grabbers/grabNamespaceInfo.php --dbpass="$dbPass" --dbuser="$dbUser" --url="$URL" 

echo "Please provide custom namespaces and separate with a |. Do not add spacing"
read customNamespaces

namespaces = "0|1|2|3|4|5|6|7|8|9|10|11|14|15"

if ![ -z "${customNamespaces}" ] {
	namespaces = "$namespaces|$customNamespaces"
}

php /var/www/html/w/grabbers/grabLogs.php --db="$dbName" --dbpass="$dbPass" --dbuser="$dbUser" --url="$URL"  --namespaces="$namespaces"
php /var/www/html/w/grabbers/grabText.php --db="$dbName" --dbpass="$dbPass" --dbuser="$dbUser"  --url="$URL"  --namespaces="$namespaces"
php /var/www/html/w/grabbers/grabFiles.php --db="$dbName" --dbpass="$dbPass" --dbuser="$dbUser" --url="$URL" 
php /var/www/html/w/grabbers/grabProtectedTitles.php --db="$dbName" --dbpass="$dbPass" --dbuser="$dbUser" ---url="$URL" 
php /var/www/html/w/grabbers/grabUserBlocks.php --db="$dbName" --dbpass="$dbPass" --dbuser="$dbUser" --url="$URL" 
php /var/www/html/w/grabbers/grabUserGroups.php --db="$dbName" --dbpass="$dbPass" --dbuser="$dbUser" --url="$URL" 

echo "remote wiki user?"
read username

echo "remote wiki's botpassword?"
read botpassword

# botpassword required [bot, sysop]
php /var/www/html/w/grabbers/grabDeletedText.php --dbpass="$dbPass"  --dbuser="$dbUser" --url="$URL" --namespaces="$namespaces" --username="$username" --password="$botpassword"
php /var/www/html/w/grabbers/grabDeletedFiles.php --db="$dbName" --dbpass="$dbPass"  --dbuser="$dbUser" --url="$URL" --username="$username" --password="$botpassword"

php /var/www/html/w/maintenance/checkBadRedirects.php --conf /var/www/html/w/LocalSettings.php

php /var/www/html/w/maintenance/updateRestrictions.php 
php /var/www/html/w/maintenance/populateCategory.php --force
php /var/www/html/w/maintenance/rebuildrecentchanges.php
php /var/www/html/w/maintenance/rebuildtextindex.php 
php /var/www/html/w/maintenance/refreshLinks.php 
php /var/www/html/w/maintenance/update.php --quick --force
php /var/www/html/w/maintenance/updateArticleCount.php --update
php /var/www/html/w/maintenance/initSiteStats.php --update
php /var/www/html/w/maintenance/runJobs.php
php /var/www/html/w/maintenance/runJobs.php
php /var/www/html/w/maintenance/runJobs.php
php /var/www/html/w/maintenance/runJobs.php
php /var/www/html/w/maintenance/rebuildImages.php
php /var/www/html/w/maintenance/refreshFileHeaders.php
php /var/www/html/w/maintenance/updateSpecialPages.php

