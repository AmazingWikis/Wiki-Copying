All bash scripts provided have been tested on Ubuntu 20.04 for mediawiki 1.37.6. These scripts will be updated as necessary.

Once the fork is completed, perform the announcement immediately or after Google Indexed stuff

* figure out how to use botpasswords or user credentials for grabDeletedText.php, grabDeletedFiles.php

3 bash scripts have been prepared to allow smooth forking
* quick install mediawiki 1.37.6 and get a wiki up
* cloning a remote wiki
* create a database dump
* create an image dump

In order to execute these scripts, you will need sysop priviledges and set `sudo chmod +x /path/to/script`

General Forking Information
- Purchase a domain, best stable price is $12 at google domains that includes domain privacy and locking
- mysql/mariadb config settings
*- set storage engine to `InnoDB`
*- disable binary logs to save storage space
/etc/mysql/my.cnf
bind-address		= 0.0.0.0
default_storage_engine	= InnoDB

/etc/mysql/mariadb.conf.d/50-server.cnf
#log_bin                = /var/log/mysql/mysql-bin.log
#max_binlog_size        = 100M

- prepare a mediawiki installation and install into a new database
*- Truncate all of the following database tables: page, revision, revision_actor_temp, revision_comment_temp, ip_changes, slots, content, text, user, actor, logging, log_search
-* after setting up a wiki and configuring namespaces, configure $wgExtraNamespaces and $wgContentNamespaces in LocalSettings.php, Refer to php /grabbers/grabNamespaceInfo.php

- Download the Grabber scripts
*- replace user.php and grabLogs.php files with the following


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
https://zeldapedia.wiki/wiki/Guidelines:Account_Migration


NOTES for Fandom/Gamepedia
* If your wiki is assigned a Wiki Representative [paid employee], do not inform them of your intent to fork or threaten to fork. They are obligated to inform their supervisor
* if a prior fork threat is made, the instant you announce will result in immediate demotion
* if you perform a surprise fork announcement, will result in immediate demotion
* all interwiki and links to NIWA or SEIWA networks will be purged
* extension data is not recoverable and Fandom/Gamepedia will not provide this table data in .sql format
