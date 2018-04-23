#!/bin/bash

# Update package manager and get tree package
sudo apt-get update
sudo apt-get install -y tree

# Setup a download and installation directory
HOME_DIR='/home/ubuntu'
INSTALLATION_DIR='/usr/local'
sudo mkdir ${HOME_DIR}/Downloads

# Install Java Development Kit
sudo apt-get install -y openjdk-8-jdk

# Install sbt for Scala
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt

# Install Python and boto
sudo apt-get install -y python-pip python-dev build-essential
sudo pip install boto
sudo pip install boto3

# Download Hadoop
HADOOP_VER=2.7.6
HADOOP_TAR=hadoop-${HADOOP_VER}.tar.gz
HADOOP_SOURCE_FOLDER=hadoop-${HADOOP_VER}
sudo wget https://s3-us-west-2.amazonaws.com/sparklab-repository/hadoop/${HADOOP_SOURCE_FOLDER}/hadoop-2.7.6.tar.gz -P ${HOME_DIR}/Downloads/
sudo tar zxvf ${HOME_DIR}/Downloads/${HADOOP_TAR} -C ${INSTALLATION_DIR}
sudo mv ${INSTALLATION_DIR}/${HADOOP_SOURCE_FOLDER} ${INSTALLATION_DIR}/hadoop
sudo chown -R ubuntu:ubuntu ${INSTALLATION_DIR}/hadoop

# Download Spark 
SPARK_SOURCE_FOLDER=spark-2.3.0-bin-hadoop2.7
SPARK_VER=2.3.0
SPARK_HADOOP_VER=2.7
SPARK_TAR=spark-2.3.0-bin-hadoop2.7.tgz
SPARK_URL=https://s3-us-west-2.amazonaws.com/sparklab-repository/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz
sudo wget ${SPARK_URL} -P ${HOME_DIR}/Downloads/
sudo tar zxvf ${HOME_DIR}/Downloads/${SPARK_TAR} -C ${INSTALLATION_DIR}
sudo mv ${INSTALLATION_DIR}/${SPARK_SOURCE_FOLDER} ${INSTALLATION_DIR}/spark
sudo chown -R ubuntu:ubuntu ${INSTALLATION_DIR}/spark
