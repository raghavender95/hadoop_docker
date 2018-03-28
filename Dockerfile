FROM ubuntu:latest
MAINTAINER raghavender95

USER root

# update and install basic tools
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -yq curl software-properties-common openssh-server openssh-client rsync wget


############ passwordless ssh ####################
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key -y
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key -y
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa 
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys



# install java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $PATH:$JAVA_HOME/bin


# install hadoop
############# Hadoop Installation ######################
RUN curl https://archive.apache.org/dist/hadoop/core/hadoop-3.0.0/hadoop-3.0.0.tar.gz | tar -xz -C /usr/local/
#COPY hadoop-3.0.0.tar.gz /usr/local/hadoop-3.0.0.tar.gz
#RUN tar -xvzf /usr/local/hadoop-3.0.0.tar.gz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-3.0.0 hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_INSTALL $HADOOP_HOME
ENV PATH $PATH:$HADOOP_INSTALL/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_HOME $HADOOP_INSTALL
ENV HADOOP_HDFS_HOME $HADOOP_INSTALL
ENV YARN_HOME $HADOOP_INSTALL
ENV PATH $HADOOP_HOME/bin:$PATH

############# Add Hadoop Configuration Files #############
ADD hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh
ADD core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
ADD yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml


ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

ADD start.sh /etc/start.sh
RUN chown root:root /etc/start.sh
RUN chmod 700 /etc/start.sh

ENV HDFS_NAMENODE_USER root
ENV HDFS_DATANODE_USER root
ENV HDFS_SECONDARYNAMENODE_USER root
ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root

# Hdfs ports
EXPOSE 9810 9820 9870 9875 9890 8020 9000

# Mapred ports
EXPOSE 10020 19888

#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088

#Other ports
EXPOSE 49707 2122

RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

RUN /usr/local/hadoop/bin/hdfs namenode -format

# install hive
RUN mkdir /usr/local/hive
RUN curl -s http://apache.mesi.com.ar/hive/hive-2.3.2/apache-hive-2.3.2-bin.tar.gz | tar -xz -C /usr/local/hive --strip-components 1
ENV HIVE_HOME /usr/local/hive
ENV PATH $HIVE_HOME/bin:$PATH



######## Hive UI Port ################
EXPOSE 10002

ADD hive-env.sh $HIVE_HOME/conf/hive-env.sh
ADD hive-site.xml $HIVE_HOME/conf/hive-site.xml



# Derby for Hive metastore backend
RUN cd $HIVE_HOME && $HIVE_HOME/bin/schematool -initSchema -dbType derby

CMD ["/etc/start.sh","-d"]