#!/bin/bash

# Tomcat 8.5 requires Java SE 7 or later 
# (the base image did not come with unzip neither wget preinstalled)
yum install -y java-1.8.0-openjdk-devel unzip wget openssl

# Create Tomcat system user 
useradd -m -U -d /opt/tomcat tomcat

#-------------------------------------------------------------
# when trying to WGET the tomcat 8.5 zip, an error occurred: 
# ERROR: cannot verify dlcdn.apache.org's certificate
# the solution was to update the ca-certificates

# install the ca-certificates package
yum install -y ca-certificates

# update ca-certificates
update-ca-trust
#-------------------------------------------------------------

# download tomcat 8.5 from their webpage
wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.100/bin/apache-tomcat-8.5.100.zip -O /tmp/apache-tomcat-8.5.100.zip

# extract the zip file and move it to a new directory 
unzip /tmp/apache-tomcat-8.5.100.zip -d /tmp
mkdir -p /opt/tomcat

mv /tmp/sample.war /tmp/apache-tomcat-8.5.100/webapps
mv /tmp/apache-tomcat-8.5.100 /opt/tomcat

# change the directory ownership
chown -R tomcat /opt/tomcat

# give exec permission to the file in location with .sh extension
sh -c 'chmod +x /opt/tomcat/apache-tomcat-8.5.100/bin/*.sh'

mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

mv /tmp/ca-key.pem /etc/ssl/private
mv /tmp/ca-cert.pem /etc/ssl/certs

#------------------------------------------------------------------------------------------------


