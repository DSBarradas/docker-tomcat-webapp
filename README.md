
### Description
Deploy a sample web app in a tomcat on a docker. 

### Requirements
- The docker must expose the port 4041
- Tomcat version is 8.5
- The docker base image is centos:7
- No manual commands should be required after the docker run command is executed in order to start and make the Sample App available.
- SSL/TLS is enabled at the 4041 endpoint (enable SSL/TLS on the tomcat daemon in an automatic fashion).

##### Note: If you already have docker installed on your host machine you can ignore step 1 and 5 (steps to create and clean a test environment) but have in mind that the test environment used throughout this project is Ubuntu 20.04.6 LTS.

## STEP 1 - TEST ENVIRONMENT

For this project we will use a [Virtual Box](https://www.virtualbox.org/wiki/Downloads) VM as a test environment to run Docker. Setting up test environments can be a time-consuming and error-prone task. A quick way to do it is to install [VAGRANT](https://developer.hashicorp.com/vagrant/docs/installation) on your host machine, which enables the creation and configuration of lightweight, reproducible, and portable development environments.

Create a project directory, download this repository from Github and in your project directory run the following commands.

```powershell
vagrant up
```
```powershell
vagrant ssh
```

##### Note: To check the state of the vagrant box use: <br> > _**vagrant status**_

Once inside the VM, run the following command to change to your project directory, in which you should have Dockerfile, tomcatscript.sh and sample.war.

In this project we wil use a vagrant ubuntu/focal64 box, so any commands inside the VM are associated with this box. <br>
(the folder _**/vagrant_data**_ was specified in the Vagrantfile as the sync_folder to your host)

```bash
cd /vagrant_data/
```

## STEP 2 - DOCKER

In this part, we are expected to have our environment ready to run Docker.

The following commands are used to start the docker service, build the docker image and run the container (tomcat server which makes webapp available).

##### Note: To check the state of the docker service, which was initiated with Vagrantfile use: <br> $ _**systemctl status docker**_

```bash          
sudo docker build -t tomcat .         # -t image_name         
```

##### Note: To check if the docker image build was successfull use: <br> $ _**sudo docker images**_

```bash
# optional docker run flags:
# [-d]      (run the container in the background)

sudo docker run -d -p 4041:8080 tomcat   # -p dockerPort:webAppPort
```

##### Note: To check the state of the docker container use: <br> $ _**sudo docker ps -a**_

## STEP 3 - TESTING

Use the following command on your docker host to test the accessibility of the webapp.

```shell
# optional curl flags:
# [-L] (Follow redirects)
# [-v] (Make the operation more talkative)

curl https://localhost:4041/sample/ 
```

##### Note: If no SSL/TLS is configured, you can test the access to the webapp through the following commands:
```shell
sudo docker build -t tomcat .              
sudo docker run -p 4041:8080 tomcat            
curl http://localhost:4041/sample/ 
```

### STEP 4 - CLEANUP DOCKER

Clean docker containers and images after testing.

```bash
sudo docker ps -a            # list containers (info about images they are spun from)
sudo docker images           # lists docker images 

sudo docker kill <container_id>    # stop a running container           
sudo docker rm <container_id> # Remove a stopped container (use -f to remove a running container)
sudo docker rmi <image_id>    # Remove image (will fail if there is a docker container referencing image)
```

### STEP 5 - CLEANUP TEST ENVIRONMENT

Clean test environment.

```powershell
vagrant destroy         # specify -f to ot ask for confirmation before destroying
```

##  Generating CA public certificate & CA private key

```bash
# generate CA private key (RSA private key)
# [-aes256]           (encrypt the private key)
# [-out filename]     (output the key to the specified file)
# [numbits]           (size of the private key)

openssl genrsa -aes256 -passout pass:challenge -out ca-key.pem 4096  
```

##### Note: When this command is executed, an input pass phrase for ca-key is required. 

```bash
# generate CA public certificate
# [-new]            (generates a new certificate request)
# [-x509]           (outputs a certificate instead of a certificate request)
# [-days n]         (when -x509 is in use this specifies the number of days to certify the certificate)
# [-key filename]   (provides the private key for signing a new certificate or certificate request)
# [-digest]         (specifies the message digest to sign the request)
# [-out filename]   (specifies the output filename)

openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -passin pass:challenge -out ca-cert.pem
```
##### Note: To generate the CA certicate, the input pass phrase for ca-key is required.

## Install SSL/TLS on Tomcat 

#### Note: This step is imcomplete. I'll update it as soon as I find a solution.

Even though this wasn't acomplished in the configuration files (Vagrantfile, Dockerfile, tomcat.sh), a path to the solution was thought.

First step is to generate the Tomcat Server private key, make the signing request and then and sign the certificate with our CA.
The next bash script below is merely a guide on how to do it, from the references.

```bash
## GENERATE SERVER KEY

# create a private key
openssl genrsa -aes256 -out /etc/ssl/private/server-key.pem 4096

# create a signing request (CSR):
openssl req -config openssl.cnf -new -sha256 \
  -key /etc/ssl/private/server-key.pem -out /etc/ssl/certs/server-cert.csr

# sign the CSR:
openssl ca -config openssl.cnf -extensions ocsp -days 375 -notext \
  -md sha256 -in /etc/ssl/certs/server-cert.csr -out /etc/ssl/certs/server-cert.pem

# verify the certificate:
openssl x509 -noout -text -in /etc/ssl/certs/server-cert.pem

```


From the "SSL/TLS on Tomcat" reference, you can also notice that some changes need to be made to the _**server.xml**_ file in order to enable HTTPS (SSL/TLS).

##### Note: To find this file, after you launch the container, you can use the commands: <br><br> _**user@testenvironment$ sudo docker exec -it <container_id> /bin/sh**_ <br> _**user@container$ find / -name server.xml**_ <br>(the path to service.xml is /opt/tomcat/apache-tomcat-8.5.100/conf/server.xml)

From the references mentioned, we conclude that the following section will have to be added to the tomcat container:

```xml
    <Connector port="8443" protocol="org.apache.coyote.http11.Http11AprProtocol"
               maxThreads="150" 
               maxParameterCount="1000"
               secure="true"
               scheme="https"
               SSLEnabled="true"
               >
        <UpgradeProtocol className="org.apache.coyote.http2.Http2Protocol" />
        <SSLHostConfig
                         caCertificateFile="/etc/ssl/certs/ca-cert.pem"
                         certificateVerification="require"
                         certificateVerificationDepth="10" >
            <Certificate 
                         certificateKeyFile="/etc/ssl/private/server-key.pem"
                         certificateFile="/etc/ssl/certs/server-cert.pem"
                         type="RSA" />
        </SSLHostConfig>
    </Connector>
```

To be continued...

## Client Key

```bash

sudo -i

mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

cp /vagrant_data/ca-key.pem /etc/ssl/private/ca-key.pem
cp /vagrant_data/ca-cert.pem /etc/ssl/certs/ca-cert.pem

# create a client key
openssl genrsa -out /etc/ssl/private/client-key.pem 4096

# certificate signing request
openssl req -subj '/CN=client' -new -key /etc/ssl/private/client-key.pem -out /etc/ssl/certs/client.csr

# make the key suitable for client authentication
echo extendedKeyUsage = clientAuth > /etc/ssl/certs/extfile-client.cnf

# generate the signed certificate
openssl x509 -req -days 365 -sha256 -in /etc/ssl/certs/client.csr -CA /etc/ssl/certs/ca-cert.pem -CAkey /etc/ssl/private/ca-key.pem \
  -CAcreateserial -passin pass:challenge -out /etc/ssl/certs/client-cert.pem -extfile /etc/ssl/certs/extfile-client.cnf

exit # quit sudo mode

#--------------------------------------------------------------------------------------

# remove the two certificate signing requests and extensions config files
sudo rm -v /etc/ssl/certs/client.csr /etc/ssl/certs/extfile-client.cnf

# remove keys write permissions (prevent accidental damage)
sudo chmod -v 0400 /etc/ssl/private/ca-key.pem  /etc/ssl/private/client-key.pem

# remove certificates write access (prevent accidental damage)
sudo chmod -v 0444 etc/ssl/certs/ca-cert.pem etc/ssl/certs/client-cert.pem
```



## Vagrantfile 

```bash
vagrant@ubuntu:/vagrant_data$ whoami
vagrant
```

```bash
# Create the docker group
sudo groupadd docker

# Add vagrant user to the docker group
# [-a] (Add the user to the supplementary group. Use only with the -G option)
# [-G] (A list of supplementary groups which the user is also a member of)
sudo usermod -aG docker vagrant
```

## File Structure

```
|--- Vagrantfile
|--- Dockerfile
|--- tomcat.sh
|--- server-key.sh
|--- client-key.sh
|--- server.xml
|--- sample.war
|--- ssl
|    |--- certs
|         |--- ca-cert.pem
|    |--- private
|         |--- ca-key.pem
|
```


## References

[Install Docker Engine on Ubuntu (test environment VM)]( https://docs.docker.com/engine/install/ubuntu/ )

[Dockerfile Syntax](https://docs.docker.com/reference/dockerfile/) 

[Generate CA private key and CA public certificate](https://docs.docker.com/engine/security/protect-access/) 

[Openssl Documentation](https://www.openssl.org/docs/man3.3/man1/openssl.html)

[SSL/TLS on Tomcat](https://tomcat.apache.org/tomcat-8.5-doc/ssl-howto.html)

