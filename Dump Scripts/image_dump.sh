#!/bin/bash

mkdir -p /var/backups/Image_Dumps/logs

echo "What is the wiki name?"
read wikiname

tar -czvf /var/backups/Image_Dumps/$wikiname.tar.gz /var/www/html/w/images > /var/backups/Image_Dumps/logs/$wikiname.log
