#!/bin/bash

# create a server private key 
sudo openssl genrsa -passout pass:challenge -out /etc/ssl/private/server-key.pem 4096 

# certificate signing request (CSR)
# [-subject]        (prints out the certificate request subject)

sudo openssl req -subj "/CN=localhost" -sha256 -new -key /etc/ssl/private/server-key.pem -out /etc/ssl/certs/server.csr

# allow connections
sudo /bin/bash -c 'echo subjectAltName = DNS:localhost,IP:127.0.0.1 >> /etc/ssl/certs/extfile.cnf'

# set the docker daemon key's extended usage attributes to be used only for server authentication
sudo /bin/bash -c 'echo extendedKeyUsage = serverAuth >> /etc/ssl/certs/extfile.cnf'

# generate the signed certificate
# [-req]                (PKCS#10 certificate request is expected - self-signed)
# [-days arg]           (specifies the number of days until a newly generated certificate expires)
# [-in filename]        (input file for reading a certificate request if the -req flag is used)
# [-CA filename]        (specifies the "CA" certificate to be used for signing)
# [-CAkey filename]     (sets the CA private key to sign a certificate with. The private key must match the public key of the certificate given with -CA)
# [-CAcreateserial]     (with this option and the -CA option the CA serial number file is created if it does not exist)
# [-out filename]       (specifies the output filename to write)
# [-extfile filename]   (Configuration file containing certificate and request X.509 extensions to add)

sudo openssl x509 -req -days 365 -sha256 -in /etc/ssl/certs/server.csr -CA /etc/ssl/certs/ca-cert.pem -CAkey /etc/ssl/private/ca-key.pem \
  -CAcreateserial -passin pass:challenge -out /etc/ssl/certs/server-cert.pem -extfile /etc/ssl/certs/extfile.cnf

#------------------------------------------------------------------------------------------------

# remove the two certificate signing requests and extensions config files
sudo rm -v /etc/ssl/certs/server.csr /etc/ssl/certs/extfile.cnf

sudo mv /etc/ssl/private/server-key.pem /vagrant_data/ssl/private
sudo mv /etc/ssl/certs/server-cert.pem /vagrant_data/ssl/certs

# remove keys write permissions (prevent accidental damage)
# chmod -v 0400 /etc/ssl/private/ca-key.pem /etc/ssl/private/server-key.pem

# remove certificates write access (prevent accidental damage)
# chmod -v 0444 /etc/ssl/certs/ca-cert.pem /etc/ssl/certs/server-cert.pem