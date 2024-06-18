FROM centos:7

# add the shell script and the sample application to the docker image
COPY /scripts/tomcatscript.sh /tmp 
COPY /tomcat-config/sample.war /tmp
COPY /tomcat-config/server.xml /tmp

# run the shell script which installs the tomcat server and prepares the container for the webapp
RUN /tmp/tomcatscript.sh

COPY /ssl/private/server-key.pem /etc/ssl/private
COPY /ssl/certs/server-cert.pem /etc/ssl/certs
COPY /ssl/certs/ca-cert.pem /etc/ssl/certs

# expose container port for HTTP and HTTPS
EXPOSE 8080 4041 

# run the webapp in the tomcat server
CMD ["/opt/tomcat/apache-tomcat-8.5.100/bin/catalina.sh", "run"]
