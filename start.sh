#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

service ssh start
$HADOOP_PREFIX/sbin/stop-all.sh
$HADOOP_PREFIX/sbin/start-all.sh -upgrade

$HADOOP_PREFIX/bin/hdfs dfs -mkdir /tmp 
$HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/local/hive/warehouse
$HADOOP_PREFIX/bin/hdfs dfs -chmod g+w /tmp 
$HADOOP_PREFIX/bin/hdfs dfs -chmod g+w /user/local/hive/warehouse

#Start Hive
#service mysqld start
#hiveserver2 --service hiveserver2 &

#Start hue in background
#cd /usr/share/hue/build/env/bin
#./supervisor &

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi