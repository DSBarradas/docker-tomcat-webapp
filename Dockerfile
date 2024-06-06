FROM centos:7

# add the shell script and the sample application to the docker image
COPY tomcatscript.sh /tmp 
COPY sample.war /tmp
COPY ca-cert.pem /tmp
COPY ca-key.pem /tmp

# run the shell script which installs the tomcat server and prepares the container for the webapp
RUN /tmp/tomcatscript.sh

# expose container port
EXPOSE 4041

# run the webapp in the tomcat server
CMD ["/opt/tomcat/apache-tomcat-8.5.100/bin/catalina.sh", "run"]

