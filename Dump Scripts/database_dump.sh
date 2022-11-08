#! /bin/bash

mkdir -p /var/backup/mariaDB

echo "what is database username?"
read username

echo "password for username"
read pass1

echo "What is database name?"
read database_name

/usr/bin/mysqldump -h localhost  --user=$username --password=$pass1 $database_name --single-transaction --quick > /var/backup/mariaDB/$database_name.sql

echo "Database dump created and is located at /var/backup/mariaDB/${database_name}.sql"
