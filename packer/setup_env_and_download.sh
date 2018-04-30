#!/bin/bash

# Set S3 bucket and technology versions
S3_BUCKET='https://s3-us-west-2.amazonaws.com/insight-tech'

PYTHON_VER=2.7.12
PYTHON3_VER=3.5.2
JDK_VER=1.8.0
SCALA_VER=2.11.12
MAVEN_VER=3.5.3

HADOOP_VER=2.7.6
SPARK_VER=2.2.1
SPARK_HADOOP_VER=2.7

# Setup a download and installation directory
INSTALL_DIR='/usr/local'
mkdir ~/Downloads
DOWNLOADS_DIR=~/Downloads

# Update package manager and get some useful packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get update -y
sudo apt-get install -y tree
sudo apt-get install -y unzip
sudo apt-get install -y nmon

# Set convenient bash history settings
echo "export HISTSIZE="  >> ~/.profile
echo "export HISTFILESIZE="  >> ~/.profile
echo "export HISTCONTROL=ignoredups"  >> ~/.profile

# Install rmate for remote sublime text
sudo wget -O /usr/local/bin/rsub https://raw.github.com/aurora/rmate/master/rmate
sudo chmod +x /usr/local/bin/rsub

# Install the Java Development Kit Version 8 and set JAVA_HOME
sudo apt-get install -y default-jdk
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.profile
source ~/.profile

# Install Scala
sudo apt-get remove -y scala-library scala
sudo wget http://scala-lang.org/files/archive/scala-${SCALA_VER}.deb -P ${DOWNLOADS_DIR}/
sudo dpkg -i ${DOWNLOADS_DIR}/scala-${SCALA_VER}.deb
sudo apt-get update -y
sudo apt-get install -y scala

# Install sbt for Scala
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update -y
sudo apt-get install -y sbt

# Install Python and boto
sudo apt-get install -y python-pip python-dev build-essential
sudo apt-get -y install python3-pip
sudo pip install boto
sudo pip install boto3

# Function for installing technologies and setting up environment
install_tech() {
	local tech=$1
	local tech_dir=$2
	local tech_ext=$3

	wget ${S3_BUCKET}/${tech}/${tech_dir}.${tech_ext} -P ${DOWNLOADS_DIR}/
	sudo tar zxvf ${DOWNLOADS_DIR}/${tech_dir}.${tech_ext} -C ${INSTALL_DIR}
	sudo mv ${INSTALL_DIR}/${tech_dir} ${INSTALL_DIR}/${tech}
	sudo chown -R ubuntu:ubuntu ${INSTALL_DIR}/${tech}
	echo "" >> ~/.profile
	echo "export ${tech^^}_HOME=${INSTALL_DIR}/${tech}" >> ~/.profile
	echo -n 'export PATH=$PATH:' >> ~/.profile && echo "${INSTALL_DIR}/${tech}/bin" >> ~/.profile
}

# Install Technologies and setup environment
install_tech maven apache-maven-${MAVEN_VER} tar.gz
install_tech hadoop hadoop-${HADOOP_VER} tar.gz
install_tech spark spark-${SPARK_VER}-bin-hadoop${SPARK_HADOOP_VER} tgz
	
# Download and install Airflow
sudo pip install apache-airflow
