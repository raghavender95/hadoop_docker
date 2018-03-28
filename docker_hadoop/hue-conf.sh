cd /usr/local
wget http://www-eu.apache.org/dist/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
tar -xzf apache-maven-3.5.3-bin.tar.gz
ln -s apache-maven-3.5.3 apache-maven
export M2_HOME=/usr/local/apache-maven
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

cd /usr/local 
wget https://www.dropbox.com/s/auwpqygqgdvu1wj/hue-4.1.0.tgz
tar -xzf hue-4.1.0.tgz
ln -s hue-4.1.0 hue
cd hue
PREFIX=/usr/share make install

adduser hue
sudo chown -R hue:hue /usr/share/hue