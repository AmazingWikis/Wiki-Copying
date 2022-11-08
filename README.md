NOT SUITABLE FOR DEPLOYMENT USAGE! ALL SOFTWARE IS INSTALLED ON ONE SERVER IS SUBJECT TO DATA LOSS.

All bash scripts provided have been tested on Ubuntu 20.04 for mediawiki 1.37.6. These should work at any VPS provider. These scripts will be updated as necessary.

Once the fork is completed, perform the announcement immediately or after Google Indexed stuff

* figure out how to use botpasswords or user credentials for grabDeletedText.php, grabDeletedFiles.php

3 bash scripts have been prepared to allow smooth forking
* quick install mediawiki 1.37.6 and get a wiki up
* create the required Apache conf file using "sample.conf" as a guide
* Add the ".htaccess" file to "/var/www/html" directory
* cloning a remote wiki
* create a database dump
* create an image dump - best to grab files on the production environment as moving files tends to cause thumbnail issues

In order to execute these scripts, you will need sysop priviledges and set `sudo chmod +x /path/to/script`

the MariaDB username is MW_Admin

General Forking Information
- Purchase a domain, best stable price is $12 at google domains that includes domain privacy and locking
- Configure networking A records, link your domain to the server IP address. This is required for creating a wiki.
- at your VPS host provider's dashboard, locate the Networking tab and choose "Domains"
*- enter your domain
- click on your domain then create an A record
*- set HOSTNAME to subdomain
*- choose your VPS server
click "Create Record"

- mysql/mariadb config settings
*- set storage engine to `InnoDB`
*- disable binary logs to save storage space
/etc/mysql/my.cnf
bind-address		= 0.0.0.0
default_storage_engine	= InnoDB

/etc/mysql/mariadb.conf.d/50-server.cnf
#log_bin                = /var/log/mysql/mysql-bin.log
#max_binlog_size        = 100M

- Configure $wgExtraNamespaces and $wgContentNamespaces in LocalSettings.php, Refer to php /grabbers/grabNamespaceInfo.php

- Download the Grabber scripts
*- replace user.php and grabLogs.php files with the following


create a copy of the remote target wiki
- run grabNamespaceInfo.php	
*- update LocalSettings.php with custom namespace
- run grabLogs.php 
*- bot account credentials/botpassword required: grabDeletedText.php, grabDeletedFiles.php, grabUserGroups.php
- grabText.php
*- it is best to skip several namespaces due to proprietary extensions
- grabFiles.php
- grabProtectedTitles.php	
- grabUserBlocks.php

if there has been a delay between grabbing a copy of the remote wiki and community approval, use grabNewText.php to get updated content and grabNewFiles.php to get new files


For remote user authentication, install and configure Extension:MediaWikiAuth
- it would be wise to disable copying over watch lists as that could delay the user authentication process
- DO NOT USE grabber's populateUserTable.php, instead use MediaWikiAuth's populateUserTable.php
- See additional account migration steps at https://zeldapedia.wiki/wiki/Guidelines:Account_Migration


REFORMAT BELOW AS WIKI

Forking Guide - ShoutWiki
- Submit a request for XML database and image dumps OR use Grabber scripts [requires sysop/admin + bot flag]
- Request the wiki be removed


Forking Guide - Miraheze 
- Submit a request for XML database and image dumps OR use Grabber scripts [requires sysop/admin + bot flag]
- Recovery of extension data where the database table does not contain sensitive personal information can be provided on request as a sql dump.
*- import this sql data into the wiki database AFTER you have created a clone of the remote target wiki
- Request the wiki be removed


Forking Guide - Grabber Sripts [Fandom/Gamepedia, Miraheze, ShoutWiki]
- Prepare a bot account: either use an existing bot account OR create a new account and gain community approval for a bot flag
- Grant the bot account sysop/admin user-group


NOTES for Fandom/Gamepedia
* If your wiki is assigned a Wiki Representative [paid employee], do not inform them of your intent to fork or threaten to fork. They are obligated to inform their supervisor
* if a prior fork threat is made, the instant you announce will result in immediate demotion
* if you perform a surprise fork announcement, will result in immediate demotion
* all interwiki and links to NIWA or SEIWA networks will be purged
* extension data is not recoverable and Fandom/Gamepedia will not provide this table data in .sql format


Best Practices
separate critical components to isolated servers

FAQ
Is the included quick MediaWiki script recommended for production environment?
No, having all of the software and both the web and database servers installed all one on server is poor practices subject to data loss. This is meant to quickly move a wiki from another platform that refuses to provide image and database dumps.

Do not remote clone a wiki with an active community with the intent to compete, the purpose of providing these shell scripts and instructions is to assist wiki communities who wish to leave but lack the technical skills to move.

These Shell Scripts are designed to automated as much of the process, however requires user input and manual configurations. This means that basic technical skills are required, which includes purchase of a domain and configure networking of the domain's [A, Custom Name Server, CAA  aka SSL Certificates records].
