#!/bin/bash

__mysql_config() {
# Hack to get MySQL up and running... I need to look into it more.
echo "Running the mysql_config function."
yum -y erase mysql mysql-server
rm -rf /var/lib/mysql/ /etc/my.cnf
yum -y install mysql mysql-server
mysql_install_db
chown -R mysql:mysql /var/lib/mysql
/usr/bin/mysqld_safe & 
sleep 10
}

__start_mysql() {
echo "Running the start_mysql function."
cd /usr/local/hive/scripts/metastore/upgrade/mysql/
mysqladmin -u root password root
mysql -uroot -proot -e "CREATE DATABASE metastore_db;"
mysql -uroot -proot -e "use metastore_db; source hive-schema-2.3.0.mysql.sql;"
sleep 10
}

# Call all functions
__mysql_config
__start_mysql