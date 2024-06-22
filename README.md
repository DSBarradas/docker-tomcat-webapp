
### Description
Deploy a [sample web app](https://tomcat.apache.org/tomcat-8.5-doc/appdev/sample/) in a tomcat on a docker. 


### Requirements
- The docker must expose the port 4041
- Tomcat version is 8.5
- The docker base image is centos:7
- No manual commands should be required after the docker run command is executed in order to start and make the Sample App available.
- SSL/TLS is enabled at the 4041 endpoint (enable SSL/TLS on the tomcat daemon in an automatic fashion).

## Project Structure

```
|--- Vagrantfile
|--- Dockerfile
|--- scripts
     |--- tomcat.sh
     |--- server-key.sh
|--- tomcat-config
     |--- server.xml
     |--- sample.war
|--- ssl
     |--- certs
          |--- ca-cert.pem
          |--- server-cert.pem
     |--- private
          |--- ca-key.pem
          |--- server-key.pem
```

* `Vagratfile` ---> build test environment.
* `Dockerfile` ---> build Tomcat docker image.
* `scripts`
  * `tomcat.sh`  ---> prepare Tomcat image during build.
  * `server-key.sh` ---> generate server key and certificate.
* `tomcat-config`
  * `server.xml` ---> Tomcat server configuration.
  * `sample.war` ---> Webapp file.
* `ssl`
  * `certs`
    * `ca-cert.pem` ---> CA public certificate.
    * `server-cert.pem` ---> Tomcat signed certificate.
  * `private`
    * `ca-key.pem` ---> CA private key.
    * `server-key.pem` ---> Tomcat private key.

## STEP 1 - Test Environment

##### Note: If you already have docker installed on your host machine you can ignore step 1 and 5 (steps to create and clean a test environment) but have in mind that the test environment used throughout this project is Ubuntu 20.04.6 LTS.

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

## STEP 2 - Docker

In this part, we are expected to have our environment ready to run Docker.

The following commands are used to start the docker service, build the docker image and run the container (tomcat server which makes webapp available).

##### Note: To check the state of the docker service, which was initiated with Vagrantfile use: <br> $ _**systemctl status docker**_

```bash          
docker build -t tomcat .         # -t image_name         
```

##### Note: To check if the docker image build was successfull use: <br> $ _**docker images**_

```bash
# optional docker run flags:
# [-d]      (run the container in the background)

docker run -d -p 8080:8080 -p 4041:4041 tomcat   # -p dockerPort:webAppPort
```

##### Note: To check the state of the docker container use: <br> $ _**docker ps -a**_

## STEP 3 - Testing

Use the following command on your docker host to test the accessibility of the webapp using HTTPS SSL/TLS.

```shell
# optional curl flags:
# [-L] (Follow redirects)
# [-v] (Make the operation more talkative)
# [-k]            (ignores invalid and self-signed certificate errors)    
# [--cacert] <ca-cert-file> (specify the CA certificate)

curl https://localhost:4041/sample/ 
```

If no SSL/TLS is configured or you want to test using HTTP, you can test the access to the webapp through the following command:

```shell  
curl http://localhost:8080/sample/ 
```

### STEP 4 - Cleanup Docker

Clean docker containers and images after testing.

```bash
docker ps -a            # list containers (info about images they are spun from)
docker images           # lists docker images 

docker stop <container_id>    # stop a running container           
docker rm <container_id> # Remove a stopped container (use -f to remove a running container)
docker rmi <image_id>    # Remove image (will fail if there is a docker container referencing image)
```

### STEP 5 - Cleanup Test Environment

Clean test environment.

```powershell
vagrant destroy         # specify -f to destroy without asking for confirmation
```

##  Generating CA public certificate & CA private key

```bash
# generate CA private key (RSA private key)
# [-aes256]           (encrypt the private key)
# [-out filename]     (output the key to the specified file)
# [numbits]           (size of the private key)

openssl genrsa -aes256 -passout pass:challenge -out /vagrant_data/ssl/private/ca-key.pem 4096  
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

openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -passin pass:challenge -out /vagrant_data/ssl/certs/ca-cert.pem
```
##### Note: To generate the CA certicate, the input pass phrase for ca-key is required.

## Installing CA on Windows

- Click the Windows Start button;
- Type `mmc.exe`, right-click the `mmc.exe` entry in the search results and select Run as Administrator;
- Select File > Add/Remove Snap-in;
- Select Certificates and click Add;
- In the Certificates snap-in dialog, select Computer account and complete the wizard.
- Click OK.
- In the MMC console, expand Certificates.
- Right-click Trusted Root Certificates and select All Tasks > Import.
- Browse your project folder and you'll find the CA certificate under `ssl/certs/ca-cert.crt`

## Results

- On the VM
  - HTTP 
  <br> (to be added)
  - HTTPS
  <br> (to be added)

- On Windows
  - Without the CA installed
  <br> (to be added)
  - With the CA installed
  <br> (to be added)

##### Note: In order to test on a browser on Windows you have to enable port forwarding from port 443 on your Windows Host to the port 4041 on your VM.


## References

[Install Docker Engine on Ubuntu (test environment VM)]( https://docs.docker.com/engine/install/ubuntu/ )

[Dockerfile Syntax](https://docs.docker.com/reference/dockerfile/) 

[Generate CA private key and CA public certificate](https://docs.docker.com/engine/security/protect-access/) 

[Openssl Documentation](https://www.openssl.org/docs/man3.3/man1/openssl.html)

[SSL/TLS on Tomcat](https://tomcat.apache.org/tomcat-8.5-doc/ssl-howto.html)

[Curl](https://curl.se/docs/sslcerts.html)

