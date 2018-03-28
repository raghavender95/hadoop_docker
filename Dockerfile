FROM centos:6.9
MAINTAINER Vodafone

USER root

########### install dev tools ##################
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync wget
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

############ passwordless ssh ####################
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

############ Java Installation ######################
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"
RUN rpm -i jdk-8u131-linux-x64.rpm
RUN rm jdk-8u131-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java

############# Hadoop Installation ######################
RUN curl https://archive.apache.org/dist/hadoop/core/hadoop-3.0.0/hadoop-3.0.0.tar.gz | tar -xz -C /usr/local/
#COPY hadoop-3.0.0.tar.gz /usr/local/hadoop-3.0.0.tar.gz
#RUN tar -xvzf /usr/local/hadoop-3.0.0.tar.gz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-3.0.0 hadoop

############# Add Hadoop Configuration Files #############
ADD hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh
ADD core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
ADD yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml

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

########### hive installation ##############################################
RUN curl http://www-eu.apache.org/dist/hive/hive-2.3.2/apache-hive-2.3.2-bin.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./apache-hive-2.3.2-bin hive

#Export Hadoop path
  ENV HADOOP_HOME /usr/local/hadoop
  ENV PATH $HADOOP_HOME/bin:$PATH
  
#Export Hive path
  ENV HIVE_HOME /usr/local/hive/
  ENV PATH $HIVE_HOME/bin:$PATH


######## Hive UI Port ################
EXPOSE 10002

ADD hive-env.sh $HIVE_HOME/conf/hive-env.sh
ADD hive-site.xml $HIVE_HOME/conf/hive-site.xml


# Derby for Hive metastore backend
RUN cd $HIVE_HOME && $HIVE_HOME/bin/schematool -initSchema -dbType derby

CMD ["/etc/start.sh","-d"]